import Testing
import SwiftData
import SharedCore
@testable import Z24x4Trainer

/// Covers the `WorkoutSource` field added so History can distinguish manual,
/// Health-imported, and watch-synced logs (and the export `source` column).
/// The SwiftData default must stay `.manual` so pre-existing records migrate safely.
@MainActor
struct WorkoutSourceTests {
    private func makeContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: WorkoutLog.self, ProfileRecord.self,
                                           configurations: config)
        return ModelContext(container)
    }

    @Test("a log defaults to the manual source")
    func defaultsToManual() {
        let log = WorkoutLog(type: .zone2, durationMin: 40)
        #expect(log.source == .manual)
    }

    @Test("source survives a SwiftData round-trip")
    func roundTrips() throws {
        let ctx = try makeContext()
        ctx.insert(WorkoutLog(type: .zone2, durationMin: 40, source: .health))
        let fetched = try ctx.fetch(FetchDescriptor<WorkoutLog>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.source == .health)
    }

    @Test("an unknown stored raw value falls back to manual")
    func unknownRawFallsBack() throws {
        let ctx = try makeContext()
        let log = WorkoutLog(type: .zone2, durationMin: 40)
        log.sourceRaw = "bogus"
        ctx.insert(log)
        let fetched = try ctx.fetch(FetchDescriptor<WorkoutLog>())
        #expect(fetched.first?.source == .manual)
    }

    @Test("a watch transfer is tagged as the watch source")
    func watchTransferTaggedWatch() throws {
        let ctx = try makeContext()
        let receiver = PhoneSessionReceiver(context: ctx)
        _ = receiver.ingest(WorkoutTransfer(healthUUID: "W-1", date: .now,
                                            type: .norwegian4x4, durationMin: 30, energyKcal: 300))
        let logs = try ctx.fetch(FetchDescriptor<WorkoutLog>())
        #expect(logs.first?.source == .watch)
    }

    @Test("raw values are stable for the export column")
    func rawValuesStable() {
        #expect(WorkoutSource.manual.rawValue == "manual")
        #expect(WorkoutSource.health.rawValue == "health")
        #expect(WorkoutSource.watch.rawValue == "watch")
    }
}
