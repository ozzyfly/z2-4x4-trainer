import Foundation
import SharedCore

/// Canned `HealthProviding` for SwiftUI previews and tests — no HealthKit access.
struct PreviewHealthService: HealthProviding {
    func requestAuthorization() async throws {}

    func todayActiveEnergyKcal() async -> Int { 420 }

    func latestBodyMassKg() async -> Double? { 79.4 }

    func restingHeartRate() async -> Int? { 54 }

    func bodyMassSeries(days: Int) async -> [(date: Date, kg: Double)] {
        let cal = Calendar.current
        let weights: [Double] = [80.6, 80.2, 80.1, 79.8, 79.5, 79.6, 79.4]
        return weights.enumerated().compactMap { offset, kg in
            guard let date = cal.date(byAdding: .day, value: -(weights.count - 1 - offset), to: .now) else {
                return nil
            }
            return (date, kg)
        }
    }

    func recentWorkouts(days: Int) async -> [HealthWorkout] {
        let cal = Calendar.current
        return [
            HealthWorkout(
                uuid: "preview-1",
                date: cal.date(byAdding: .day, value: -1, to: .now) ?? .now,
                durationMin: 40,
                energyKcal: 360
            ),
            HealthWorkout(
                uuid: "preview-2",
                date: cal.date(byAdding: .day, value: -3, to: .now) ?? .now,
                durationMin: 28,
                energyKcal: 300
            )
        ]
    }

    func vo2MaxSeries(days: Int) async -> [VO2MaxSample] {
        let cal = Calendar.current
        let values: [Double] = [41.2, 42.0, 42.8, 43.5, 44.1, 45.0]
        return values.enumerated().compactMap { offset, value in
            let weeksAgo = values.count - 1 - offset
            guard let date = cal.date(byAdding: .weekOfYear, value: -weeksAgo * 4, to: .now) else {
                return nil
            }
            return VO2MaxSample(date: date, value: value)
        }
    }
}
