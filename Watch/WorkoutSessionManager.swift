import Foundation
import HealthKit
import Observation
import SharedCore
import os

private let log = Logger(subsystem: "ca.logolo.z24x4", category: "WorkoutSession")

/// Which session the watch is running.
enum WatchWorkoutKind: String, Identifiable, CaseIterable {
    case zone2
    case fourByFour

    var id: String { rawValue }

    var title: String {
        switch self {
        case .zone2: return "Zone 2"
        case .fourByFour: return "Norwegian 4×4"
        }
    }

    var isStructured: Bool { self == .fourByFour }
}

/// Owns the `HKWorkoutSession` + `HKLiveWorkoutBuilder` lifecycle and surfaces the
/// live heart rate and derived `HRZone` to SwiftUI. Saves an `HKWorkout` on end.
///
/// `@unchecked Sendable` because `HKLiveWorkoutBuilderDelegate` callbacks arrive on
/// HealthKit's queue; all mutable UI state is hopped back to the main actor.
@Observable
final class WorkoutSessionManager: NSObject, @unchecked Sendable {
    // MARK: Live state (read on the main actor by SwiftUI)
    @MainActor private(set) var currentHR: Int = 0
    @MainActor private(set) var currentZone: HRZone?
    @MainActor private(set) var isRunning = false
    @MainActor private(set) var isPaused = false
    @MainActor private(set) var kind: WatchWorkoutKind = .zone2
    /// Session start time, for showing elapsed time on open-ended (Zone 2) sessions.
    @MainActor private(set) var startDate: Date?

    /// Drives the structured timeline when running a 4×4. Nil for Zone 2.
    @MainActor private(set) var intervalEngine: IntervalEngine?

    /// Banked "time in Zone 2" (seconds) for an open-ended Zone 2 session — only
    /// accrues while HR is at/above the Zone 2 floor.
    @MainActor private(set) var zone2InZoneSeconds: Int = 0
    /// Whether the Zone 2 timer is currently counting (HR in zone) vs paused (Zone 1).
    @MainActor private(set) var zone2Counting: Bool = false
    @MainActor private var zone2Tracker: Zone2TimeTracker?
    private var zone2Timer: Timer?
    /// Wall-clock anchor for the Zone 2 tracker: watchOS throttles timers while
    /// the app is inactive, so each timer fire (and each HR sample) advances the
    /// tracker by however many whole seconds actually elapsed.
    @MainActor private var zone2Clock = TickClock()
    /// When the last heart-rate sample arrived; stale readings are treated as none.
    @MainActor private var lastHRSampleDate: Date?
    /// A reading older than this is treated as "no heart rate" — a dead sensor
    /// stops delivering samples, so the last value would otherwise look fresh forever.
    private static let hrStaleAfterSec: TimeInterval = 10

    @MainActor var zone2AverageHR: Int { zone2Tracker?.avgInZoneHR ?? 0 }
    @MainActor var zone2InZonePercent: Int { zone2Tracker?.inZonePercent ?? 0 }
    @MainActor var zone2TotalSeconds: Int { zone2Tracker?.totalSeconds ?? 0 }
    /// True when the Zone 2 tracker lost heart rate long enough to credit
    /// wall-clock time instead (surfaced as "No HR — timed" in the live view).
    @MainActor var zone2Blind: Bool { zone2Tracker?.isBlind ?? false }

    // MARK: HealthKit
    private let store = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    private var calculator: HRZoneCalculator
    private var warmupMinSec: Int
    private var hardWallCapSec: Int
    private var recoveryMinSec: Int

    init(
        calculator: HRZoneCalculator,
        warmupMinSec: Int = 180,
        hardWallCapSec: Int = 480,
        recoveryMinSec: Int = 30
    ) {
        self.calculator = calculator
        self.warmupMinSec = warmupMinSec
        self.hardWallCapSec = hardWallCapSec
        self.recoveryMinSec = recoveryMinSec
        super.init()
    }

    /// Swaps in zones + 4×4 guards from a freshly synced profile, but only while idle —
    /// never mid-session (the live builder reads `calculator` off the main actor, so
    /// we only mutate it when no session is running and no callbacks can race).
    @MainActor
    func applyProfileIfIdle(_ profile: UserProfile) {
        guard !isRunning else { return }
        calculator = HRZoneCalculator(profile: profile)
        warmupMinSec = profile.warmupMinSec
        hardWallCapSec = profile.hardWallCapSec
        recoveryMinSec = profile.recoveryMinSec
    }

