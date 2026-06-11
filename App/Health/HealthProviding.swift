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
    /// Requests read authorization for the health types we consume, plus share
    /// authorization for the workout samples we write back.
    func requestAuthorization() async throws

    /// Whether the app currently holds share authorization to save workouts.
    func workoutWriteAuthorized() async -> Bool

    /// Saves a completed workout to Apple Health and returns the HKWorkout UUID
    /// string, so the local log can be stamped for import deduplication.
    func saveWorkout(type: SessionType, start: Date, durationMin: Int, energyKcal: Int?) async throws -> String

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

    /// Heart-rate variability (SDNN, ms) samples over the last `days` days, oldest first.
    func hrvSeries(days: Int) async -> [MetricSample]

    /// Resting heart-rate (bpm) samples over the last `days` days, oldest first.
    func restingHeartRateSeries(days: Int) async -> [MetricSample]
}
