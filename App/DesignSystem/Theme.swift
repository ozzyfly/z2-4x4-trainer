import SwiftUI

/// Spacing scale used across the app for consistent, airy layouts.
enum Spacing {
    /// 4 pt
    static let xs: CGFloat = 4
    /// 8 pt
    static let sm: CGFloat = 8
    /// 12 pt
    static let md: CGFloat = 12
    /// 16 pt
    static let lg: CGFloat = 16
    /// 20 pt
    static let xl: CGFloat = 20
    /// 28 pt
    static let xxl: CGFloat = 28
}

/// Corner-radius scale.
enum Radius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 22
    /// Fully rounded pill.
    static let pill: CGFloat = 999
}

/// Color tokens that adapt to light/dark via the system semantic colors.
enum Theme {
    /// Screen background for grouped, card-led layouts.
    static let background = Color(.systemGroupedBackground)
    /// Plain background.
    static let plainBackground = Color(.systemBackground)
    /// Card / surface fill.
    static let surface = Color(.secondarySystemBackground)
    /// Primary text.
    static let label = Color(.label)
    /// Secondary / supporting text.
    static let secondaryLabel = Color(.secondaryLabel)
    /// Hairline separators.
    static let separator = Color(.separator)
    /// Brand accent (from AccentColor asset; adapts light/dark).
    /// Loaded by name so it applies even when the project's global accent
    /// build setting isn't pointed at the asset.
    static let accent = Color("AccentColor", bundle: .main)
}

extension Text {
    /// Rounded, monospaced-digit numeric styling for stats.
    func numericStyle(_ font: Font = .body) -> some View {
        self.font(font)
            .monospacedDigit()
            .fontDesign(.rounded)
    }
}

extension Font {
    /// Rounded variant of a system text style.
    static func rounded(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        .system(style, design: .rounded).weight(weight)
    }
}
