import Foundation
import Testing
@testable import SharedCore

@Suite("Progress")
struct ProgressTests {
    @Test("fraction clamps to 0…1")
    func fraction() {
        #expect(TargetProgress(done: 75, target: 150).fraction == 0.5)
        #expect(TargetProgress(done: 200, target: 150).fraction == 1)   // clamped
        #expect(TargetProgress(done: 10, target: 0).fraction == 1)      // no target
    }

    @Test("isMet and remaining")
    func metRemaining() {
        let p = TargetProgress(done: 120, target: 150)
        #expect(p.isMet == false)
        #expect(p.remaining == 30)
        #expect(TargetProgress(done: 150, target: 150).isMet)
        #expect(TargetProgress(done: 160, target: 150).remaining == 0)
    }
}

@Suite("Schedule lookup")
struct ScheduleTests {
    @Test("returns the session for a weekday, rest when none")
    func byWeekday() {
        let plan = TrainingPlan.weekly(for: .maintainHealth)
        #expect(plan.session(onWeekday: 1).type == .zone2)        // Monday
        #expect(plan.session(onWeekday: 3).type == .norwegian4x4) // Wednesday
        #expect(plan.session(onWeekday: 2).type == .rest)         // Tuesday
    }

    @Test("maps a calendar date to the right weekday")
    func byDate() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        // 2026-06-01 is a Monday → weekday 1 → Zone 2 in the maintain plan.
        let monday = DateComponents(calendar: cal, year: 2026, month: 6, day: 1).date!
        let plan = TrainingPlan.weekly(for: .maintainHealth)
        #expect(plan.session(on: monday, calendar: cal).type == .zone2)
    }
}
