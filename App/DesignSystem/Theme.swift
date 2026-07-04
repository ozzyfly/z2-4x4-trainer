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

/// Color tokens for the Hermès-inspired palette: warm ivory paper, espresso ink,
/// and a single refined orange accent. Each is an adaptive light/dark pair.
enum Theme {
    /// Screen background — warm ivory paper (deep warm charcoal in dark).
    static let background = Color(uiColor: .dynamic(light: 0xF4EFE4, dark: 0x1A1714))
    /// Plain background — a touch lighter than `background`.
    static let plainBackground = Color(uiColor: .dynamic(light: 0xFBF8F1, dark: 0x201C18))
    /// Card / surface fill — near-white warm card that sits on the ivory with a hairline.
    static let surface = Color(uiColor: .dynamic(light: 0xFFFEFB, dark: 0x26221C))
    /// Primary text — espresso ink (warm ivory in dark).
    static let label = Color(uiColor: .dynamic(light: 0x2A2521, dark: 0xF0E9DD))
    /// Secondary / supporting text — warm taupe.
    static let secondaryLabel = Color(uiColor: .dynamic(light: 0x8A7C6A, dark: 0xA89C8A))
    /// Hairline separators — warm, faint.
    static let separator = Color(uiColor: .dynamic(light: 0xE4DAC8, dark: 0x3A332B))
    /// Brand accent — Hermès-style refined orange (a little brighter in dark).
    static let accent = Color(uiColor: .dynamic(light: 0xDD5A12, dark: 0xF2772E))

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
    /// Monospaced-digit numeric styling for stats. SF (default) numerals — not
    /// rounded — so figures read editorial next to the serif headings, in keeping
    /// with the Hermès-style restraint of the rest of the chrome.
    func numericStyle(_ font: Font = .body) -> some View {
        self.font(font)
            .monospacedDigit()
            .fontDesign(.default)
    }
}

extension Font {
    /// Rounded variant of a system text style.
    static func rounded(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        .system(style, design: .rounded).weight(weight)
    }

    /// Serif (New York) variant of a system text style — the Hermès-style display
    /// face for titles and headings. Scales with Dynamic Type like any text style.
    static func serif(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        .system(style, design: .serif).weight(weight)
    }
}
