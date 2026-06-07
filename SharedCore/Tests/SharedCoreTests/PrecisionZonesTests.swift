import Foundation
import Testing
@testable import SharedCore

@Suite("Precision zones")
struct PrecisionZonesTests {
    private func profile(
        method: ZoneMethod,
        restingHR: Int? = nil,
        customZones: [HRRange]? = nil,
        maxHROverride: Int? = 190
    ) -> UserProfile {
        UserProfile(
            age: 30,
            sex: .male,
            weightKg: 80,
            heightCm: 180,
            restingHR: restingHR,
            maxHROverride: maxHROverride,
            zoneMethod: method,
            customZones: customZones
        )
    }

    @Test("Karvonen uses heart-rate reserve")
    func karvonenReserve() {
        let c = HRZoneCalculator(profile: profile(method: .karvonen, restingHR: 50))
        // reserve = 140; lower = 50 + 0.60·140 = 134; upper = 50 + 0.70·140 = 148
        #expect(c.zone2 == HRRange(lower: 134, upper: 148))
    }

    @Test("Age-max default unchanged: Zone 2 is 114–133 at maxHR 190")
    func ageMaxUnchanged() {
        let c = HRZoneCalculator(profile: profile(method: .ageMax))
        #expect(c.zone2 == HRRange(lower: 114, upper: 133))
    }

    @Test("Custom bands honored")
    func customHonored() {
        let custom = [
            HRRange(lower: 100, upper: 120), // zone1
            HRRange(lower: 120, upper: 140), // zone2
            HRRange(lower: 140, upper: 160), // zone3
            HRRange(lower: 160, upper: 175), // zone4
            HRRange(lower: 175, upper: 190), // zone5
        ]
        let c = HRZoneCalculator(profile: profile(method: .custom, customZones: custom))
        #expect(c.zone2 == HRRange(lower: 120, upper: 140))
    }

    @Test("Karvonen with nil resting HR falls back to age-max")
    func karvonenFallsBackWhenRestingNil() {
        let karvonen = HRZoneCalculator(profile: profile(method: .karvonen, restingHR: nil))
        let ageMax = HRZoneCalculator(profile: profile(method: .ageMax))
        #expect(karvonen.zone2 == ageMax.zone2)
        #expect(karvonen.zone2 == HRRange(lower: 114, upper: 133))
    }

    @Test("Custom with missing band falls back to age-max")
    func customFallsBackWhenMissing() {
        let c = HRZoneCalculator(profile: profile(method: .custom, customZones: nil))
        #expect(c.zone2 == HRRange(lower: 114, upper: 133))
    }

    @Test("HRRange round-trips through Codable")
    func hrRangeCodable() throws {
        let range = HRRange(lower: 120, upper: 140)
        let data = try JSONEncoder().encode(range)
        let decoded = try JSONDecoder().decode(HRRange.self, from: data)
        #expect(decoded == range)
    }

    @Test("Profile persisted before precision-zones still decodes")
    func legacyProfileDecodes() throws {
        // Encode a current profile, then drop the new keys to simulate legacy JSON.
        let current = UserProfile(age: 30, sex: .male, weightKg: 80, heightCm: 180)
        let data = try JSONEncoder().encode(current)
        var dict = try #require(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )
        dict.removeValue(forKey: "zoneMethod")
        dict.removeValue(forKey: "customZones")
        let legacy = try JSONSerialization.data(withJSONObject: dict)

        let p = try JSONDecoder().decode(UserProfile.self, from: legacy)
        #expect(p.zoneMethod == .ageMax)
        #expect(p.customZones == nil)
    }
}
