import Foundation
import HealthKit
import Observation
import SharedCore

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
    @MainActor private(set) var kind: WatchWorkoutKind = .zone2
    /// Session start time, for showing elapsed time on open-ended (Zone 2) sessions.
    @MainActor private(set) var startDate: Date?

    /// Drives the structured timeline when running a 4×4. Nil for Zone 2.
    @MainActor private(set) var intervalEngine: IntervalEngine?

    // MARK: HealthKit
    private let store = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    private let calculator: HRZoneCalculator

    init(calculator: HRZoneCalculator) {
        self.calculator = calculator
        super.init()
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
        let typesToShare: Set = [HKQuantityType.workoutType()]
        var typesToRead: Set<HKObjectType> = [HKObjectType.workoutType()]
        if let hr = HKQuantityType.quantityType(forIdentifier: .heartRate) {
            typesToRead.insert(hr)
        }
        if let energy = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
            typesToRead.insert(energy)
        }
        try await store.requestAuthorization(toShare: typesToShare, read: typesToRead)
    }

    @MainActor
    func start(kind: WatchWorkoutKind) {
        guard HKHealthStore.isHealthDataAvailable(), !isRunning else { return }
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
                let engine = IntervalEngine(calculator: calculator)
                self.intervalEngine = engine
                engine.start()
            } else {
                self.intervalEngine = nil
            }

            let startDate = Date()
            self.startDate = startDate
            session.startActivity(with: startDate)
            builder.beginCollection(withStart: startDate) { _, _ in }
            isRunning = true
        } catch {
            // Surface nothing fancy on the watch; just stay idle.
            session = nil
            builder = nil
            isRunning = false
        }
    }

    @MainActor
    func end() {
        intervalEngine?.stop()
        session?.end()
    }

    // MARK: - Saving

    private func finishAndSave() {
        guard let builder else { return }
        let endDate = Date()
        builder.endCollection(withEnd: endDate) { [weak self] _, _ in
            builder.finishWorkout { workout, _ in
                // `workout` (HKWorkout?) is now persisted to Health. Forward it to the iPhone.
                let energyKcal = builder.statistics(for: HKQuantityType(.activeEnergyBurned))?
                    .sumQuantity()?.doubleValue(for: .kilocalorie())
                Task { @MainActor in
                    guard let self else { return }
                    if let workout {
                        let type: SessionType = self.kind == .fourByFour ? .norwegian4x4 : .zone2
                        let transfer = WorkoutTransfer(
                            healthUUID: workout.uuid.uuidString,
                            date: workout.startDate,
                            type: type,
                            durationMin: Int((workout.duration / 60).rounded()),
                            energyKcal: energyKcal.map { Int($0.rounded()) }
                        )
                        WatchWorkoutSender.shared.send(transfer)
                    }
                    self.isRunning = false
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
            isRunning = false
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
        Task { @MainActor in
            self.currentHR = rounded
            self.currentZone = zone
        }
    }
}
