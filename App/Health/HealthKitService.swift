import Foundation
import HealthKit
import SharedCore

/// Concrete `HealthProviding` backed by HealthKit. Reads metrics and writes
/// back manually logged workouts (workout sample + active energy).
final class HealthKitService: HealthProviding, @unchecked Sendable {
    /// Why a Health write could not be performed.
    enum WriteError: Error {
        case healthDataUnavailable
        case finishFailed
    }

    private let store = HKHealthStore()

    private var readTypes: Set<HKObjectType> {
        var types = Set<HKObjectType>()
        if let energy = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
            types.insert(energy)
        }
        if let resting = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) {
            types.insert(resting)
        }
        if let mass = HKQuantityType.quantityType(forIdentifier: .bodyMass) {
            types.insert(mass)
        }
        if let hr = HKQuantityType.quantityType(forIdentifier: .heartRate) {
            types.insert(hr)
        }
        if let vo2 = HKQuantityType.quantityType(forIdentifier: .vo2Max) {
            types.insert(vo2)
        }
        if let hrv = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) {
            types.insert(hrv)
        }
        types.insert(HKObjectType.workoutType())
        return types
    }

    private var shareTypes: Set<HKSampleType> {
        var types = Set<HKSampleType>()
        types.insert(HKObjectType.workoutType())
        if let energy = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
            types.insert(energy)
        }
        return types
    }

    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        try await store.requestAuthorization(toShare: shareTypes, read: readTypes)
    }

    func workoutWriteAuthorized() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else { return false }
        return store.authorizationStatus(for: HKObjectType.workoutType()) == .sharingAuthorized
    }

    /// Builds and finishes an `HKWorkout` covering `start ..< start + duration`,
    /// attaching an active-energy sample when provided. Uses `.running`, matching
    /// how watch sessions are recorded; imports dedupe purely on the returned UUID.
    func saveWorkout(type: SessionType, start: Date, durationMin: Int, energyKcal: Int?) async throws -> String {
        guard HKHealthStore.isHealthDataAvailable() else { throw WriteError.healthDataUnavailable }

        let end = start.addingTimeInterval(TimeInterval(durationMin) * 60)
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .running

        let builder = HKWorkoutBuilder(healthStore: store, configuration: configuration, device: .local())
        try await builder.beginCollection(at: start)

        if let kcal = energyKcal, kcal > 0,
           let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
            let sample = HKQuantitySample(
                type: energyType,
                quantity: HKQuantity(unit: .kilocalorie(), doubleValue: Double(kcal)),
                start: start,
                end: end
            )
            try await builder.addSamples([sample])
        }

        // Stamp the session kind so a re-import from Health recovers the right type.
        try await builder.addMetadata([WorkoutMetadata.sessionTypeKey: type.rawValue])

        try await builder.endCollection(at: end)
        guard let workout = try await builder.finishWorkout() else { throw WriteError.finishFailed }
        return workout.uuid.uuidString
    }

    func todayActiveEnergyKcal() async -> Int {
        guard HKHealthStore.isHealthDataAvailable(),
              let type = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            return 0
        }
        let start = Calendar.current.startOfDay(for: .now)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: .now)
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, stats, _ in
                let kcal = stats?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                continuation.resume(returning: Int(kcal.rounded()))
            }
            store.execute(query)
        }
    }

    func latestBodyMassKg() async -> Double? {
        guard let type = HKQuantityType.quantityType(forIdentifier: .bodyMass) else { return nil }
        return await latestQuantity(of: type, unit: .gramUnit(with: .kilo))
    }

    func restingHeartRate() async -> Int? {
        guard let type = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else { return nil }
        let unit = HKUnit.count().unitDivided(by: .minute())
        guard let bpm = await latestQuantity(of: type, unit: unit) else { return nil }
        return Int(bpm.rounded())
    }

    func observedMaxHeartRate(days: Int) async -> Int? {
        guard HKHealthStore.isHealthDataAvailable(),
              let type = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return nil }
        let unit = HKUnit.count().unitDivided(by: .minute())
        let cal = Calendar.current
        let start = cal.startOfDay(for: cal.date(byAdding: .day, value: -days, to: .now) ?? .now)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: .now)

        // Per-day maxima rather than one global max, so a single bogus spike on one
        // day doesn't define the ceiling.
        let dailyMaxes: [Int] = await withCheckedContinuation { continuation in
            let query = HKStatisticsCollectionQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .discreteMax,
                anchorDate: start,
                intervalComponents: DateComponents(day: 1)
            )
            query.initialResultsHandler = { _, collection, _ in
                var values: [Int] = []
                collection?.enumerateStatistics(from: start, to: .now) { stats, _ in
                    if let bpm = stats.maximumQuantity()?.doubleValue(for: unit) {
                        values.append(Int(bpm.rounded()))
                    }
                }
                continuation.resume(returning: values)
            }
            store.execute(query)
        }

        return Self.filteredObservedMax(dailyMaxes)
    }

    /// Picks a robust "observed max" from per-day maxima: keep only physiologically
    /// plausible values, drop the top spike(s) as likely artifacts, and return the
    /// highest remaining. A genuine max recurs across days, so it survives the trim.
    static func filteredObservedMax(_ dailyMaxes: [Int]) -> Int? {
        let plausible = dailyMaxes.filter { (100...215).contains($0) }.sorted()
        guard !plausible.isEmpty else { return nil }
        // Drop up to the top 2 days as potential one-off artifacts when we have enough data.
        let dropTop = plausible.count >= 5 ? 2 : (plausible.count >= 3 ? 1 : 0)
        return plausible[plausible.count - 1 - dropTop]
    }

    func bodyMassSeries(days: Int) async -> [(date: Date, kg: Double)] {
        guard HKHealthStore.isHealthDataAvailable(),
              let type = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
            return []
        }
        let start = Calendar.current.date(byAdding: .day, value: -days, to: .now) ?? .now
        let predicate = HKQuery.predicateForSamples(withStart: start, end: .now)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sort]
            ) { _, samples, _ in
                let series: [(date: Date, kg: Double)] = (samples as? [HKQuantitySample] ?? []).map {
                    ($0.startDate, $0.quantity.doubleValue(for: .gramUnit(with: .kilo)))
                }
                continuation.resume(returning: series)
            }
            store.execute(query)
        }
    }

    func recentWorkouts(days: Int) async -> [HealthWorkout] {
        guard HKHealthStore.isHealthDataAvailable() else { return [] }
        let start = Calendar.current.date(byAdding: .day, value: -days, to: .now) ?? .now
        let predicate = HKQuery.predicateForSamples(withStart: start, end: .now)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: .workoutType(),
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sort]
            ) { _, samples, _ in
                let bpmUnit = HKUnit.count().unitDivided(by: .minute())
                let workouts: [HealthWorkout] = (samples as? [HKWorkout] ?? []).map { w in
                    let kcal = w.statistics(for: HKQuantityType(.activeEnergyBurned))?
                        .sumQuantity()?.doubleValue(for: .kilocalorie())
                    let avgHR = w.statistics(for: HKQuantityType(.heartRate))?
                        .averageQuantity()?.doubleValue(for: bpmUnit)
                    let stampedType = (w.metadata?[WorkoutMetadata.sessionTypeKey] as? String)
                        .flatMap(SessionType.init(rawValue:))
                    return HealthWorkout(
                        uuid: w.uuid.uuidString,
                        date: w.startDate,
                        durationMin: Int((w.duration / 60).rounded()),
                        energyKcal: kcal.map { Int($0.rounded()) },
                        type: stampedType,
                        avgHR: avgHR.map { Int($0.rounded()) }
                    )
                }
                continuation.resume(returning: workouts)
            }
            store.execute(query)
        }
    }

    func vo2MaxSeries(days: Int) async -> [VO2MaxSample] {
        guard HKHealthStore.isHealthDataAvailable(),
              let type = HKQuantityType.quantityType(forIdentifier: .vo2Max) else {
            return []
        }
        let unit = HKUnit(from: "ml/kg*min")
        let start = Calendar.current.date(byAdding: .day, value: -days, to: .now) ?? .now
        let predicate = HKQuery.predicateForSamples(withStart: start, end: .now)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sort]
            ) { _, samples, _ in
                let series: [VO2MaxSample] = (samples as? [HKQuantitySample] ?? []).map {
                    VO2MaxSample(date: $0.startDate, value: $0.quantity.doubleValue(for: unit))
                }
                continuation.resume(returning: series)
            }
            store.execute(query)
        }
    }

    func hrvSeries(days: Int) async -> [MetricSample] {
        guard let type = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            return []
        }
        return await metricSeries(of: type, unit: .secondUnit(with: .milli), days: days)
    }

    func restingHeartRateSeries(days: Int) async -> [MetricSample] {
        guard let type = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
            return []
        }
        let unit = HKUnit.count().unitDivided(by: .minute())
        return await metricSeries(of: type, unit: unit, days: days)
    }

    // MARK: - Helpers

    private func metricSeries(of type: HKQuantityType, unit: HKUnit, days: Int) async -> [MetricSample] {
        guard HKHealthStore.isHealthDataAvailable() else { return [] }
        let start = Calendar.current.date(byAdding: .day, value: -days, to: .now) ?? .now
        let predicate = HKQuery.predicateForSamples(withStart: start, end: .now)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sort]
            ) { _, samples, _ in
                let series: [MetricSample] = (samples as? [HKQuantitySample] ?? []).map {
                    MetricSample(date: $0.startDate, value: $0.quantity.doubleValue(for: unit))
                }
                continuation.resume(returning: series)
            }
            store.execute(query)
        }
    }

    private func latestQuantity(of type: HKQuantityType, unit: HKUnit) async -> Double? {
        guard HKHealthStore.isHealthDataAvailable() else { return nil }
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sort]
            ) { _, samples, _ in
                let value = (samples?.first as? HKQuantitySample)?.quantity.doubleValue(for: unit)
                continuation.resume(returning: value)
            }
            store.execute(query)
        }
    }
}
