import Foundation
import SwiftData
import SharedCore

/// Persisted user profile (single record). Bridges to the pure-domain `UserProfile`.
@Model
final class ProfileRecord {
    var age: Int
    var sexRaw: String
    var weightKg: Double
    var heightCm: Double
    var restingHR: Int?
    var maxHROverride: Int?
    var activityRaw: String
    var goalIsLose: Bool
    var loseRateKgPerWeek: Double

    init(
        age: Int,
        sex: BiologicalSex,
        weightKg: Double,
        heightCm: Double,
        restingHR: Int? = nil,
        maxHROverride: Int? = nil,
        activity: ActivityLevel = .moderate,
        goalIsLose: Bool = false,
        loseRateKgPerWeek: Double = 0.5
    ) {
        self.age = age
        self.sexRaw = sex.rawValue
        self.weightKg = weightKg
        self.heightCm = heightCm
        self.restingHR = restingHR
        self.maxHROverride = maxHROverride
        self.activityRaw = activity.rawValue
        self.goalIsLose = goalIsLose
        self.loseRateKgPerWeek = loseRateKgPerWeek
    }

    var sex: BiologicalSex {
        get { BiologicalSex(rawValue: sexRaw) ?? .male }
        set { sexRaw = newValue.rawValue }
    }

    var activity: ActivityLevel {
        get { ActivityLevel(rawValue: activityRaw) ?? .moderate }
        set { activityRaw = newValue.rawValue }
    }

    /// The pure-domain value used by all calculators.
    var domain: UserProfile {
        UserProfile(
            age: age,
            sex: sex,
            weightKg: weightKg,
            heightCm: heightCm,
            restingHR: restingHR,
            maxHROverride: maxHROverride,
            activityLevel: activity,
            goal: goalIsLose ? .loseWeight(rateKgPerWeek: loseRateKgPerWeek) : .maintainHealth
        )
    }
}
