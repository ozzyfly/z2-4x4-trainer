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

    @Test("v2 fields round-trip through encode and decode")
    func roundTripV2() throws {
        let original = WidgetSnapshot(
            todayType: .norwegian4x4,
            todayMinutes: 30,
            weekDoneMinutes: 95,
            weekTargetMinutes: 180,
            hardDone: 1,
            hardTarget: 2,
            generatedAt: Date(timeIntervalSince1970: 1_700_000_000),
            readinessValue: 82,
            readinessLabel: .goHard,
            streakWeeks: 3
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(WidgetSnapshot.self, from: data)
        #expect(decoded == original)
        #expect(decoded.readinessValue == 82)
        #expect(decoded.readinessLabel == .goHard)
        #expect(decoded.streakWeeks == 3)
    }

    @Test("legacy JSON without v2 keys decodes with nil new fields")
    func legacyJSONDecodes() throws {
        let legacy = """
        {
            "todayType": "norwegian4x4",
            "todayMinutes": 30,
            "weekDoneMinutes": 95,
            "weekTargetMinutes": 180,
            "hardDone": 1,
            "hardTarget": 2,
            "generatedAt": 1700000000
        }
        """
        let decoded = try JSONDecoder().decode(WidgetSnapshot.self, from: Data(legacy.utf8))
        #expect(decoded.todayType == .norwegian4x4)
        #expect(decoded.weekDoneMinutes == 95)
        #expect(decoded.readinessValue == nil)
        #expect(decoded.readinessLabel == nil)
        #expect(decoded.streakWeeks == nil)
    }

    @Test("placeholder has nil v2 fields")
    func placeholderV2Fields() {
        let p = WidgetSnapshot.placeholder
        #expect(p.readinessValue == nil)
        #expect(p.readinessLabel == nil)
        #expect(p.streakWeeks == nil)
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
