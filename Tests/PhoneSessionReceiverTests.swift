import Testing
import SwiftData
import SharedCore
@testable import Z24x4Trainer

/// End-to-end check of the phone-side WatchConnectivity receiver against real SwiftData:
/// a transfer inserts one `WorkoutLog`, and a duplicate (same `healthUUID`) is ignored.
@MainActor
struct PhoneSessionReceiverTests {
    private func makeContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: WorkoutLog.self, ProfileRecord.self,
                                           configurations: config)
        return ModelContext(container)
    }

    private func transfer(uuid: String) -> WorkoutTransfer {
        WorkoutTransfer(healthUUID: uuid, date: .now, type: .norwegian4x4,
                        durationMin: 43, energyKcal: 320)
    }

    private func logCount(_ ctx: ModelContext) -> Int {
        (try? ctx.fetch(FetchDescriptor<WorkoutLog>()))?.count ?? -1
    }

    @Test("a transfer inserts one WorkoutLog with mapped fields")
    func insertsOnce() throws {
        let ctx = try makeContext()
        let receiver = PhoneSessionReceiver(context: ctx)
        #expect(receiver.ingest(transfer(uuid: "ABC-1")) == true)
        let logs = try ctx.fetch(FetchDescriptor<WorkoutLog>())
        #expect(logs.count == 1)
        #expect(logs.first?.healthUUID == "ABC-1")
        #expect(logs.first?.type == .norwegian4x4)
        #expect(logs.first?.durationMin == 43)
    }

    @Test("a duplicate healthUUID is not inserted twice")
    func dedupes() throws {
        let ctx = try makeContext()
        let receiver = PhoneSessionReceiver(context: ctx)
        #expect(receiver.ingest(transfer(uuid: "DUP")) == true)
        #expect(receiver.ingest(transfer(uuid: "DUP")) == false)
        #expect(logCount(ctx) == 1)
    }

    @Test("different healthUUIDs both insert")
    func distinctInsert() throws {
        let ctx = try makeContext()
        let receiver = PhoneSessionReceiver(context: ctx)
        _ = receiver.ingest(transfer(uuid: "A"))
        _ = receiver.ingest(transfer(uuid: "B"))
        #expect(logCount(ctx) == 2)
    }
}
