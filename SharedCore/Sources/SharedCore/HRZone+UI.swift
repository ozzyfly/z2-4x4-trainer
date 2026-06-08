import SwiftUI

/// Shared visual tokens for heart-rate zones, used by both the iOS and watchOS
/// targets so the color/name/glyph mapping is defined exactly once.
///
/// Color is paired with a `glyph` (a non-color signal) so adopting screens can
/// convey a zone without relying on color alone.
public extension HRZone {
    /// Human-readable zone name, e.g. "Zone 2".
    var displayName: String {
        switch self {
        case .zone1: return "Zone 1"
        case .zone2: return "Zone 2"
        case .zone3: return "Zone 3"
        case .zone4: return "Zone 4"
        case .zone5: return "Zone 5"
        }
    }

    /// Zone accent color. z1 gray, z2 green, z3 blue, z4 orange, z5 red —
    /// identical across phone and watch.
    var color: Color {
        switch self {
        case .zone1: return .gray
        case .zone2: return .green
        case .zone3: return .blue
        case .zone4: return .orange
        case .zone5: return .red
        }
    }

    /// SF Symbol conveying the zone without color (the numbered ring).
    var glyph: String {
        switch self {
        case .zone1: return "1.circle.fill"
        case .zone2: return "2.circle.fill"
        case .zone3: return "3.circle.fill"
        case .zone4: return "4.circle.fill"
        case .zone5: return "5.circle.fill"
        }
    }
}
