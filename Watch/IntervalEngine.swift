import Foundation
import Observation
import SharedCore
#if canImport(WatchKit)
import WatchKit
#endif

/// Drives a structured `Norwegian4x4` session: a wall-clock timer that advances
/// through the prebuilt interval list, exposing the current segment and the
/// seconds remaining in it, and firing a haptic on every transition.
@Observable
@MainActor
final class IntervalEngine {
    /// The full prescribed timeline (warmup → 4×(hard+recovery) → cooldown).
    let intervals: [WorkoutInterval]

    /// Index of the segment currently in progress, or `intervals.count` once finished.
    private(set) var currentIndex: Int = 0

    /// Whole seconds left in the current segment.
    private(set) var secondsRemaining: Int = 0

    /// True once the final segment has elapsed.
    private(set) var isFinished: Bool = false

    private var timer: Timer?

    init(intervals: [WorkoutInterval]) {
        self.intervals = intervals
        self.secondsRemaining = intervals.first?.durationSec ?? 0
    }

    convenience init(calculator: HRZoneCalculator) {
        self.init(intervals: Norwegian4x4.build(using: calculator))
    }

    /// The segment the athlete is currently in, or nil when finished/empty.
    var currentInterval: WorkoutInterval? {
        guard currentIndex < intervals.count else { return nil }
        return intervals[currentIndex]
    }

    /// "HARD 2:13" style label for the live view.
    var countdownLabel: String {
        guard let interval = currentInterval else { return "DONE" }
        let mins = secondsRemaining / 60
        let secs = secondsRemaining % 60
        return String(format: "%@ %d:%02d", interval.kind.displayName.uppercased(), mins, secs)
    }

    func start() {
        guard timer == nil, !intervals.isEmpty else { return }
        currentIndex = 0
        isFinished = false
        secondsRemaining = intervals[0].durationSec
        playHaptic(.start)
        let t = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        guard currentIndex < intervals.count else { return }
        if secondsRemaining > 1 {
            secondsRemaining -= 1
            return
        }
        // Current segment just elapsed; advance.
        advance()
    }

    private func advance() {
        let next = currentIndex + 1
        if next < intervals.count {
            currentIndex = next
            secondsRemaining = intervals[next].durationSec
            // Distinguish ramping into a hard effort from easing off.
            playHaptic(intervals[next].kind == .hard ? .directionUp : .notification)
        } else {
            currentIndex = intervals.count
            secondsRemaining = 0
            isFinished = true
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

extension IntervalKind {
    var displayName: String {
        switch self {
        case .warmup: return "Warm Up"
        case .hard: return "Hard"
        case .recovery: return "Recovery"
        case .cooldown: return "Cool Down"
        }
    }
}
