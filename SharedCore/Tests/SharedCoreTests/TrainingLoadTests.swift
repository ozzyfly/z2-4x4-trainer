import Foundation
import Testing
@testable import SharedCore

@Suite("Training load (ACWR)")
struct TrainingLoadTests {
    private let now = Date(timeIntervalSinceReferenceDate: 800_000_000)

    /// One `minutes`-long Zone 2 record `days` days before `now`.
    private func record(daysAgo: Int, minutes: Int) -> WorkoutRecord {
        WorkoutRecord(
            date: Calendar.current.date(byAdding: .day, value: -daysAgo, to: now)!,
            type: .zone2,
            durationMin: minutes
        )
    }

    @Test("steady week-in, week-out load is ok (ratio ≈ 1)")
    func steadyLoad() {
        // 4 × 45 min every week for 4 weeks.
        var history: [WorkoutRecord] = []
        for week in 0..<4 {
            for day in [1, 3, 5, 6] {
                history.append(record(daysAgo: week * 7 + day, minutes: 45))
            }
        }
        let a = TrainingLoad.assess(history: history, now: now)
        #expect(a.level == .ok)
        #expect(a.ratio != nil)
        #expect(abs((a.ratio ?? 0) - 1.0) < 0.15)
    }

    @Test("sudden ramp trips caution, bigger ramp trips high risk")
    func ramp() {
        // 3 quiet weeks (~90 min/wk), then a huge acute week.
        var history: [WorkoutRecord] = []
        for week in 1..<4 {
            history.append(record(daysAgo: week * 7 + 1, minutes: 45))
            history.append(record(daysAgo: week * 7 + 3, minutes: 45))
        }
        var caution = history
        caution.append(record(daysAgo: 1, minutes: 90))
        caution.append(record(daysAgo: 3, minutes: 90))
        let c = TrainingLoad.assess(history: caution, now: now)
        #expect(c.level == .caution || c.level == .highRisk)

        var risky = history
        for day in 1...5 { risky.append(record(daysAgo: day, minutes: 90)) }
        let r = TrainingLoad.assess(history: risky, now: now)
        #expect(r.level == .highRisk)
        #expect((r.ratio ?? 0) >= TrainingLoad.highRiskRatio)
    }

    @Test("thin chronic history never alarms (no divide-by-nearly-zero)")
    func newAthlete() {
        // First-ever week of training: nothing before it.
        let history = [
            record(daysAgo: 1, minutes: 45),
            record(daysAgo: 2, minutes: 45),
            record(daysAgo: 4, minutes: 45),
        ]
        let a = TrainingLoad.assess(history: history, now: now)
        #expect(a.level == .ok)
        #expect(a.ratio == nil)
    }

    @Test("empty history is ok with zeroed numbers")
    func empty() {
        let a = TrainingLoad.assess(history: [], now: now)
        #expect(a.level == .ok)
        #expect(a.acuteMinutes == 0)
        #expect(a.ratio == nil)
    }

    @Test("records outside the chronic window are ignored")
    func windowing() {
        var history: [WorkoutRecord] = [record(daysAgo: 40, minutes: 500)]
        for week in 0..<4 {
            history.append(record(daysAgo: week * 7 + 2, minutes: 60))
        }
        let a = TrainingLoad.assess(history: history, now: now)
        // The giant 40-day-old session must not inflate the chronic baseline.
        #expect(a.chronicWeeklyMinutes <= 70)
    }
}
