import Foundation

/// Energy math for weight-loss targets. Pure functions, all inputs explicit.
public enum EnergyCalculator {
    /// Energy in one kilogram of body fat, in kilocalories (standard 7700 kcal/kg).
    public static let kcalPerKgFat: Double = 7700

    /// Basal metabolic rate via the Mifflin–St Jeor equation (kcal/day).
    public static func bmr(profile: UserProfile) -> Double {
        let base = 10 * profile.weightKg + 6.25 * profile.heightCm - 5 * Double(profile.age)
        switch profile.sex {
        case .male: return base + 5
        case .female: return base - 161
        }
    }

    /// Total daily energy expenditure: BMR scaled by everyday activity (kcal/day).
    public static func tdee(profile: UserProfile) -> Double {
        bmr(profile: profile) * profile.activityLevel.factor
    }

    /// Daily kcal deficit required to lose fat at the given weekly rate.
    public static func dailyDeficit(rateKgPerWeek: Double) -> Double {
        rateKgPerWeek * kcalPerKgFat / 7
    }

    /// Resolved daily energy picture for the profile's goal.
    /// For `maintainHealth`, deficit is 0 and `intakeTarget == tdee`.
    public static func dailyEnergy(profile: UserProfile)
        -> (tdee: Double, deficit: Double, intakeTarget: Double) {
        let t = tdee(profile: profile)
        switch profile.goal {
        case .maintainHealth:
            return (t, 0, t)
        case .loseWeight(let rate):
            let d = dailyDeficit(rateKgPerWeek: rate)
            return (t, d, t - d)
        }
    }
}
