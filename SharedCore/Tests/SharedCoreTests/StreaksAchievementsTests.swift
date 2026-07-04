import Foundation
import Testing
@testable import SharedCore

@Suite("Streaks")
struct StreaksTests {
    private let calendar = Calendar(identifier: .gregorian)
    private let now = Date(timeIntervalSince1970: 1_700_000_000)

    private func record(weeksAgo: Int, minutes: Int = 40, type: SessionType = .zone2) -> WorkoutRecord {
        let date = calendar.date(byAdding: .weekOfYear, value: -weeksAgo, to: now)!
        return WorkoutRecord(date: date, type: type, durationMin: minutes)
    }

    @Test("3 consecutive trained weeks → current streak 3, longest ≥ 3")
    func threeWeekStreak() {
        let history = [record(weeksAgo: 0), record(weeksAgo: 1), record(weeksAgo: 2)]
        #expect(StreakCalculator.currentWeeks(in: history, now: now, calendar: calendar) == 3)
        #expect(StreakCalculator.longestWeeks(in: history, now: now, calendar: calendar) >= 3)
    }

    @Test("No workout this week → current streak 0")
    func gapThisWeekBreaksStreak() {
        let history = [record(weeksAgo: 1), record(weeksAgo: 2), record(weeksAgo: 3)]
        #expect(StreakCalculator.currentWeeks(in: history, now: now, calendar: calendar) == 0)
    }
}
