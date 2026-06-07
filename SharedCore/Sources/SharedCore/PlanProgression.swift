import Foundation

/// Adapts a base `TrainingPlan` from training history, deterministically.
///
/// The rule (so the UI can describe it):
/// 1. Walk backwards week-by-week from `now`, counting **consecutive met weeks** — a week is
///    "met" when its logged minutes (sum of `WorkoutRecord` minutes in that week) are at least
///    the weekly training-minute target from `TargetsCalculator.weekly`.
/// 2. If the most recent completed week (the week before the current one) **missed** the
///    target → **hold**: return the base plan unchanged.
/// 3. Else, with `metWeeks` consecutive met weeks:
///    - **deload** when `metWeeks >= 3 && metWeeks % 4 == 0` → reduce every Zone 2 session by
///      10 min (floor 20) so total volume drops below base.
///    - **progress** when `metWeeks >= 3` → add 10 min to every Zone 2 session so total volume
///      rises above base.
///    - otherwise (1–2 met weeks) → hold (base plan).
public enum PlanProgression {
    public static func adjust(
        base: TrainingPlan,
        history: [WorkoutRecord],
        profile: UserProfile,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> TrainingPlan {
        let target = TargetsCalculator.weekly(profile: profile, plan: base).trainingMinutes
        let samples = history.map(\.sample)

        // Did the most recent completed week (one week before now) meet the target?
        guard let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: now) else {
            return base
        }
        let lastWeekMinutes = ActivityAggregator.weeklyMinutes(in: samples, for: lastWeek, calendar: calendar)
        if lastWeekMinutes < target {
            return base // hold after a missed week
        }

        // Count consecutive met weeks ending at the last completed week.
        var metWeeks = 0
        var cursor = lastWeek
        while true {
            let minutes = ActivityAggregator.weeklyMinutes(in: samples, for: cursor, calendar: calendar)
            guard minutes >= target else { break }
            metWeeks += 1
            guard let prev = calendar.date(byAdding: .weekOfYear, value: -1, to: cursor) else { break }
            cursor = prev
        }

        guard metWeeks >= 3 else { return base } // hold until consistency is established

        if metWeeks % 4 == 0 {
            return deloaded(base) // scheduled deload every 4th progression week
        }
        return progressed(base)
    }

    /// +10 min on every Zone 2 session → strictly more volume than base.
    private static func progressed(_ base: TrainingPlan) -> TrainingPlan {
        TrainingPlan(sessions: base.sessions.map { s in
            s.type == .zone2
                ? PlannedSession(day: s.day, type: s.type, durationMin: s.durationMin + 10)
                : s
        })
    }

    /// −10 min on every Zone 2 session (floor 20) → strictly less volume than base.
    private static func deloaded(_ base: TrainingPlan) -> TrainingPlan {
        TrainingPlan(sessions: base.sessions.map { s in
            s.type == .zone2
                ? PlannedSession(day: s.day, type: s.type, durationMin: max(20, s.durationMin - 10))
                : s
        })
    }
}
