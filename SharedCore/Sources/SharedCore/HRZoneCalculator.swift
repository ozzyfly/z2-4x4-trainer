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
public struct HRRange: Equatable, Sendable {
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
/// Uses the age-based estimate maxHR = 220 − age unless the user supplies an override.
/// Karvonen (heart-rate-reserve) is intentionally not used yet; `restingHR` is captured
/// on the profile so it can be added without changing call sites.
public struct HRZoneCalculator: Sendable {
    public let maxHR: Int

    public init(maxHR: Int) {
        self.maxHR = maxHR
    }

    public init(profile: UserProfile) {
        self.maxHR = profile.maxHROverride ?? (220 - profile.age)
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

    public func range(for zone: HRZone) -> HRRange {
        let b = bounds(for: zone)
        return HRRange(lower: bpm(b.lower), upper: bpm(b.upper))
    }

    /// The aerobic-base target band.
    public var zone2: HRRange { range(for: .zone2) }

    /// The hard-interval band for Norwegian 4×4 (85–95% maxHR).
    public var fourByFourHard: HRRange {
        HRRange(lower: bpm(0.85), upper: bpm(0.95))
    }

    /// Classifies a live heart-rate sample into a zone, or nil if below zone 1.
    public func zone(forBPM bpm: Int) -> HRZone? {
        for zone in HRZone.allCases.reversed() {
            if bpm >= range(for: zone).lower { return zone }
        }
        return nil
    }
}
