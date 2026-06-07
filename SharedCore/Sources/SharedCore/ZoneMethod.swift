import Foundation

/// How heart-rate zones are derived from a profile.
public enum ZoneMethod: String, Codable, Sendable, CaseIterable {
    /// Percent of estimated maximum heart rate (220 − age, or override).
    case ageMax
    /// Karvonen / heart-rate-reserve: resting + pct·(max − resting). Needs a resting HR.
    case karvonen
    /// User-supplied custom bands, indexed by zone.
    case custom
}
