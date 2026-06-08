import SwiftUI

/// Shared visual tokens for interval kinds, used by both the iOS workout-detail
/// list and the watch live-workout banner so the color/glyph mapping is defined
/// exactly once.
///
/// Color is paired with a `glyph` (a non-color signal) so adopting screens can
/// convey an interval kind without relying on color alone.
public extension IntervalKind {
    /// Banner color. warmup blue, hard red, recovery green, cooldown teal —
    /// identical across phone and watch.
    var bannerColor: Color {
        switch self {
        case .warmup: return .blue
        case .hard: return .red
        case .recovery: return .green
        case .cooldown: return .teal
        }
    }

    /// SF Symbol conveying the interval kind without color.
    var glyph: String {
        switch self {
        case .warmup: return "figure.walk"
        case .hard: return "bolt.fill"
        case .recovery: return "arrow.down.heart.fill"
        case .cooldown: return "wind"
        }
    }
}
