import Foundation
import Testing
@testable import SharedCore

@Suite("Widget snapshot")
struct WidgetSnapshotTests {
    @Test("encode then decode round-trips")
    func roundTrip() throws {
        let original = WidgetSnapshot(
            todayType: .norwegian4x4,
            todayMinutes: 30,
            weekDoneMinutes: 95,
            weekTargetMinutes: 180,
            hardDone: 1,
            hardTarget: 2,
            generatedAt: Date(timeIntervalSince1970: 1_700_000_000)
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(WidgetSnapshot.self, from: data)
        #expect(decoded == original)
    }

    @Test("week fraction clamps to 0...1")
    func weekFraction() {
        let over = WidgetSnapshot(
            todayType: .zone2, todayMinutes: 40,
            weekDoneMinutes: 200, weekTargetMinutes: 180,
            hardDone: 2, hardTarget: 2, generatedAt: .now
        )
        #expect(over.weekFraction == 1)

        let zeroTarget = WidgetSnapshot(
            todayType: .rest, todayMinutes: 0,
            weekDoneMinutes: 0, weekTargetMinutes: 0,
            hardDone: 0, hardTarget: 0, generatedAt: .now
        )
        #expect(zeroTarget.weekFraction == 0)
    }
}
