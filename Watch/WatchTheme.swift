import SwiftUI

/// Brand tokens for the watch app. watchOS renders on black, so only the
/// dark-appearance values from the iPhone `Theme` are mirrored here.
/// Keep in sync with App/DesignSystem/Theme.swift.
enum WatchTheme {
    /// Hermès-style refined orange — the single brand accent (Theme.accent dark).
    static let accent = Color(red: 0xF2 / 255, green: 0x77 / 255, blue: 0x2E / 255)
    /// Warm ivory for primary text on black (Theme.label dark).
    static let ivory = Color(red: 0xF0 / 255, green: 0xE9 / 255, blue: 0xDD / 255)
    /// Warm taupe for supporting text (Theme.secondaryLabel dark).
    static let taupe = Color(red: 0xA8 / 255, green: 0x9C / 255, blue: 0x8A / 255)
}
