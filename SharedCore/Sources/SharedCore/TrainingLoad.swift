import Foundation

/// Acute:chronic workload ratio (ACWR) — the classic overtraining early-warning
/// signal, computed purely from the athlete's own workout history. No sensors
/// required, so it works even when HRV / heart-rate data is missing entirely.
///
/// Load is measured in training minutes (the app's native unit). Acute = the
/// last 7 days; chronic = the 28-day daily average scaled to a week. A ratio
/// meaningfully above 1.0 means this week is much bigger than what the body is
/// adapted to; the commonly cited caution zone starts around 1.3–1.5.
public enum TrainingLoad {
    /// Days in the acute (recent) window.
    public static let acuteWindowDays = 7
    /// Days in the chronic (baseline) window.
    public static let chronicWindowDays = 28
    /// Ratio at/above which the athlete should be warned they're ramping too fast.
    public static let cautionRatio = 1.3
    /// Ratio at/above which the ramp is high-risk.
    public static let highRiskRatio = 1.5
    /// Minimum chronic weekly minutes before a ratio is meaningful — a brand-new
    /// athlete's first week would otherwise divide by (near) zero and always alarm.
    public static let minimumChronicWeeklyMinutes = 60.0

    public enum Level: Sendable, Equatable {
        /// Ramp is within the adapted range (or there's not enough history to judge).
        case ok
        /// Acute load is well above chronic — consider easing this week.
        case caution
        /// Acute load far exceeds chronic — high overtraining/injury risk.
        case highRisk
    }

    public struct Assessment: Sendable, Equatable {
        /// Acute (7-day) training minutes.
        public let acuteMinutes: Int
        /// Chronic load expressed as average weekly minutes over the 28-day window.
        public let chronicWeeklyMinutes: Int
        /// acute ÷ chronic, rounded to 2 decimals. Nil when chronic history is too thin.
        public let ratio: Double?
        public let level: Level

        public init(acuteMinutes: Int, chronicWeeklyMinutes: Int, ratio: Double?, level: Level) {
            self.acuteMinutes = acuteMinutes
            self.chronicWeeklyMinutes = chronicWeeklyMinutes
            self.ratio = ratio
            self.level = level
        }
    }

    /// Assesses the current ramp from workout history. Pure + deterministic.
    public static func assess(
        history: [WorkoutRecord],
        now: Date = .now,
        calendar: Calendar = .current
    ) -> Assessment {
        let acuteStart = calendar.date(byAdding: .day, value: -acuteWindowDays, to: now) ?? now
        let chronicStart = calendar.date(byAdding: .day, value: -chronicWindowDays, to: now) ?? now

        let acute = history
            .filter { $0.date > acuteStart && $0.date <= now }
            .reduce(0) { $0 + $1.durationMin }
        let chronicTotal = history
            .filter { $0.date > chronicStart && $0.date <= now }
            .reduce(0) { $0 + $1.durationMin }
        // Daily average over the window, scaled to a week — includes the acute
        // days, which damps the ratio slightly (standard rolling-average ACWR).
        let chronicWeekly = Double(chronicTotal) / Double(chronicWindowDays) * 7.0

        guard chronicWeekly >= minimumChronicWeeklyMinutes else {
            return Assessment(
                acuteMinutes: acute,
                chronicWeeklyMinutes: Int(chronicWeekly.rounded()),
                ratio: nil,
                level: .ok
            )
        }

        let ratio = (Double(acute) / chronicWeekly * 100).rounded() / 100
        let level: Level
        if ratio >= highRiskRatio {
            level = .highRisk
        } else if ratio >= cautionRatio {
            level = .caution
        } else {
            level = .ok
        }
        return Assessment(
            acuteMinutes: acute,
            chronicWeeklyMinutes: Int(chronicWeekly.rounded()),
            ratio: ratio,
            level: level
        )
    }
}
