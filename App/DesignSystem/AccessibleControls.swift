import SwiftUI

// MARK: - AccessibleStepper

/// A `Stepper` wrapper that exposes a single accessibility element with a
/// distinct label and value, an adjustable (increment/decrement) action, and a
/// ≥44pt tap target.
///
/// VoiceOver announces it as "<title>, <valueText>" with up/down adjust actions,
/// instead of the concatenated phrase a hand-rolled `Stepper("Age: 30", …)`
/// produces. The caller supplies `valueText` so the displayed and spoken value
/// match exactly (e.g. "30", "0.50 kg/week", "165 bpm").
struct AccessibleStepper<V: Strideable>: View {
    /// `LocalizedStringKey` so literal titles at call sites resolve through the
    /// String Catalog at runtime (a `String` parameter would render verbatim).
    let title: LocalizedStringKey
    @Binding var value: V
    let range: ClosedRange<V>
    var step: V.Stride = 1
    let valueText: String

    var body: some View {
        Stepper(value: $value, in: range, step: step) {
            HStack {
                Text(title)
                    .foregroundStyle(Theme.label)
                Spacer()
                Text(valueText)
                    .numericStyle(.body)
                    .foregroundStyle(Theme.secondaryLabel)
            }
        }
        .frame(minHeight: 44)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(valueText)
        .accessibilityHint("Swipe up or down to adjust")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                let next = value.advanced(by: step)
                if next <= range.upperBound { value = next }
            case .decrement:
                let next = value.advanced(by: -step)
                if next >= range.lowerBound { value = next }
            @unknown default:
                break
            }
        }
    }
}

#Preview("AccessibleStepper") {
    struct Demo: View {
        @State private var age = 30
        @State private var rate = 0.5
        var body: some View {
            VStack(spacing: Spacing.md) {
                AccessibleStepper(
                    title: "Age", value: $age, range: 12...100,
                    valueText: "\(age)"
                )
                Divider()
                AccessibleStepper(
                    title: "Rate", value: $rate, range: 0.25...1.0, step: 0.25,
                    valueText: String(format: "%.2f kg/week", rate)
                )
            }
            .card()
            .padding(Spacing.lg)
            .background(Theme.background)
        }
    }
    return Demo()
}
