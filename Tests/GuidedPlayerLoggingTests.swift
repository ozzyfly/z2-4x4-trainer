import Testing
import SwiftData
import SharedCore
@testable import Z24x4Trainer

/// Covers `GuidedSessionLogger`: a normally-completed guided session records exactly
/// one `WorkoutLog` (source `.guided`); a session ended before its prescribed duration
/// records nothing. Mirrors the in-memory harness used by `PhoneSessionReceiverTests`.
@MainActor
struct GuidedPlayerLoggingTests {
    private func makeContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: WorkoutLog.self, ProfileRecord.self, DeletedWorkout.self,
                                           configurations: config)
        return ModelContext(container)
    }

    private func logCount(_ ctx: ModelContext) -> Int {
        (try? ctx.fetch(FetchDescriptor<WorkoutLog>()))?.count ?? -1
    }

    // MARK: durationToLog decision (pure)

    @Test("a finished 4×4 logs its full structured duration")
    func fourByFourFinishedLogsTotal() {
        let mins = GuidedSessionLogger.durationToLog(
            type: .norwegian4x4, isFinished: true, elapsedSec: 0, prescribedMinutes: 0)
        #expect(mins == Norwegian4x4.totalDurationSec / 60)
    }

    @Test("an unfinished 4×4 logs nothing")
    func fourByFourUnfinishedLogsNil() {
        let mins = GuidedSessionLogger.durationToLog(
            type: .norwegian4x4, isFinished: false, elapsedSec: 20 * 60, prescribedMinutes: 0)
        #expect(mins == nil)
    }

    @Test("zone 2 at or beyond prescribed logs the elapsed minutes")
    func zone2AtOrBeyondPrescribed() {
        // exactly at the boundary
        #expect(GuidedSessionLogger.durationToLog(
            type: .zone2, isFinished: false, elapsedSec: 40 * 60, prescribedMinutes: 40) == 40)
        // beyond — logs actual elapsed
        #expect(GuidedSessionLogger.durationToLog(
            type: .zone2, isFinished: false, elapsedSec: 47 * 60, prescribedMinutes: 40) == 47)
    }

    @Test("zone 2 below prescribed logs nothing")
    func zone2BelowPrescribed() {
        #expect(GuidedSessionLogger.durationToLog(
            type: .zone2, isFinished: false, elapsedSec: 39 * 60, prescribedMinutes: 40) == nil)
    }

    @Test("rest logs nothing")
    func restLogsNil() {
        #expect(GuidedSessionLogger.durationToLog(
            type: .rest, isFinished: true, elapsedSec: 60 * 60, prescribedMinutes: 0) == nil)
    }

    // MARK: log() inserts + tags source

    @Test("completing a guided 4×4 inserts one guided WorkoutLog")
    func completing4x4InsertsOne() throws {
        let ctx = try makeContext()
        let logger = GuidedSessionLogger(context: ctx)
        let did = logger.log(type: .norwegian4x4, isFinished: true,
                             elapsedSec: 0, prescribedMinutes: 0)
        #expect(did == true)
        let logs = try ctx.fetch(FetchDescriptor<WorkoutLog>())
        #expect(logs.count == 1)
        #expect(logs.first?.type == .norwegian4x4)
        #expect(logs.first?.durationMin == Norwegian4x4.totalDurationSec / 60)
        #expect(logs.first?.source == .guided)
    }

    @Test("completing a guided zone 2 inserts one guided WorkoutLog with elapsed minutes")
    func completingZone2InsertsOne() throws {
        let ctx = try makeContext()
        let logger = GuidedSessionLogger(context: ctx)
        let did = logger.log(type: .zone2, isFinished: false,
                             elapsedSec: 42 * 60, prescribedMinutes: 40)
        #expect(did == true)
        let logs = try ctx.fetch(FetchDescriptor<WorkoutLog>())
        #expect(logs.count == 1)
        #expect(logs.first?.type == .zone2)
        #expect(logs.first?.durationMin == 42)
        #expect(logs.first?.source == .guided)
    }

    @Test("logWorkout returns the created log for feedback")
    func logWorkoutReturnsCreatedLog() throws {
        let ctx = try makeContext()
        let logger = GuidedSessionLogger(context: ctx)
        let log = try #require(logger.logWorkout(type: .zone2, isFinished: false,
                                                 elapsedSec: 42 * 60, prescribedMinutes: 40))
        log.note = "Felt: Good"
        let logs = try ctx.fetch(FetchDescriptor<WorkoutLog>())
        #expect(logs.count == 1)
        #expect(logs.first?.note == "Felt: Good")
    }

    @Test("cancelling a guided zone 2 before prescribed inserts nothing")
    func cancellingZone2InsertsNothing() throws {
        let ctx = try makeContext()
        let logger = GuidedSessionLogger(context: ctx)
        let did = logger.log(type: .zone2, isFinished: false,
                             elapsedSec: 10 * 60, prescribedMinutes: 40)
        #expect(did == false)
        #expect(logCount(ctx) == 0)
    }

    @Test("cancelling a guided 4×4 before completion inserts nothing")
    func cancelling4x4InsertsNothing() throws {
        let ctx = try makeContext()
        let logger = GuidedSessionLogger(context: ctx)
        let did = logger.log(type: .norwegian4x4, isFinished: false,
                             elapsedSec: 15 * 60, prescribedMinutes: 0)
        #expect(did == false)
        #expect(logCount(ctx) == 0)
    }
}
