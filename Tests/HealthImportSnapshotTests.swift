import Foundation
import Testing
import SwiftData
import SharedCore
@testable import Z24x4Trainer

/// Covers the widget-snapshot refresh after an Apple Health import:
/// `HealthStore.importWorkouts` reports how many new `WorkoutLog`s it inserted, so the
/// caller refreshes the snapshot only when the import actually changed the store.
/// An import of only-duplicate (or empty) workouts inserts nothing and triggers no refresh.
@MainActor
struct HealthImportSnapshotTests {
    private final class Spy: HealthProviding, @unchecked Sendable {
        var importableWorkouts: [HealthWorkout] = []
        func requestAuthorization() async throws {}
        func workoutWriteAuthorized() async -> Bool { true }
        func saveWorkout(type: SessionType, start: Date, durationMin: Int, energyKcal: Int?) async throws -> String { "X" }
        func todayActiveEnergyKcal() async -> Int { 0 }
        func latestBodyMassKg() async -> Double? { nil }
        func restingHeartRate() async -> Int? { nil }
        func bodyMassSeries(days: Int) async -> [(date: Date, kg: Double)] { [] }
        func recentWorkouts(days: Int) async -> [HealthWorkout] { importableWorkouts }
        func vo2MaxSeries(days: Int) async -> [VO2MaxSample] { [] }
        func hrvSeries(days: Int) async -> [MetricSample] { [] }
        func restingHeartRateSeries(days: Int) async -> [MetricSample] { [] }
    }

    private func makeContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: WorkoutLog.self, ProfileRecord.self,
                                           configurations: config)
        return ModelContext(container)
    }

    @Test("importing a new Health workout reports one insertion")
    func newWorkoutReportsInsertion() async throws {
        let ctx = try makeContext()
        let spy = Spy()
        spy.importableWorkouts = [HealthWorkout(uuid: "H-1", date: .now, durationMin: 40, energyKcal: 300)]
        let store = HealthStore(provider: spy)

        let inserted = await store.importWorkouts(into: ctx)

        #expect(inserted == 1)
        #expect(try ctx.fetch(FetchDescriptor<WorkoutLog>()).count == 1)
    }

    @Test("re-importing the same Health workout reports no insertion")
    func duplicateReportsNoInsertion() async throws {
        let ctx = try makeContext()
        let spy = Spy()
        spy.importableWorkouts = [HealthWorkout(uuid: "H-1", date: .now, durationMin: 40, energyKcal: 300)]
        let store = HealthStore(provider: spy)

        let first = await store.importWorkouts(into: ctx)
        #expect(first == 1)

        let second = await store.importWorkouts(into: ctx)
        #expect(second == 0)
        #expect(try ctx.fetch(FetchDescriptor<WorkoutLog>()).count == 1)
    }

    @Test("an empty import reports no insertion")
    func emptyReportsNoInsertion() async throws {
        let ctx = try makeContext()
        let store = HealthStore(provider: Spy())
        let inserted = await store.importWorkouts(into: ctx)
        #expect(inserted == 0)
    }
}
