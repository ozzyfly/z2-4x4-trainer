import Foundation

/// Biological sex, used only for the BMR formula.
public enum BiologicalSex: String, Codable, Sendable, CaseIterable {
    case male
    case female
}

/// Day-to-day activity outside of prescribed training, used to scale TDEE.
public enum ActivityLevel: String, Codable, Sendable, CaseIterable {
    case sedentary      // little/no exercise, desk job
    case light          // light exercise 1–3 days/week
    case moderate       // moderate exercise 3–5 days/week
    case active         // hard exercise 6–7 days/week
    case veryActive     // physical job or 2× training/day

    /// Mifflin–St Jeor activity multiplier.
    public var factor: Double {
        switch self {
        case .sedentary: return 1.2
        case .light: return 1.375
        case .moderate: return 1.55
        case .active: return 1.725
        case .veryActive: return 1.9
        }
    }
}

/// What the user is training for. Drives plan volume and energy targets.
public enum TrainingGoal: Codable, Sendable, Equatable {
    case maintainHealth
    case loseWeight(rateKgPerWeek: Double)
}

/// All user-supplied / Health-derived inputs the domain needs. No UI, no HealthKit types.
public struct UserProfile: Codable, Sendable, Equatable {
    public var age: Int
    public var sex: BiologicalSex
    public var weightKg: Double
    public var heightCm: Double
    /// Optional, typically read from Health. Enables Karvonen (HRR) zones later.
    public var restingHR: Int?
    /// Optional manual override; when nil, maxHR defaults to 220 − age.
    public var maxHROverride: Int?
    public var activityLevel: ActivityLevel
    public var goal: TrainingGoal

    public init(
        age: Int,
        sex: BiologicalSex,
        weightKg: Double,
        heightCm: Double,
        restingHR: Int? = nil,
        maxHROverride: Int? = nil,
        activityLevel: ActivityLevel = .moderate,
        goal: TrainingGoal = .maintainHealth
    ) {
        self.age = age
        self.sex = sex
        self.weightKg = weightKg
        self.heightCm = heightCm
        self.restingHR = restingHR
        self.maxHROverride = maxHROverride
        self.activityLevel = activityLevel
        self.goal = goal
    }
}
