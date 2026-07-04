import Testing
@testable import SharedCore

@Suite("Zone ladder validation")
struct ZoneLadderTests {
    @Test("an ascending, ordered ladder is valid")
    func ascendingIsValid() {
        let zones = [
            HRRange(lower: 100, upper: 120),
            HRRange(lower: 120, upper: 140),
            HRRange(lower: 140, upper: 160),
            HRRange(lower: 160, upper: 175),
            HRRange(lower: 175, upper: 190),
        ]
        #expect(zones.isAscendingZoneLadder)
    }

    @Test("out-of-order bands are flagged and the fix restores order")
    func disorderDetectedAndFixed() {
        let zones = [
            HRRange(lower: 140, upper: 160), // z1 (wrong)
            HRRange(lower: 100, upper: 120), // z2
            HRRange(lower: 175, upper: 190), // z3
            HRRange(lower: 160, upper: 175), // z4
            HRRange(lower: 120, upper: 140), // z5
        ]
        #expect(!zones.isAscendingZoneLadder)

        let fixed = zones.sortedAscendingLadder()
        #expect(fixed.isAscendingZoneLadder)
        #expect(fixed.map(\.lower) == [100, 120, 140, 160, 175])
    }

    @Test("a band whose upper dips below the previous is raised to stay monotonic")
    func uppersForcedMonotonic() {
        let zones = [
            HRRange(lower: 100, upper: 150),
            HRRange(lower: 120, upper: 130), // upper dips below previous
        ]
        let fixed = zones.sortedAscendingLadder()
        #expect(fixed.isAscendingZoneLadder)
        #expect(fixed[1].upper >= fixed[0].upper)
    }
}
