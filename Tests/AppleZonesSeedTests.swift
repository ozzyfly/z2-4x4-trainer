import Foundation
import Testing
import SharedCore
@testable import Z24x4Trainer

@Suite("Apple zone seeding")
struct AppleZonesSeedTests {
    /// Minimal `HealthProviding` mock returning canned resting / observed-max HR.
    private final class SeedHealth: HealthProviding, @unchecked Sendable {
        var resting: Int?
        var observedMax: Int?
        init(resting: Int?, observedMax: Int?) {
            self.resting = resting
            self.observedMax = observedMax
        }
        func requestAuthorization() async throws {}
        func workoutWriteAuthorized() async -> Bool { false }
        func saveWorkout(type: SessionType, start: Date, durationMin: Int, energyKcal: Int?) async throws -> String { "" }
        func todayActiveEnergyKcal() async -> Int { 0 }
        func latestBodyMassKg() async -> Double? { nil }
        func restingHeartRate() async -> Int? { resting }
        func observedMaxHeartRate(days: Int) async -> Int? { observedMax }
        func bodyMassSeries(days: Int) async -> [(date: Date, kg: Double)] { [] }
        func recentWorkouts(days: Int) async -> [HealthWorkout] { [] }
        func vo2MaxSeries(days: Int) async -> [VO2MaxSample] { [] }
        func hrvSeries(days: Int) async -> [MetricSample] { [] }
        func restingHeartRateSeries(days: Int) async -> [MetricSample] { [] }
        func wristTemperatureSeries(days: Int) async -> [MetricSample] { [] }
        func lastNightSleepHours() async -> Double? { nil }
    }

    // MARK: appleZoneSeed

    @Test("observed max above the estimate wins, and zones use heart-rate reserve")
    @MainActor
    func observedMaxWins() async {
        let store = HealthStore(provider: SeedHealth(resting: 50, observedMax: 200))
        let seed = await store.appleZoneSeed(age: 30, maxHROverride: nil)
        let s = try! #require(seed)
        #expect(s.restingHR == 50)
        #expect(s.maxHR == 200) // max(220-30=190, observed 200)
        // Karvonen Zone 2: 50 + (0.60…0.70)·(200−50) = 140…155
        #expect(s.zones[1] == HRRange(lower: 140, upper: 155))
        #expect(s.zones.count == 5)
    }

    @Test("estimate wins when observed max is lower")
    @MainActor
    func estimateWins() async {
        let store = HealthStore(provider: SeedHealth(resting: 50, observedMax: 170))
        let seed = await store.appleZoneSeed(age: 30, maxHROverride: nil)
        #expect(seed?.maxHR == 190) // 220 − 30
    }

    @Test("no resting HR means no seed")
    @MainActor
    func noRestingNoSeed() async {
        let store = HealthStore(provider: SeedHealth(resting: nil, observedMax: 200))
        let seed = await store.appleZoneSeed(age: 30, maxHROverride: nil)
        #expect(seed == nil)
    }

    // MARK: filteredObservedMax

    @Test("filtered observed max drops spikes and implausible values")
    func filteredMax() {
        #expect(HealthKitService.filteredObservedMax([]) == nil)
        // 90 too low, 300 too high → nothing plausible.
        #expect(HealthKitService.filteredObservedMax([90, 300]) == nil)
        // 5+ values → drop top 2 as artifacts: sorted [150,160,170,180,190] → index 2.
        #expect(HealthKitService.filteredObservedMax([190, 150, 180, 160, 170]) == 170)
        // 250 filtered out; 2 left → no drop → max 185.
        #expect(HealthKitService.filteredObservedMax([180, 185, 250]) == 185)
        // 3 values → drop top 1 → 175.
        #expect(HealthKitService.filteredObservedMax([170, 175, 180]) == 175)
    }
}
