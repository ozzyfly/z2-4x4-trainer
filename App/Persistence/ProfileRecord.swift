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

    /// Persisted zone-derivation method. Defaults to age-max for older records/data.
    var zoneMethodRaw: String = ZoneMethod.ageMax.rawValue
    /// Persisted display-unit preference. Defaults to metric for older records/data.
    var unitsRaw: String = UnitPreference.metric.rawValue
    /// Persisted custom-zone bands, stored as parallel scalar arrays (index = zone − 1).
    var customZoneLowers: [Int]?
    var customZoneUppers: [Int]?

    init(
        age: Int,
        sex: BiologicalSex,
        weightKg: Double,
        heightCm: Double,
        restingHR: Int? = nil,
        maxHROverride: Int? = nil,
        activity: ActivityLevel = .moderate,
        goalIsLose: Bool = false,
        loseRateKgPerWeek: Double = 0.5,
        zoneMethod: ZoneMethod = .ageMax,
        customZones: [HRRange]? = nil,
        units: UnitPreference = .defaultValue(for: Locale.current)
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
        self.zoneMethodRaw = zoneMethod.rawValue
        self.customZoneLowers = customZones?.map(\.lower)
        self.customZoneUppers = customZones?.map(\.upper)
        self.unitsRaw = units.rawValue
    }

    var sex: BiologicalSex {
        get { BiologicalSex(rawValue: sexRaw) ?? .male }
        set { sexRaw = newValue.rawValue }
    }

    var activity: ActivityLevel {
        get { ActivityLevel(rawValue: activityRaw) ?? .moderate }
        set { activityRaw = newValue.rawValue }
    }

    var zoneMethod: ZoneMethod {
        get { ZoneMethod(rawValue: zoneMethodRaw) ?? .ageMax }
        set { zoneMethodRaw = newValue.rawValue }
    }

    var units: UnitPreference {
        get { UnitPreference(rawValue: unitsRaw) ?? .metric }
        set { unitsRaw = newValue.rawValue }
    }

    /// User-supplied zone bands, reassembled from the parallel scalar arrays.
    var customZones: [HRRange]? {
        get {
            guard let lowers = customZoneLowers, let uppers = customZoneUppers,
                  lowers.count == uppers.count else { return nil }
            return zip(lowers, uppers).map { HRRange(lower: $0, upper: $1) }
        }
        set {
            customZoneLowers = newValue?.map(\.lower)
            customZoneUppers = newValue?.map(\.upper)
        }
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
            goal: goalIsLose ? .loseWeight(rateKgPerWeek: loseRateKgPerWeek) : .maintainHealth,
            zoneMethod: zoneMethod,
            customZones: customZones
        )
    }
}
