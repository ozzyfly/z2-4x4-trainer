import Testing
@testable import SharedCore

@Suite("HR zones")
struct HRZoneCalculatorTests {
    @Test("maxHR defaults to 220 − age")
    func ageBasedMaxHR() {
        let p = UserProfile(age: 30, sex: .male, weightKg: 80, heightCm: 180)
        #expect(HRZoneCalculator(profile: p).maxHR == 190)
    }

    @Test("maxHR override wins over age estimate")
    func overrideMaxHR() {
        let p = UserProfile(age: 30, sex: .male, weightKg: 80, heightCm: 180, maxHROverride: 200)
        #expect(HRZoneCalculator(profile: p).maxHR == 200)
    }

    @Test("Zone 2 band is 60–70% of maxHR")
    func zone2Band() {
        let c = HRZoneCalculator(maxHR: 200)
        #expect(c.zone2 == HRRange(lower: 120, upper: 140))
    }

    @Test("4×4 hard band is 85–95% of maxHR")
    func hardBand() {
        let c = HRZoneCalculator(maxHR: 200)
        #expect(c.fourByFourHard == HRRange(lower: 170, upper: 190))
    }

    @Test("classifies live HR into the right zone")
    func classifyBPM() {
        let c = HRZoneCalculator(maxHR: 200)
        #expect(c.zone(forBPM: 95) == nil)        // below zone 1 (lower 100)
        #expect(c.zone(forBPM: 100) == .zone1)
        #expect(c.zone(forBPM: 130) == .zone2)
        #expect(c.zone(forBPM: 145) == .zone3)
        #expect(c.zone(forBPM: 185) == .zone5)
    }
}
