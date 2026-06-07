import Foundation

/// Evaluates `Achievement.catalog` against training history and fitness, returning the set of
/// unlocked achievement ids.
public enum AchievementEvaluator {
    public static func unlocked(
        history: [WorkoutRecord],
        fitness: FitnessTrend?,
        profile: UserProfile,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> Set<String> {
        var ids: Set<String> = []

        // First 4×4 — any Norwegian 4×4 in history.
        if history.contains(where: { $0.type == .norwegian4x4 }) {
            ids.insert("first-4x4")
        }

        // 10 Sessions — at least 10 logged workouts.
        if history.count >= 10 {
            ids.insert("ten-sessions")
        }

        // 3-Week Streak — current or longest streak reaches 3 weeks.
        let current = StreakCalculator.currentWeeks(in: history, now: now, calendar: calendar)
        let longest = StreakCalculator.longestWeeks(in: history, now: now, calendar: calendar)
        if current >= 3 || longest >= 3 {
            ids.insert("three-week-streak")
        }

        // Consistent Month — at least 4 distinct weeks met the weekly training target.
        if weeksMeetingTarget(history: history, profile: profile, calendar: calendar) >= 4 {
            ids.insert("weekly-target-4x")
        }

        // Fitter — VO2max has improved since the first sample.
        if let fitness, fitness.deltaFromFirst > 0 {
            ids.insert("vo2max-up")
        }

        return ids
    }

    /// Counts distinct calendar weeks whose logged minutes met the weekly target.
    private static func weeksMeetingTarget(
        history: [WorkoutRecord],
        profile: UserProfile,
        calendar: Calendar
    ) -> Int {
        let base = TrainingPlan.weekly(for: profile.goal)
        let target = TargetsCalculator.weekly(profile: profile, plan: base).trainingMinutes
        let samples = history.map(\.sample)

        let weekStarts: Set<Date> = Set(history.compactMap { record in
            calendar.dateInterval(of: .weekOfYear, for: record.date)?.start
        })
        return weekStarts.filter { weekStart in
            ActivityAggregator.weeklyMinutes(in: samples, for: weekStart, calendar: calendar) >= target
        }.count
    }
}
