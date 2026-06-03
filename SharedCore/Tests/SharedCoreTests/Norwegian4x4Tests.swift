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

    @Test("total duration is 43 minutes")
    func totalDuration() {
        #expect(Norwegian4x4.totalDurationSec == 2580)
    }
}
