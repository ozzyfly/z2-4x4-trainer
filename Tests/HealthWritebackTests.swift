import Foundation
import Testing
import SwiftData
import SharedCore
@testable import Z24x4Trainer

/// Spy `HealthProviding` that records `saveWorkout` calls, supports failure
/// injection, and serves canned workouts to `HealthStore`'s import path.
private final class SpyHealthService: HealthProviding, @unchecked Sendable {
    struct SaveFailure: Error {}

    var shouldFailSave = false
    var savedUUID = "SPY-WORKOUT-UUID"
    /// Workouts returned by `recentWorkouts`, used to simulate a Health import.
    var importableWorkouts: [HealthWorkout] = []
    private(set) var saveCalls = 0

    func requestAuthorization() async throws {}

    func workoutWriteAuthorized() async -> Bool { true }

    func saveWorkout(type: SessionType, start: Date, durationMin: Int, energyKcal: Int?) async throws -> String {
        saveCalls += 1
        if shouldFailSave { throw SaveFailure() }
        return savedUUID
    }

    func todayActiveEnergyKcal() async -> Int { 0 }
    func latestBodyMassKg() async -> Double? { nil }
    func restingHeartRate() async -> Int? { nil }
    func bodyMassSeries(days: Int) async -> [(date: Date, kg: Double)] { [] }
    func recentWorkouts(days: Int) async -> [HealthWorkout] { importableWorkouts }
    func vo2MaxSeries(days: Int) async -> [VO2MaxSample] { [] }
    func hrvSeries(days: Int) async -> [MetricSample] { [] }
    func restingHeartRateSeries(days: Int) async -> [MetricSample] { [] }
}

/// Health write-back round trip against real SwiftData: a successful save stamps
/// the workout UUID on the log, a failed save keeps the local log untouched, and
/// a subsequent Health import of the same UUID does not duplicate the log.
@MainActor
struct HealthWritebackTests {
    private func makeContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: WorkoutLog.self, ProfileRecord.self,
                                           configurations: config)
        return ModelContext(container)
    }

    private func insertManualLog(into ctx: ModelContext) -> WorkoutLog {
        let log = WorkoutLog(date: .now, type: .zone2, durationMin: 45, activeEnergyKcal: 380)
        ctx.insert(log)
        return log
    }

    private func logs(_ ctx: ModelContext) throws -> [WorkoutLog] {
        try ctx.fetch(FetchDescriptor<WorkoutLog>())
    }

    @Test("a successful Health save writes the workout UUID onto the log")
    func successWritesUUID() async throws {
        let ctx = try makeContext()
        let spy = SpyHealthService()
        let log = insertManualLog(into: ctx)

        let wroteBack = await ManualEntryView.writeBackToHealth(log, using: spy)

        #expect(wroteBack == true)
        #expect(spy.saveCalls == 1)
        #expect(log.healthUUID == "SPY-WORKOUT-UUID")
        #expect(try logs(ctx).count == 1)
    }

    @Test("an injected save failure keeps the local log with a nil healthUUID")
    func failureKeepsLocalLog() async throws {
        let ctx = try makeContext()
        let spy = SpyHealthService()
        spy.shouldFailSave = true
        let log = insertManualLog(into: ctx)

        let wroteBack = await ManualEntryView.writeBackToHealth(log, using: spy)

        #expect(wroteBack == false)
        #expect(spy.saveCalls == 1)
        let fetched = try logs(ctx)
        #expect(fetched.count == 1)
        #expect(fetched.first?.healthUUID == nil)
    }

    @Test("importing the written-back workout UUID does not duplicate the log")
    func roundTripImportDedupes() async throws {
        let ctx = try makeContext()
        let spy = SpyHealthService()
        let log = insertManualLog(into: ctx)

        let wroteBack = await ManualEntryView.writeBackToHealth(log, using: spy)
        #expect(wroteBack == true)

        // Simulate the next Health import returning the workout we just wrote.
        spy.importableWorkouts = [
            HealthWorkout(uuid: spy.savedUUID, date: log.date,
                          durationMin: log.durationMin, energyKcal: log.activeEnergyKcal)
        ]
        let store = HealthStore(provider: spy)
        await store.refresh(context: ctx)

        #expect(try logs(ctx).count == 1)

        // A genuinely new Health workout still imports.
        spy.importableWorkouts.append(
            HealthWorkout(uuid: "OTHER-UUID", date: .now, durationMin: 30, energyKcal: 250)
        )
        await store.refresh(context: ctx)
        #expect(try logs(ctx).count == 2)
    }
}
