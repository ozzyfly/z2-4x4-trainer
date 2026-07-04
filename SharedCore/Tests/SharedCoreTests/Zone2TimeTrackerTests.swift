import Testing
@testable import SharedCore

@Suite("Zone 2 time tracker")
struct Zone2TimeTrackerTests {
    @Test("credits a second only inside the Zone 2 band")
    func countsInBandOnly() {
        var t = Zone2TimeTracker(lowerBound: 120, upperBound: 140)

        // Inside the band counts.
        t.tick(heartRate: 130)
        t.tick(heartRate: 125)
        #expect(t.inZoneSeconds == 2)
        #expect(t.isCounting)

        // Drop to Zone 1 → pause.
        t.tick(heartRate: 110)
        #expect(t.inZoneSeconds == 2)
        #expect(!t.isCounting)

        // Push into Zone 3+ (above upper) → also pause.
        t.tick(heartRate: 150)
        #expect(t.inZoneSeconds == 2)
        #expect(!t.isCounting)

        // Both bounds are inclusive.
        t.tick(heartRate: 120)
        t.tick(heartRate: 140)
        #expect(t.inZoneSeconds == 4)
        #expect(t.isCounting)
    }

    @Test("no heart rate does not accrue time (within the grace window)")
    func noHRNoCount() {
        var t = Zone2TimeTracker(lowerBound: 120, upperBound: 140)
        t.tick(heartRate: 0)
        t.tick(heartRate: 0)
        #expect(t.inZoneSeconds == 0)
        #expect(t.totalSeconds == 2)
        #expect(!t.isCounting)
        #expect(!t.isBlind)
    }

    @Test("prolonged HR loss goes blind and credits wall-clock time")
    func blindFallback() {
        var t = Zone2TimeTracker(lowerBound: 120, upperBound: 140, noHRGraceSec: 15)
        // Working in zone, then the sensor dies.
        t.tick(heartRate: 130)
        for _ in 0..<14 { t.tick(heartRate: 0) }
        #expect(!t.isBlind)
        #expect(t.inZoneSeconds == 1) // grace window banked nothing extra

        t.tick(heartRate: 0) // 15th consecutive miss → blind
        #expect(t.isBlind)
        #expect(t.isCounting)
        #expect(t.inZoneSeconds == 2)

        // Blind seconds keep crediting, but never touch the HR average.
        for _ in 0..<10 { t.tick(heartRate: 0) }
        #expect(t.inZoneSeconds == 12)
        #expect(t.avgInZoneHR == 130)
    }

    @Test("heart rate returning ends blind fallback and resumes band gating")
    func blindRecovery() {
        var t = Zone2TimeTracker(lowerBound: 120, upperBound: 140, noHRGraceSec: 5)
        for _ in 0..<6 { t.tick(heartRate: 0) }
        #expect(t.isBlind)

        // A reading comes back *below* the band → no longer blind, back to gating.
        t.tick(heartRate: 100)
        #expect(!t.isBlind)
        #expect(!t.isCounting)

        t.tick(heartRate: 125)
        #expect(t.isCounting)
    }

    @Test("tracks average in-zone HR, total time, and in-zone percentage")
    func avgAndPercent() {
        var t = Zone2TimeTracker(lowerBound: 120, upperBound: 140)
        t.tick(heartRate: 130) // in zone
        t.tick(heartRate: 140) // in zone
        t.tick(heartRate: 100) // below → out, but still counts toward total
        t.tick(heartRate: 160) // above → out
        #expect(t.inZoneSeconds == 2)
        #expect(t.totalSeconds == 4)
        #expect(t.avgInZoneHR == 135)   // (130 + 140) / 2
        #expect(t.inZonePercent == 50)  // 2 of 4
    }
}