    /// The active target band, for the live view to show "in zone" feedback.
    @MainActor var targetRange: HRRange? {
        switch kind {
        case .zone2:
            return calculator.zone2
        case .fourByFour:
            return intervalEngine?.currentInterval?.targetHR
        }
    }

    // MARK: - Lifecycle

    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        // The live builder saves heart-rate and active-energy samples into the
        // workout, so those types need *share* authorization too — with only
        // workoutType the workout saves but its samples (energy!) are dropped.
        var typesToShare: Set<HKSampleType> = [HKQuantityType.workoutType()]
        var typesToRead: Set<HKObjectType> = [HKObjectType.workoutType()]
        if let hr = HKQuantityType.quantityType(forIdentifier: .heartRate) {
            typesToRead.insert(hr)
            typesToShare.insert(hr)
        }
        if let energy = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
            typesToRead.insert(energy)
            typesToShare.insert(energy)
        }
        try await store.requestAuthorization(toShare: typesToShare, read: typesToRead)
    }

    @MainActor
    func start(kind: WatchWorkoutKind) {
        guard HKHealthStore.isHealthDataAvailable() else {
            log.error("HealthKit data not available on this device — no heart rate.")
            return
        }
        guard !isRunning else { return }
        self.kind = kind
        self.currentHR = 0
        self.currentZone = nil

        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .running
        configuration.locationType = .unknown

        do {
            let session = try HKWorkoutSession(healthStore: store, configuration: configuration)
            let builder = session.associatedWorkoutBuilder()
            builder.dataSource = HKLiveWorkoutDataSource(
                healthStore: store,
                workoutConfiguration: configuration
            )
            session.delegate = self
            builder.delegate = self

            self.session = session
            self.builder = builder

            if kind.isStructured {
                // Drop to a reduced session on low-readiness days; honor advanced guards.
                let reps = Norwegian4x4.recommendedRepeats(for: WidgetSnapshotStore.read()?.readinessLabel)
                let engine = IntervalEngine(
                    calculator: calculator,
                    repeats: reps,
                    warmupMinSec: warmupMinSec,
                    hardWallCapSec: hardWallCapSec,
                    recoveryMinSec: recoveryMinSec
                )
                self.intervalEngine = engine
                engine.start()
            } else {
                self.intervalEngine = nil
                startZone2Timer()
            }

            let startDate = Date()
            self.startDate = startDate
            session.startActivity(with: startDate)
            builder.beginCollection(withStart: startDate) { ok, error in
                if !ok { log.error("beginCollection failed: \(String(describing: error)) — heart rate will not stream.") }
            }
            // Stamp the session kind so a re-import from Apple Health keeps the right type.
            let sessionType: SessionType = kind == .fourByFour ? .norwegian4x4 : .zone2
            builder.addMetadata([WorkoutMetadata.sessionTypeKey: sessionType.rawValue]) { _, _ in }
            isRunning = true
        } catch {
            log.error("failed to start workout session: \(error)")
            session = nil
            builder = nil
            isRunning = false
        }
    }

    @MainActor
    func end() {
        intervalEngine?.stop()
        stopZone2Timer()
        session?.end()
    }

    /// Pauses timing + data collection mid-session; the HKWorkoutSession excludes
    /// paused time from the recorded duration.
    @MainActor
    func pause() {
        guard isRunning, !isPaused else { return }
        isPaused = true
        session?.pause()
        intervalEngine?.stop()
        stopZone2Timer()
    }

    @MainActor
    func resume() {
        guard isRunning, isPaused else { return }
        isPaused = false
        session?.resume()
        if kind.isStructured {
            intervalEngine?.resume()
        } else {
            startZone2Timer(reset: false)
        }
    }

    // MARK: - Zone 2 in-zone timer

    @MainActor
    private func startZone2Timer(reset: Bool = true) {
        if reset {
            zone2InZoneSeconds = 0
            zone2Counting = false
            zone2Tracker = Zone2TimeTracker(lowerBound: calculator.zone2.lower, upperBound: calculator.zone2.upper)
        }
        zone2Clock.start()
        let t = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tickZone2() }
        }
        RunLoop.main.add(t, forMode: .common)
        zone2Timer = t
    }

    /// `currentHR`, or 0 when the last sample is too old to trust.
    @MainActor
    private var effectiveHR: Int {
        guard let lastHRSampleDate,
              Date().timeIntervalSince(lastHRSampleDate) <= Self.hrStaleAfterSec else { return 0 }
        return currentHR
    }

    /// Advances the tracker by however many whole seconds have elapsed — one in
    /// the steady state, several when the timer was throttled (wrist down).
    @MainActor
    private func tickZone2() {
        let due = zone2Clock.consumeDue()
        guard due > 0, var tracker = zone2Tracker else { return }
        let hr = effectiveHR
        for _ in 0..<due { tracker.tick(heartRate: hr) }
        zone2Tracker = tracker
        zone2InZoneSeconds = tracker.inZoneSeconds
        zone2Counting = tracker.isCounting
    }

    @MainActor
    private func stopZone2Timer() {
        zone2Timer?.invalidate()
        zone2Timer = nil
        zone2Clock.pause()
    }

    // MARK: - Saving

    private func finishAndSave() {
        guard let builder else { return }
        let endDate = Date()
        builder.endCollection(withEnd: endDate) { [weak self] _, endError in
            if let endError { log.error("endCollection failed: \(endError)") }
            builder.finishWorkout { workout, finishError in
                if workout == nil {
                    log.error("finishWorkout returned no workout (\(String(describing: finishError))) — not synced to iPhone.")
                }
                // `workout` (HKWorkout?) is now persisted to Health. Forward it to the iPhone.
                let energyKcal = builder.statistics(for: HKQuantityType(.activeEnergyBurned))?
                    .sumQuantity()?.doubleValue(for: .kilocalorie())
                Task { @MainActor in
                    guard let self else { return }
                    self.stopZone2Timer()
                    if let workout {
                        let type: SessionType = self.kind == .fourByFour ? .norwegian4x4 : .zone2
                        // Zone 2 credits only time spent in zone; 4×4 uses wall-clock duration.
                        let durationMin = type == .zone2
                            ? Int((Double(self.zone2InZoneSeconds) / 60).rounded())
                            : Int((workout.duration / 60).rounded())
                        let summary = self.intervalEngine?.summary
                        let z2 = self.zone2Tracker
                        // Don't record empty mis-taps (ended immediately, nothing banked).
                        if durationMin >= 1 {
                            let transfer = WorkoutTransfer(
                                healthUUID: workout.uuid.uuidString,
                                date: workout.startDate,
                                type: type,
                                durationMin: durationMin,
                                energyKcal: energyKcal.map { Int($0.rounded()) },
                                qualityScore: type == .norwegian4x4 ? summary?.qualityScore : nil,
                                peakHR: type == .norwegian4x4 ? summary?.peakHR : nil,
                                avgHardHR: type == .norwegian4x4 ? summary?.avgHardHR : nil,
                                repsCompleted: type == .norwegian4x4 ? summary?.repsCompletedFully : nil,
                                avgHR: type == .zone2 ? z2?.avgInZoneHR : nil,
                                totalSec: type == .zone2 ? z2?.totalSeconds : nil
                            )
                            WatchWorkoutSender.shared.send(transfer)
                        }
                    }
                    self.isRunning = false
                    self.isPaused = false
                    self.session = nil
                    self.builder = nil
                }
            }
        }
    }
}

