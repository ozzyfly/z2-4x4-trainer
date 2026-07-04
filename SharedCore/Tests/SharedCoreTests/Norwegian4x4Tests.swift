import Testing
@testable import SharedCore

@Suite("Norwegian 4×4")
struct Norwegian4x4Tests {
    @Test("session is warmup + 4×(hard+recovery) + cooldown = 10 intervals")
    func structure() {
        let intervals = Norwegian4x4.build(using: HRZoneCalculator(maxHR: 200))
        #expect(intervals.count == 10)
        #expect(intervals.first?.kind == .warmup)
        #expect(intervals.last?.kind == .cooldown)
        #expect(intervals.filter { $0.kind == .hard }.count == 4)
        #expect(intervals.filter { $0.kind == .recovery }.count == 4)
    }

    @Test("hard intervals target the 85–95% band")
    func hardTargets() {
        let c = HRZoneCalculator(maxHR: 200)
        let intervals = Norwegian4x4.build(using: c)
        for hard in intervals.filter({ $0.kind == .hard }) {
            #expect(hard.targetHR == c.fourByFourHard)
            #expect(hard.durationSec == 4 * 60)
        }
    }

    @Test("total duration is 36 minutes")
    func totalDuration() {
        // 5 min warmup + 4×(4 min hard + 3 min recovery) + 3 min cooldown.
        #expect(Norwegian4x4.totalDurationSec == 2160)
    }

    @Test("low readiness reduces to 3 hard blocks")
    func readinessReducesRepeats() {
        #expect(Norwegian4x4.recommendedRepeats(for: .easy) == 3)
        #expect(Norwegian4x4.recommendedRepeats(for: .steady) == 4)
        #expect(Norwegian4x4.recommendedRepeats(for: .goHard) == 4)
        #expect(Norwegian4x4.recommendedRepeats(for: nil) == 4)

        let three = Norwegian4x4.build(using: HRZoneCalculator(maxHR: 200), repeats: 3)
        #expect(three.filter { $0.kind == .hard }.count == 3)
        #expect(three.filter { $0.kind == .recovery }.count == 3)
    }
}
