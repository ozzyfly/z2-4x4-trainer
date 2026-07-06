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

    private static let connectedKey = "hasConnectedHealth"
    /// Minimum minutes before a workout stamped by our own watch app is worth
    /// re-importing from Health — the watch deliberately skips logging mis-taps.
    static let minimumOwnImportMinutes = 5

    init(provider: HealthProviding) {
        self.provider = provider
    }

    /// Whether the user has connected Apple Health before (persisted across launches),
    /// so we can silently restore the connection instead of asking again.
    var hasConnectedBefore: Bool { UserDefaults.standard.bool(forKey: Self.connectedKey) }

    /// Requests authorization, then loads metrics (no SwiftData import). Requesting
    /// again after the first grant is silent — the system doesn't re-prompt.
    @MainActor
    func connect() async {
        do {
            try await provider.requestAuthorization()
            authorized = true
            UserDefaults.standard.set(true, forKey: Self.connectedKey)
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
        // Optional recovery signals: sleeping wrist temperature above baseline
        // and short sleep both subtract from readiness (penalty-only, so their
        // absence changes nothing).
        let wristTemp = await provider.wristTemperatureSeries(days: 30)
        let sleepHours = await provider.lastNightSleepHours()
        readiness = ReadinessCalculator.score(
            hrv: hrv,
            restingHR: restingHR,
            wristTemp: wristTemp,
            sleepHours: sleepHours
        )
    }

    /// The most recent resting heart-rate reading from Apple Health, if any.
    @MainActor
    func latestRestingHR() async -> Int? {
        await provider.restingHeartRate()
    }

    /// Seeds Apple-style heart-rate zones from Health: pulls resting HR and the
    /// observed-max HR, then derives the five bands with the heart-rate-reserve
    /// (Karvonen) method Apple uses by default. `maxHR` is the higher of the
    /// supplied estimate (override or 220 − age) and the observed maximum, so a
    /// well-trained athlete's real ceiling isn't undercut.
    ///
    /// Returns nil when Health has no resting-HR sample to work from — without it
    /// HRR zones can't be computed and the caller should keep manual entry.
    ///
    /// Note: HealthKit exposes no API for the Fitness app's *configured* zone
    /// boundaries, so this is a close estimate, not a guaranteed exact match.
    @MainActor
    func appleZoneSeed(age: Int, maxHROverride: Int?) async -> (zones: [HRRange], restingHR: Int, maxHR: Int)? {
        guard let resting = await provider.restingHeartRate() else { return nil }
        let observedMax = await provider.observedMaxHeartRate(days: 365) ?? 0
        let maxHR = max(maxHROverride ?? (220 - age), observedMax)
        let calc = HRZoneCalculator(profile: UserProfile(
            age: age,
            sex: .male,
            weightKg: 0,
            heightCm: 0,
            restingHR: resting,
            maxHROverride: maxHR,
            zoneMethod: .karvonen
        ))
        let zones = HRZone.allCases.map { calc.range(for: $0) }
        return (zones, resting, maxHR)
    }

    /// Imports recent Health workouts into `context`, deduped by health UUID, and
    /// refreshes the widget snapshot when at least one new log was created. Returns
    /// the number of newly inserted logs (0 when everything was a duplicate or empty).
    @MainActor
    @discardableResult
    func importWorkouts(into context: ModelContext) async -> Int {
        // Respect the user's "auto-import" preference (defaults on when unset).
        let autoImport = UserDefaults.standard.object(forKey: "autoImportHealth") as? Bool ?? true
        guard autoImport else { return 0 }

        let workouts = await provider.recentWorkouts(days: 30)
        guard !workouts.isEmpty else { return 0 }

        // Dedup only needs the UUID column, not fully materialized models.
        var uuidQuery = FetchDescriptor<WorkoutLog>()
        uuidQuery.propertiesToFetch = [\.healthUUID]
        let existing = (try? context.fetch(uuidQuery)) ?? []
        let existingUUIDs = Set(existing.compactMap { $0.healthUUID })
        let tombstoned = Set(((try? context.fetch(FetchDescriptor<DeletedWorkout>())) ?? []).map(\.healthUUID))

        var inserted = 0
        // Skip duplicates, user-deleted workouts, and empty (0-minute) noise.
        // Workouts carrying OUR session stamp came from the watch app, and the
        // watch already refuses to sync mis-taps — but they still land in Apple
        // Health, so without a floor the auto-import resurrects them as 1-minute
        // junk rows (observed on-device 2026-07-05). A genuinely lost session is
        // well past 5 minutes, so the safety-net import still catches those.
        for w in workouts where !existingUUIDs.contains(w.uuid) && !tombstoned.contains(w.uuid)
            && w.durationMin >= (w.type != nil ? Self.minimumOwnImportMinutes : 1) {
            let log = WorkoutLog(
                date: w.date,
                type: w.type ?? .zone2,
                durationMin: w.durationMin,
                activeEnergyKcal: w.energyKcal,
                note: "Imported from Apple Health",
                healthUUID: w.uuid,
                source: .health,
                avgHR: w.avgHR
            )
            context.insert(log)
            inserted += 1
        }

        if inserted > 0 {
            WidgetSnapshotWriter.update(context: context)
        }
        return inserted
    }
}
