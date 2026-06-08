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
    /// 2 pt — tightest gap (e.g. stacked label + value).
    static let xxs: CGFloat = 2
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

    // MARK: - Semantic status tokens
    //
    // Foreground colors for conveying state (readiness, fitness trend, HR zones,
    // required-field warnings). Each is an adaptive light/dark pair chosen so the
    // color, used as text or a glyph on `Theme.surface` / `Theme.background`,
    // clears the WCAG AA 4.5:1 contrast ratio in BOTH appearances.
    //
    // Contrast is achieved by deliberate color choice, not runtime computation —
    // the spec's "Accessible semantic color tokens" scenario is the guardrail, and
    // measured ratios are recorded in the PR description. Color must never be the
    // ONLY signal: callers pair these with a glyph, +/- sign, or text label (see
    // the `usability` / `accessibility-pass` changes that adopt them).

    /// Positive / ready / improving. Light #1B7F3B on white ≈ 5.0:1; dark #4ADE80 on #1C1C1E ≈ 9:1.
    static let success = Color(uiColor: .dynamic(light: 0x1B7F3B, dark: 0x4ADE80))
    /// Caution / required input missing. Light #B45309 on white ≈ 4.9:1; dark #FBBF24 on #1C1C1E ≈ 10:1.
    static let warning = Color(uiColor: .dynamic(light: 0xB45309, dark: 0xFBBF24))
    /// Negative / rest / declining. Light #C62828 on white ≈ 5.5:1; dark #F87171 on #1C1C1E ≈ 5.6:1.
    static let danger = Color(uiColor: .dynamic(light: 0xC62828, dark: 0xF87171))
    /// Neutral informational accent. Light #1565C0 on white ≈ 5.7:1; dark #60A5FA on #1C1C1E ≈ 6:1.
    static let info = Color(uiColor: .dynamic(light: 0x1565C0, dark: 0x60A5FA))
}

extension UIColor {
    /// Builds an adaptive color from two 0xRRGGBB literals (light, dark).
    static func dynamic(light: UInt32, dark: UInt32) -> UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(rgb: dark) : UIColor(rgb: light)
        }
    }

    /// Builds an opaque color from a 0xRRGGBB literal.
    convenience init(rgb: UInt32) {
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >> 8) & 0xFF) / 255,
            blue: CGFloat(rgb & 0xFF) / 255,
            alpha: 1
        )
    }
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
