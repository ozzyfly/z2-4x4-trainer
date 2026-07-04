import SwiftUI

/// Shared display tokens for live coaching cues, so the watch live-workout view
/// renders them consistently with one source of truth.
public extension CoachingCue {
    /// Short on-screen label with a directional arrow.
    var label: String {
        switch self {
        case .push: return String(localized: "PUSH ▲", bundle: .module)
        case .easeOff: return String(localized: "EASE OFF ▼", bundle: .module)
        }
    }

    /// VoiceOver phrase (no arrow glyph).
    var accessibilityLabel: String {
        switch self {
        case .push: return String(localized: "Push harder", bundle: .module)
        case .easeOff: return String(localized: "Ease off", bundle: .module)
        }
    }

    /// Accent color: push is urgent (orange), ease-off is calming (blue).
    var tint: Color {
        switch self {
        case .push: return .orange
        case .easeOff: return .blue
        }
    }
}
