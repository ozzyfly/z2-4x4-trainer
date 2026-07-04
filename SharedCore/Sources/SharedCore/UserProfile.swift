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
    /// Which method `HRZoneCalculator` uses to derive zones. Defaults to age-max.
    public var zoneMethod: ZoneMethod
    /// User-supplied zone bands, indexed by zone (1 = Zone 1 … 5 = Zone 5). Used when
    /// `zoneMethod` is `.custom`; ignored otherwise.
    public var customZones: [HRRange]?

    /// When true, the Norwegian 4×4 hard effort targets Zone 5 only (≈90–100%) for a
    /// stricter VO2max stimulus; when false it spans the top band (≈Zone 4–5).
    public var hardEffortStrict: Bool

    /// Advanced 4×4 timing guards (seconds). Defaults match the engine's defaults.
    public var warmupMinSec: Int
    public var hardWallCapSec: Int
    public var recoveryMinSec: Int

    public init(
        age: Int,
        sex: BiologicalSex,
        weightKg: Double,
        heightCm: Double,
        restingHR: Int? = nil,
        maxHROverride: Int? = nil,
        activityLevel: ActivityLevel = .moderate,
        goal: TrainingGoal = .maintainHealth,
        zoneMethod: ZoneMethod = .ageMax,
        customZones: [HRRange]? = nil,
        hardEffortStrict: Bool = false,
        warmupMinSec: Int = 180,
        hardWallCapSec: Int = 480,
        recoveryMinSec: Int = 30
    ) {
        self.age = age
        self.sex = sex
        self.weightKg = weightKg
        self.heightCm = heightCm
        self.restingHR = restingHR
        self.maxHROverride = maxHROverride
        self.activityLevel = activityLevel
        self.goal = goal
        self.zoneMethod = zoneMethod
        self.customZones = customZones
        self.hardEffortStrict = hardEffortStrict
        self.warmupMinSec = warmupMinSec
        self.hardWallCapSec = hardWallCapSec
        self.recoveryMinSec = recoveryMinSec
    }

    // Backwards-compatible decoding: profiles persisted before precision-zones
    // omit `zoneMethod`/`customZones`, so default them when absent.
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        age = try c.decode(Int.self, forKey: .age)
        sex = try c.decode(BiologicalSex.self, forKey: .sex)
        weightKg = try c.decode(Double.self, forKey: .weightKg)
        heightCm = try c.decode(Double.self, forKey: .heightCm)
        restingHR = try c.decodeIfPresent(Int.self, forKey: .restingHR)
        maxHROverride = try c.decodeIfPresent(Int.self, forKey: .maxHROverride)
        activityLevel = try c.decode(ActivityLevel.self, forKey: .activityLevel)
        goal = try c.decode(TrainingGoal.self, forKey: .goal)
        zoneMethod = try c.decodeIfPresent(ZoneMethod.self, forKey: .zoneMethod) ?? .ageMax
        customZones = try c.decodeIfPresent([HRRange].self, forKey: .customZones)
        hardEffortStrict = try c.decodeIfPresent(Bool.self, forKey: .hardEffortStrict) ?? false
        warmupMinSec = try c.decodeIfPresent(Int.self, forKey: .warmupMinSec) ?? 180
        hardWallCapSec = try c.decodeIfPresent(Int.self, forKey: .hardWallCapSec) ?? 480
        recoveryMinSec = try c.decodeIfPresent(Int.self, forKey: .recoveryMinSec) ?? 30
    }
}
