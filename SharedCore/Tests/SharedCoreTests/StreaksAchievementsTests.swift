import Foundation
import Testing
@testable import SharedCore

@Suite("Streaks & achievements")
struct StreaksAchievementsTests {
    private let calendar = Calendar(identifier: .gregorian)
    private let now = Date(timeIntervalSince1970: 1_700_000_000)
    private let profile = UserProfile(age: 30, sex: .male, weightKg: 80, heightCm: 180)

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

    @Test("Catalog contains all expected ids")
    func catalogIds() {
        let ids = Set(Achievement.catalog.map(\.id))
        #expect(ids == [
            "first-4x4", "ten-sessions", "three-week-streak", "weekly-target-4x", "vo2max-up",
        ])
    }

    @Test("First 4×4 unlocks with a Norwegian 4×4 in history")
    func firstFourByFourUnlocks() {
        let history = [record(weeksAgo: 0, minutes: 43, type: .norwegian4x4)]
        let unlocked = AchievementEvaluator.unlocked(
            history: history, fitness: nil, profile: profile, now: now, calendar: calendar
        )
        #expect(unlocked.contains("first-4x4"))
    }

    @Test("10 Sessions stays locked under 10 workouts")
    func tenSessionsLockedUnderTen() {
        let history = (0..<9).map { record(weeksAgo: $0 % 4) }
        let unlocked = AchievementEvaluator.unlocked(
            history: history, fitness: nil, profile: profile, now: now, calendar: calendar
        )
        #expect(!unlocked.contains("ten-sessions"))
    }

    @Test("10 Sessions unlocks at 10 workouts")
    func tenSessionsUnlocks() {
        let history = (0..<10).map { _ in record(weeksAgo: 0, minutes: 30) }
        let unlocked = AchievementEvaluator.unlocked(
            history: history, fitness: nil, profile: profile, now: now, calendar: calendar
        )
        #expect(unlocked.contains("ten-sessions"))
    }

    @Test("Fitter unlocks when VO2max delta is positive")
    func vo2maxUpUnlocks() {
        let day: TimeInterval = 86_400
        let trend = FitnessTrend.from([
            VO2MaxSample(date: now.addingTimeInterval(-day), value: 40),
            VO2MaxSample(date: now, value: 43),
        ])
        let unlocked = AchievementEvaluator.unlocked(
            history: [], fitness: trend, profile: profile, now: now, calendar: calendar
        )
        #expect(unlocked.contains("vo2max-up"))
    }
}
