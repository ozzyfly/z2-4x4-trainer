import Foundation

/// Computes weekly training streaks from history. A week "counts" when it contains at least
/// one logged workout.
public enum StreakCalculator {
    /// Consecutive weeks ending with the current week that each have ≥1 record.
    /// Returns 0 when the current week has no workout.
    public static func currentWeeks(
        in history: [WorkoutRecord],
        now: Date = .now,
        calendar: Calendar = .current
    ) -> Int {
        var streak = 0
        var cursor = now
        while hasRecord(in: history, week: cursor, calendar: calendar) {
            streak += 1
            guard let prev = calendar.date(byAdding: .weekOfYear, value: -1, to: cursor) else { break }
            cursor = prev
        }
        return streak
    }

    /// The longest run of consecutive trained weeks anywhere in history.
    public static func longestWeeks(
        in history: [WorkoutRecord],
        now: Date = .now,
        calendar: Calendar = .current
    ) -> Int {
        guard !history.isEmpty else { return 0 }

        // Distinct trained weeks, keyed by the start of their week.
        let weekStarts: Set<Date> = Set(history.compactMap { record in
            calendar.dateInterval(of: .weekOfYear, for: record.date)?.start
        })
        guard !weekStarts.isEmpty else { return 0 }

        let sorted = weekStarts.sorted()
        var longest = 1
        var run = 1
        for i in 1..<sorted.count {
            let expectedPrev = calendar.date(byAdding: .weekOfYear, value: -1, to: sorted[i])
            if let expectedPrev, calendar.isDate(expectedPrev, equalTo: sorted[i - 1], toGranularity: .weekOfYear) {
                run += 1
            } else {
                run = 1
            }
            longest = max(longest, run)
        }
        return longest
    }

    private static func hasRecord(in history: [WorkoutRecord], week: Date, calendar: Calendar) -> Bool {
        history.contains { calendar.isDate($0.date, equalTo: week, toGranularity: .weekOfYear) }
    }
}
