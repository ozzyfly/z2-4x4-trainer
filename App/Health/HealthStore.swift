import Foundation
import SwiftData
import SharedCore

/// Observable wrapper around a `HealthProviding` source. Drives the UI and imports
/// Apple Health workouts into SwiftData, deduped by `WorkoutLog.healthUUID`.
@Observable
final class HealthStore {
    private let provider: HealthProviding

    var authorized = false
    var todayEnergy = 0
    var latestWeightKg: Double?
    var weightSeries: [(date: Date, kg: Double)] = []
    private(set) var fitness: FitnessTrend?
    private(set) var readiness: ReadinessScore?

    init(provider: HealthProviding) {
        self.provider = provider
    }

    /// Requests authorization, then loads metrics (no SwiftData import).
    @MainActor
    func connect() async {
        do {
            try await provider.requestAuthorization()
            authorized = true
        } catch {
            authorized = false
        }
        await loadMetrics()
    }

    /// Loads metrics and imports recent workouts into `context`, deduped by health UUID.
    @MainActor
    func refresh(context: ModelContext) async {
        await loadMetrics()
        await importWorkouts(into: context)
    }

    @MainActor
    private func loadMetrics() async {
        todayEnergy = await provider.todayActiveEnergyKcal()
        latestWeightKg = await provider.latestBodyMassKg()
        weightSeries = await provider.bodyMassSeries(days: 30)
        fitness = FitnessTrend.from(await provider.vo2MaxSeries(days: 180))

        let hrv = await provider.hrvSeries(days: 30)
        let restingHR = await provider.restingHeartRateSeries(days: 30)
        readiness = ReadinessCalculator.score(hrv: hrv, restingHR: restingHR)
    }

    @MainActor
    private func importWorkouts(into context: ModelContext) async {
        let workouts = await provider.recentWorkouts(days: 30)
        guard !workouts.isEmpty else { return }

        let existing = (try? context.fetch(FetchDescriptor<WorkoutLog>())) ?? []
        let existingUUIDs = Set(existing.compactMap { $0.healthUUID })

        for w in workouts where !existingUUIDs.contains(w.uuid) {
            let log = WorkoutLog(
                date: w.date,
                type: .zone2,
                durationMin: w.durationMin,
                activeEnergyKcal: w.energyKcal,
                note: "Imported from Apple Health",
                healthUUID: w.uuid,
                source: .health
            )
            context.insert(log)
        }
    }
}
