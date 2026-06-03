import Foundation

/// What the user should achieve in a week to meet their goal.
public struct WeeklyTargets: Sendable, Equatable {
    /// Moderate-or-greater training minutes (WHO guidance: 150–300/week).
    public let trainingMinutes: Int
    /// Number of hard (4×4) sessions.
    public let hardSessions: Int
    /// Extra energy to burn through exercise for weight loss, kcal. nil when maintaining.
    public let activeEnergyKcal: Int?
}

/// What the user should achieve today (the weekly target spread across training days).
public struct DailyTargets: Sendable, Equatable {
    public let trainingMinutes: Int
    public let activeEnergyKcal: Int?
}

/// Turns a profile + plan into concrete weekly/daily targets.
public enum TargetsCalculator {
    /// WHO floor for substantial health benefit.
    public static let whoWeeklyMinutesFloor = 150

    public static func weekly(profile: UserProfile, plan: TrainingPlan) -> WeeklyTargets {
        let minutes = max(plan.weeklyTrainingMinutes, whoWeeklyMinutesFloor)
        let energy: Int?
        switch profile.goal {
        case .maintainHealth:
            energy = nil
        case .loseWeight(let rate):
            // Half the deficit is assumed to come from exercise, half from diet.
            let weeklyExerciseDeficit = EnergyCalculator.dailyDeficit(rateKgPerWeek: rate) * 7 * 0.5
            energy = Int(weeklyExerciseDeficit.rounded())
        }
        return WeeklyTargets(
            trainingMinutes: minutes,
            hardSessions: plan.weeklyHardSessions,
            activeEnergyKcal: energy
        )
    }

    /// Spreads a weekly target across the number of non-rest days in the plan.
    public static func daily(profile: UserProfile, plan: TrainingPlan) -> DailyTargets {
        let weekly = weekly(profile: profile, plan: plan)
        let trainingDays = max(plan.sessions.filter { $0.type != .rest }.count, 1)
        let minutes = Int((Double(weekly.trainingMinutes) / Double(trainingDays)).rounded())
        let energy = weekly.activeEnergyKcal.map {
            Int((Double($0) / Double(trainingDays)).rounded())
        }
        return DailyTargets(trainingMinutes: minutes, activeEnergyKcal: energy)
    }
}
