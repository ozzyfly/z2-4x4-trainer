import Foundation
import SharedCore

/// A workout summary pulled from Apple Health (source-agnostic).
struct HealthWorkout {
    let uuid: String
    let date: Date
    let durationMin: Int
    let energyKcal: Int?
}

/// Abstraction over Apple Health so the UI can be driven by a mock in previews/tests.
protocol HealthProviding: Sendable {
    /// Requests read authorization for the health types we consume.
    func requestAuthorization() async throws

    /// Active energy burned so far today, in kilocalories.
    func todayActiveEnergyKcal() async -> Int

    /// The most recent body-mass sample, in kilograms (nil if none).
    func latestBodyMassKg() async -> Double?

    /// The most recent resting heart-rate sample, in bpm (nil if none).
    func restingHeartRate() async -> Int?

    /// Daily body-mass samples over the last `days` days, oldest first.
    func bodyMassSeries(days: Int) async -> [(date: Date, kg: Double)]

    /// Workouts completed in the last `days` days.
    func recentWorkouts(days: Int) async -> [HealthWorkout]

    /// VO2max samples over the last `days` days, oldest first.
    func vo2MaxSeries(days: Int) async -> [VO2MaxSample]
}