// MARK: - HKWorkoutSessionDelegate

extension WorkoutSessionManager: HKWorkoutSessionDelegate {
    func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didChangeTo toState: HKWorkoutSessionState,
        from fromState: HKWorkoutSessionState,
        date: Date
    ) {
        if toState == .ended {
            finishAndSave()
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        Task { @MainActor in
            intervalEngine?.stop()
            stopZone2Timer()
            isRunning = false
            isPaused = false
        }
    }
}

// MARK: - HKLiveWorkoutBuilderDelegate

extension WorkoutSessionManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}

    func workoutBuilder(
        _ workoutBuilder: HKLiveWorkoutBuilder,
        didCollectDataOf collectedTypes: Set<HKSampleType>
    ) {
        guard let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate),
              collectedTypes.contains(hrType),
              let statistics = workoutBuilder.statistics(for: hrType) else {
            return
        }
        let unit = HKUnit.count().unitDivided(by: .minute())
        guard let bpm = statistics.mostRecentQuantity()?.doubleValue(for: unit) else { return }
        let rounded = Int(bpm.rounded())
        let zone = calculator.zone(forBPM: rounded)
        // Relay the live reading to the phone (best-effort) so a phone-side guided
        // session can show it.
        WatchWorkoutSender.shared.sendLiveHR(rounded)
        Task { @MainActor in
            self.currentHR = rounded
            self.currentZone = zone
            self.lastHRSampleDate = Date()
            // Drive the adaptive interval timing (hard waits for the zone, recovery
            // ends once HR drops back) with the latest sample. Both engines also
            // advance any wall-clock ticks that a throttled timer missed —
            // HealthKit keeps delivering samples while the app is inactive.
            self.intervalEngine?.updateHeartRate(rounded)
            if !self.kind.isStructured { self.tickZone2() }
        }
    }
}
