import Foundation
import HealthKit
import SharedCore

/// Concrete `HealthProviding` backed by HealthKit. Reads only — never writes.
final class HealthKitService: HealthProviding, @unchecked Sendable {
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

    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        try await store.requestAuthorization(toShare: [], read: readTypes)
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
                let workouts: [HealthWorkout] = (samples as? [HKWorkout] ?? []).map { w in
                    let kcal = w.statistics(for: HKQuantityType(.activeEnergyBurned))?
                        .sumQuantity()?.doubleValue(for: .kilocalorie())
                    return HealthWorkout(
                        uuid: w.uuid.uuidString,
                        date: w.startDate,
                        durationMin: Int((w.duration / 60).rounded()),
                        energyKcal: kcal.map { Int($0.rounded()) }
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
