import Foundation
import Observation
import SharedCore
#if canImport(WatchKit)
import WatchKit
#endif

/// Watch-side host around the pure `IntervalRunner` state machine: owns the
/// per-second `Timer`, feeds it the latest heart rate, republishes its state for
/// SwiftUI via `@Observable`, and turns the runner's events into haptics.
///
/// Timing is anchored to the wall clock (`TickClock`), not to timer fires: watchOS
/// throttles timers while the app is inactive (wrist down), so each fire — and each
/// incoming heart-rate sample — advances the runner by however many whole seconds
/// actually elapsed. Missed seconds are replayed as catch-up ticks.
///
/// All adaptive timing logic lives in `IntervalRunner` (SharedCore) so it's unit
/// tested on the Mac; this class is just the runtime wiring.
@Observable
@MainActor
final class IntervalEngine {
    private var runner: IntervalRunner

    @ObservationIgnored private var timer: Timer?
    /// Wall-clock anchor: how many seconds the runner should be advanced by.
    @ObservationIgnored private var clock = TickClock()
    /// Latest heart rate pushed from the workout session (0 until the first sample).
    @ObservationIgnored private var latestHR: Int = 0
    /// When `latestHR` was last refreshed; stale samples are treated as no reading.
    @ObservationIgnored private var latestHRDate: Date?
    /// A reading older than this is treated as "no heart rate" so the runner's
    /// blind fallback can kick in (a dead sensor stops delivering samples — the
    /// last value would otherwise look fresh forever).
    private static let hrStaleAfterSec: TimeInterval = 10
    // Retained so `start()` can rebuild the runner with the athlete's tuned guards.
    @ObservationIgnored private let warmupMinSec: Int
    @ObservationIgnored private let hardWallCapSec: Int
    @ObservationIgnored private let recoveryMinSec: Int

    init(
        intervals: [WorkoutInterval],
        warmupMinSec: Int = 180,
        hardWallCapSec: Int = 8 * 60,
        recoveryMinSec: Int = 30
    ) {
        self.warmupMinSec = warmupMinSec
        self.hardWallCapSec = hardWallCapSec
        self.recoveryMinSec = recoveryMinSec
        self.runner = IntervalRunner(
            intervals: intervals,
            warmupMinSec: warmupMinSec,
            hardWallCapSec: hardWallCapSec,
            recoveryMinSec: recoveryMinSec
        )
    }

    convenience init(
        calculator: HRZoneCalculator,
        repeats: Int = Norwegian4x4.repeats,
        warmupMinSec: Int = 180,
        hardWallCapSec: Int = 8 * 60,
        recoveryMinSec: Int = 30
    ) {
        self.init(
            intervals: Norwegian4x4.build(using: calculator, repeats: repeats),
            warmupMinSec: warmupMinSec,
            hardWallCapSec: hardWallCapSec,
            recoveryMinSec: recoveryMinSec
        )
    }

    /// Quality summary of the session so far (per-rep stats + score).
    var summary: FourByFourSummary { runner.summary }

    // MARK: Published state (republished from the runner)

    var intervals: [WorkoutInterval] { runner.intervals }
    var currentIndex: Int { runner.currentIndex }
    var secondsRemaining: Int { runner.secondsRemaining }
    var coachingCue: CoachingCue? { runner.coachingCue }
    var isFinished: Bool { runner.isFinished }
    /// True when HR has been unavailable long enough that timing fell back to the clock.
    var noHeartRate: Bool { runner.isBlind }

    /// The segment the athlete is currently in, or nil when finished/empty.
    var currentInterval: WorkoutInterval? { runner.currentInterval }

    /// Total number of hard efforts in the session.
    var hardRepTotal: Int { runner.intervals.lazy.filter { $0.kind == .hard }.count }

    /// Which hard effort (1-based) is in progress, or nil when not in a hard segment.
    var hardRepIndex: Int? {
        guard currentInterval?.kind == .hard else { return nil }
        return runner.intervals[...runner.currentIndex].lazy.filter { $0.kind == .hard }.count
    }

    /// Overall session completion, 0…1, by segment index.
    var sessionProgress: Double {
        let total = runner.intervals.count
        guard total > 0 else { return 0 }
        return min(1, Double(runner.currentIndex) / Double(total))
    }

    /// "HARD 2:13" style label for the live view.
    var countdownLabel: String {
        guard let interval = currentInterval else { return "DONE" }
        let name = interval.kind.displayName.uppercased()
        let mins = secondsRemaining / 60
        let secs = secondsRemaining % 60
        return String(format: "%@ %d:%02d", name, mins, secs)
    }

    /// Feed the latest heart rate (bpm) so adaptive segments can react. Also
    /// advances any due ticks: HealthKit keeps delivering samples while the app is
    /// inactive, so this keeps timing accurate even when the timer is throttled.
    func updateHeartRate(_ bpm: Int) {
        latestHR = bpm
        latestHRDate = Date()
        advanceDueTicks()
    }

    /// `latestHR`, or 0 when the last sample is too old to trust.
    private var effectiveHR: Int {
        guard let latestHRDate,
              Date().timeIntervalSince(latestHRDate) <= Self.hrStaleAfterSec else { return 0 }
        return latestHR
    }

    func start() {
        guard timer == nil, !runner.intervals.isEmpty else { return }
        runner = IntervalRunner(
            intervals: runner.intervals,
            warmupMinSec: warmupMinSec,
            hardWallCapSec: hardWallCapSec,
            recoveryMinSec: recoveryMinSec
        )
        playHaptic(.start)
        clock.start()
        startTimer()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        clock.pause()
    }

    /// Resumes ticking after a pause — keeps the runner's state (no reset, no haptic).
    /// Time spent paused yields no ticks (the clock re-anchors at resume).
    func resume() {
        guard timer == nil, !runner.isFinished else { return }
        clock.start()
        startTimer()
    }

    private func startTimer() {
        let t = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.advanceDueTicks() }
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    /// Advances the runner by however many whole seconds have elapsed since the
    /// last advance — one tick in the steady state, several after a throttled gap.
    private func advanceDueTicks() {
        let due = clock.consumeDue()
        guard due > 0 else { return }
        let hr = effectiveHR
        for _ in 0..<due {
            for event in runner.tick(heartRate: hr) {
                handle(event)
            }
            if runner.isFinished { break }
        }
    }

    private func handle(_ event: IntervalRunner.Event) {
        switch event {
        case .enteredSegment(let kind):
            // Distinguish ramping into a hard effort from easing off.
            playHaptic(kind == .hard ? .directionUp : .notification)
        case .cue(let cue):
            // Only the "work harder" nudge buzzes; easing off is expected.
            if cue == .push { playHaptic(.directionUp) }
        case .heartRateLost:
            // Let the athlete know intervals are now timed, not HR-driven.
            playHaptic(.notification)
        case .heartRateRestored:
            break
        case .finished:
            playHaptic(.success)
            stop()
        }
    }

    private func playHaptic(_ type: HapticType) {
        #if canImport(WatchKit)
        WKInterfaceDevice.current().play(type.wkType)
        #endif
    }

    private enum HapticType {
        case start, notification, directionUp, success
        #if canImport(WatchKit)
        var wkType: WKHapticType {
            switch self {
            case .start: return .start
            case .notification: return .notification
            case .directionUp: return .directionUp
            case .success: return .success
            }
        }
        #endif
    }
}

// IntervalKind.displayName / CoachingCue tokens now live in SharedCore, shared by
// the watch engine and the iPhone guided player.
