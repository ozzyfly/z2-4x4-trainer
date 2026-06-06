import SwiftUI

// MARK: - Card

/// Applies the standard card surface: rounded rect, secondary-system fill,
/// padding, and a subtle shadow that reads well in light and dark.
struct CardModifier: ViewModifier {
    var padding: CGFloat = Spacing.lg

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                    .fill(Theme.surface)
            )
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

extension View {
    /// Wraps the view in the standard card surface.
    func card(padding: CGFloat = Spacing.lg) -> some View {
        modifier(CardModifier(padding: padding))
    }
}

/// Container wrapper equivalent of `.card()` for inline use: `Card { ... }`.
struct Card<Content: View>: View {
    var padding: CGFloat
    @ViewBuilder var content: Content

    init(padding: CGFloat = Spacing.lg, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content.card(padding: padding)
    }
}

// MARK: - SectionHeader

/// Uppercase, tracked, secondary-colored section label.
struct SectionHeader: View {
    let title: String

    init(_ title: String) { self.title = title }

    var body: some View {
        Text(title.uppercased())
            .font(.caption.weight(.semibold))
            .tracking(0.8)
            .foregroundStyle(Theme.secondaryLabel)
            .accessibilityAddTraits(.isHeader)
    }
}

// MARK: - TargetBar

/// Sleek capsule progress bar with an animated accent fill.
/// Shows "x / y unit" and a checkmark when the target is met.
struct TargetBar: View {
    let done: Int
    let target: Int
    var unit: String = "min"
    var label: String = "Daily target"

    @State private var animatedFraction: Double = 0

    private var fraction: Double {
        guard target > 0 else { return 1 }
        return min(Double(done) / Double(target), 1)
    }

    private var isMet: Bool { done >= target }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(alignment: .firstTextBaseline) {
                Text("\(done) / \(target) \(unit)")
                    .numericStyle(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.label)
                Spacer()
                if isMet {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Theme.accent)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Text("\(max(target - done, 0)) to go")
                        .font(.caption)
                        .foregroundStyle(Theme.secondaryLabel)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Theme.accent.opacity(0.15))
                    Capsule()
                        .fill(Theme.accent)
                        .frame(width: max(geo.size.width * animatedFraction, animatedFraction > 0 ? 8 : 0))
                }
            }
            .frame(height: 10)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) {
                animatedFraction = fraction
            }
        }
        .onChange(of: fraction) { _, newValue in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) {
                animatedFraction = newValue
            }
        }
    }

    private var accessibilityText: String {
        let status = isMet ? "complete" : "\(max(target - done, 0)) \(unit) remaining"
        return "\(label), \(done) of \(target) \(unit), \(status)"
    }
}

// MARK: - PrimaryButton

/// Filled, rounded, bold accent button style.
struct PrimaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .fill(Theme.accent)
            )
            .opacity(configuration.isPressed ? 0.8 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - ZoneChip

/// Small pill showing a zone band, e.g. "Zone 2 · 114–133".
struct ZoneChip: View {
    let title: String
    let range: String
    var color: Color = Theme.accent

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.label)
            Text("·")
                .foregroundStyle(Theme.secondaryLabel)
            Text(range)
                .numericStyle(.caption)
                .foregroundStyle(Theme.secondaryLabel)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(
            Capsule().fill(Theme.plainBackground)
        )
        .overlay(
            Capsule().strokeBorder(Theme.separator.opacity(0.6), lineWidth: 0.5)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(range)")
    }
}
