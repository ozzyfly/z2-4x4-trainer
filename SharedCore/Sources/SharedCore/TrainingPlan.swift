import Foundation

public enum SessionType: String, Codable, Sendable, Equatable {
    case zone2
    case norwegian4x4
    case rest
}

/// A single prescribed session within a week. `day` is 1 = Monday … 7 = Sunday.
public struct PlannedSession: Codable, Sendable, Equatable {
    public let day: Int
    public let type: SessionType
    /// Prescribed duration in minutes. For 4×4 this is the full session length; rest = 0.
    public let durationMin: Int

    public init(day: Int, type: SessionType, durationMin: Int) {
        self.day = day
        self.type = type
        self.durationMin = durationMin
    }
}

/// A weekly schedule of Zone 2 and Norwegian 4×4 sessions, scaled by goal.
public struct TrainingPlan: Sendable, Equatable {
    public let sessions: [PlannedSession]

    public init(sessions: [PlannedSession]) {
        self.sessions = sessions
    }

    private static let fourByFourMin = (Norwegian4x4.totalDurationSec + 59) / 60

    /// Default weekly plan for a goal.
    ///
    /// - maintainHealth: 3 Zone 2 (40 min) + 1 4×4 → meets the WHO 150 min/week floor.
    /// - loseWeight: 4 Zone 2 (45 min) + 2 4×4 → higher volume for an energy deficit.
    public static func weekly(for goal: TrainingGoal) -> TrainingPlan {
        switch goal {
        case .maintainHealth:
            return TrainingPlan(sessions: [
                .init(day: 1, type: .zone2, durationMin: 40),
                .init(day: 2, type: .rest, durationMin: 0),
                .init(day: 3, type: .norwegian4x4, durationMin: fourByFourMin),
                .init(day: 4, type: .rest, durationMin: 0),
                .init(day: 5, type: .zone2, durationMin: 40),
                .init(day: 6, type: .zone2, durationMin: 40),
                .init(day: 7, type: .rest, durationMin: 0),
            ])
        case .loseWeight:
            return TrainingPlan(sessions: [
                .init(day: 1, type: .zone2, durationMin: 45),
                .init(day: 2, type: .norwegian4x4, durationMin: fourByFourMin),
                .init(day: 3, type: .zone2, durationMin: 45),
                .init(day: 4, type: .rest, durationMin: 0),
                .init(day: 5, type: .norwegian4x4, durationMin: fourByFourMin),
                .init(day: 6, type: .zone2, durationMin: 45),
                .init(day: 7, type: .zone2, durationMin: 45),
            ])
        }
    }

    /// The session prescribed for a given weekday (1 = Monday … 7 = Sunday).
    /// Returns a rest session if the plan has no entry for that day.
    public func session(onWeekday weekday: Int) -> PlannedSession {
        sessions.first { $0.day == weekday }
            ?? PlannedSession(day: weekday, type: .rest, durationMin: 0)
    }

    /// The session prescribed for a calendar date, using the user's calendar.
    public func session(on date: Date, calendar: Calendar = .current) -> PlannedSession {
        // Calendar weekday: 1 = Sunday … 7 = Saturday → map to 1 = Monday … 7 = Sunday.
        let cw = calendar.component(.weekday, from: date)
        let weekday = ((cw + 5) % 7) + 1
        return session(onWeekday: weekday)
    }

    public var weeklyZone2Minutes: Int {
        sessions.filter { $0.type == .zone2 }.reduce(0) { $0 + $1.durationMin }
    }

    public var weeklyHardSessions: Int {
        sessions.filter { $0.type == .norwegian4x4 }.count
    }

    /// Total prescribed moderate-or-greater minutes across the week.
    public var weeklyTrainingMinutes: Int {
        sessions.filter { $0.type != .rest }.reduce(0) { $0 + $1.durationMin }
    }
}
