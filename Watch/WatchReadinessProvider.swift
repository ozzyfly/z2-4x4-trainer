import Foundation
import HealthKit
import SharedCore

/// Computes today's readiness on the watch itself, straight from HealthKit —
/// used when the phone hasn't pushed a fresh snapshot (absent or >24h old), so
/// the low-readiness guard and 4×4 rep reduction still work when the watch is
/// running independently.
struct WatchReadinessProvider: Sendable {
    private let store = HKHealthStore()

    /// A readiness score from the watch's own HRV/resting-HR history, or nil
    /// when HealthKit is unavailable or history is too thin.
    func computeScore() async -> ReadinessScore? {
        guard HKHealthStore.isHealthDataAvailable() else { return nil }
        let bpm = HKUnit.count().unitDivided(by: .minute())
        async let hrv = series(.heartRateVariabilitySDNN, unit: .secondUnit(with: .milli), days: 30)
        async let rhr = series(.restingHeartRate, unit: bpm, days: 30)
        return ReadinessCalculator.score(hrv: await hrv, restingHR: await rhr)
    }

    private func series(_ id: HKQuantityTypeIdentifier, unit: HKUnit, days: Int) async -> [MetricSample] {
        guard let type = HKQuantityType.quantityType(forIdentifier: id) else { return [] }
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
}
