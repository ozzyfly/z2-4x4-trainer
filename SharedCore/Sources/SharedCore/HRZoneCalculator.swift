import Foundation

/// Five-zone heart-rate model (percent of max HR).
public enum HRZone: Int, CaseIterable, Sendable {
    case zone1 = 1  // 50–60% — very light / recovery
    case zone2      // 60–70% — aerobic base (the "Zone 2" target)
    case zone3      // 70–80% — tempo
    case zone4      // 80–90% — threshold
    case zone5      // 90–100% — VO2max
}

/// Inclusive heart-rate band in beats per minute.
public struct HRRange: Equatable, Sendable, Codable {
    public let lower: Int
    public let upper: Int
    public init(lower: Int, upper: Int) {
        self.lower = lower
        self.upper = upper
    }
    public func contains(_ bpm: Int) -> Bool { bpm >= lower && bpm <= upper }
}

/// Derives personalised heart-rate zones from a profile.
///
/// The estimate maxHR = 220 − age is used unless the user supplies an override. The
/// `zoneMethod` selects how the bands are derived:
/// - `.ageMax`: percent of maxHR (the original behaviour).
/// - `.karvonen`: heart-rate reserve, resting + pct·(max − resting); falls back to age-max
///   when no resting HR is available.
/// - `.custom`: user-supplied bands indexed by zone; falls back to age-max when a band is
///   missing.
public struct HRZoneCalculator: Sendable {
    public let maxHR: Int
    private let method: ZoneMethod
    private let restingHR: Int?
    private let customZones: [HRRange]?

    public init(maxHR: Int) {
        self.maxHR = maxHR
        self.method = .ageMax
        self.restingHR = nil
        self.customZones = nil
    }

    public init(profile: UserProfile) {
        self.maxHR = profile.maxHROverride ?? (220 - profile.age)
        self.method = profile.zoneMethod
        self.restingHR = profile.restingHR
        self.customZones = profile.customZones
    }

    private func bpm(_ percent: Double) -> Int {
        Int((Double(maxHR) * percent).rounded())
    }

    /// Inclusive bounds, in % of maxHR, for each zone.
    private func bounds(for zone: HRZone) -> (lower: Double, upper: Double) {
        switch zone {
        case .zone1: return (0.50, 0.60)
        case .zone2: return (0.60, 0.70)
        case .zone3: return (0.70, 0.80)
        case .zone4: return (0.80, 0.90)
        case .zone5: return (0.90, 1.00)
        }
    }

    /// Age-max band for a zone (percent of maxHR). This is the fallback for every method.
    private func ageMaxRange(for zone: HRZone) -> HRRange {
        let b = bounds(for: zone)
        return HRRange(lower: bpm(b.lower), upper: bpm(b.upper))
    }

    /// Karvonen / heart-rate-reserve band: resting + pct·(max − resting).
    private func karvonenRange(for zone: HRZone, resting: Int) -> HRRange {
        let reserve = Double(maxHR - resting)
        let b = bounds(for: zone)
        let lower = Double(resting) + b.lower * reserve
        let upper = Double(resting) + b.upper * reserve
        return HRRange(lower: Int(lower.rounded()), upper: Int(upper.rounded()))
    }

    public func range(for zone: HRZone) -> HRRange {
        switch method {
        case .ageMax:
            return ageMaxRange(for: zone)
        case .karvonen:
            guard let resting = restingHR else { return ageMaxRange(for: zone) }
            return karvonenRange(for: zone, resting: resting)
        case .custom:
            let index = zone.rawValue - 1
            if let zones = customZones, customZones?.indices.contains(index) == true {
                return zones[index]
            }
            return ageMaxRange(for: zone)
        }
    }

    /// The aerobic-base target band.
    public var zone2: HRRange { range(for: .zone2) }

    /// The hard-interval band for Norwegian 4×4 (85–95% maxHR / reserve / custom-derived).
    public var fourByFourHard: HRRange {
        switch method {
        case .ageMax:
            return HRRange(lower: bpm(0.85), upper: bpm(0.95))
        case .karvonen:
            guard let resting = restingHR else {
                return HRRange(lower: bpm(0.85), upper: bpm(0.95))
            }
            let reserve = Double(maxHR - resting)
            let lower = Double(resting) + 0.85 * reserve
            let upper = Double(resting) + 0.95 * reserve
            return HRRange(lower: Int(lower.rounded()), upper: Int(upper.rounded()))
        case .custom:
            // No dedicated custom 4×4 band; treat it as the top of the custom range.
            return HRRange(lower: bpm(0.85), upper: bpm(0.95))
        }
    }

    /// Classifies a live heart-rate sample into a zone, or nil if below zone 1.
    public func zone(forBPM bpm: Int) -> HRZone? {
        for zone in HRZone.allCases.reversed() {
            if bpm >= range(for: zone).lower { return zone }
        }
        return nil
    }
}
