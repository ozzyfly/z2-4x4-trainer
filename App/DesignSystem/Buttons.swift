import SwiftUI

// MARK: - Press animation

/// Applies the press scale/opacity animation — but disables it under Reduce
/// Motion. Lives as a `ViewModifier` (not inline `.animation`) so it can read
/// the environment, which a `ButtonStyle` struct cannot do directly.
struct PressAnimation: ViewModifier {
    let isPressed: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content.animation(reduceMotion ? nil : .easeOut(duration: 0.15), value: isPressed)
    }
}

// MARK: - SecondaryButton

/// Subordinate counterpart to `PrimaryButton`: same size and full-width layout,
/// but a tinted (not filled) accent style so it reads as the lower-priority
/// action. Keeps a ≥44pt tap target and fires a selection haptic on press.
///
/// Use for secondary actions placed alongside a `PrimaryButton`
/// (e.g. "Log a workout" beside "Start workout").
struct SecondaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .textCase(.uppercase)
            .tracking(1.2)
            .foregroundStyle(Theme.accent)
            .frame(maxWidth: .infinity, minHeight: 44)
            .padding(.vertical, Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                    .fill(Theme.accent.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                    .strokeBorder(Theme.accent.opacity(0.35), lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.8 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .modifier(PressAnimation(isPressed: configuration.isPressed))
            .sensoryFeedback(.selection, trigger: configuration.isPressed)
    }
}

#Preview("Primary + Secondary") {
    VStack(spacing: Spacing.md) {
        Button("Start workout") {}
            .buttonStyle(PrimaryButton())
        Button("Log a workout") {}
            .buttonStyle(SecondaryButton())
    }
    .padding(Spacing.lg)
    .background(Theme.background)
}
