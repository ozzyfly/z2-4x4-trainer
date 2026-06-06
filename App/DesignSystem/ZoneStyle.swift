import SwiftUI
import SharedCore

/// iOS-target styling for heart-rate zones. Mirrors the watch's `HRZone.displayName/color`
/// mapping (z1 gray, z2 green, z3 blue, z4 orange, z5 red) so phone and watch agree.
extension HRZone {
    /// Human-readable zone name, e.g. "Zone 2".
    var label: String {
        switch self {
        case .zone1: return "Zone 1"
        case .zone2: return "Zone 2"
        case .zone3: return "Zone 3"
        case .zone4: return "Zone 4"
        case .zone5: return "Zone 5"
        }
    }

    /// Zone accent color, matching the watch face mapping.
    var color: Color {
        switch self {
        case .zone1: return .gray
        case .zone2: return .green
        case .zone3: return .blue
        case .zone4: return .orange
        case .zone5: return .red
        }
    }
}
