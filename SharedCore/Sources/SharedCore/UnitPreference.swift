import Foundation

/// The user's preferred display units for body metrics (weight, height).
/// Storage and all training calculations stay metric; this only drives the display layer.
public enum UnitPreference: String, Codable, Sendable, CaseIterable {
    case metric
    case imperial

    /// The default preference for a locale: imperial for the US measurement
    /// system, metric for everything else (including UK, which mixes systems).
    public static func defaultValue(for locale: Locale) -> UnitPreference {
        locale.measurementSystem == .us ? .imperial : .metric
    }
}
