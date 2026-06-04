import Foundation
import Testing
@testable import SharedCore

@Suite("Workout transfer")
struct WorkoutTransferTests {
    private func sample(uuid: String = "ABC-123", energy: Int? = 320) -> WorkoutTransfer {
        WorkoutTransfer(healthUUID: uuid, date: Date(timeIntervalSince1970: 1_700_000_000),
                        type: .norwegian4x4, durationMin: 43, energyKcal: energy)
    }

    @Test("userInfo round-trips")
    func roundTrip() {
        let t = sample()
        let back = WorkoutTransfer(userInfo: t.toUserInfo())
        #expect(back == t)
    }

    @Test("userInfo round-trips with nil energy")
    func roundTripNilEnergy() {
        let t = sample(energy: nil)
        let dict = t.toUserInfo()
        #expect(dict["energyKcal"] == nil)
        #expect(WorkoutTransfer(userInfo: dict) == t)
    }

    @Test("malformed userInfo decodes to nil")
    func malformed() {
        #expect(WorkoutTransfer(userInfo: ["healthUUID": "x"]) == nil)
    }

    @Test("dedupe: insert only unseen UUIDs")
    func dedupe() {
        let t = sample(uuid: "ABC-123")
        #expect(WorkoutSyncDedupe.shouldInsert(t, existingHealthUUIDs: []) == true)
        #expect(WorkoutSyncDedupe.shouldInsert(t, existingHealthUUIDs: ["ABC-123"]) == false)
        #expect(WorkoutSyncDedupe.shouldInsert(t, existingHealthUUIDs: ["OTHER"]) == true)
    }
}
