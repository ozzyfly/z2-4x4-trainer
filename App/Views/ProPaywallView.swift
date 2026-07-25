import SwiftUI
import StoreKit
import SharedCore

/// The one-time Pro unlock sheet. Hermès restraint: serif headline, a short
/// list of what the coach's brain adds, one price, one quiet restore link.
struct ProPaywallView: View {
    @Environment(ProStore.self) private var pro
    @Environment(\.dismiss) private var dismiss
    @State private var showsCodeRedemption = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Z2/4×4 Pro")
                            .font(.serif(.largeTitle, weight: .semibold))
                            .foregroundStyle(Theme.label)
                        Text("One purchase, yours forever. No subscription — the app runs on your device, so there's nothing to rent.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.secondaryLabel)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        featureRow("waveform.path.ecg", "Readiness, in full",
                                   "The daily score with its HRV, resting-HR, wrist-temperature and sleep signals — not just the headline.")
                        featureRow("gauge.with.needle.fill", "Overtraining guard",
                                   "Acute-vs-chronic load analysis with the numbers behind every warning.")
                        featureRow("figure.run.circle.fill", "Adaptive coaching",
                                   "Your weekly plan progresses and deloads with your actual training.")
                        featureRow("chart.line.uptrend.xyaxis", "Fitness trend",
                                   "VO₂max trajectory from Apple Health, charted over months.")
                        featureRow("square.and.arrow.up", "Export",
                                   "Your complete history as CSV or JSON — your data is yours.")
                    }

                    VStack(spacing: Spacing.md) {
                        if let product = pro.product {
                            Button {
                                Task {
                                    if await pro.purchase() { dismiss() }
                                }
                            } label: {
                                Text("Unlock Pro · \(product.displayPrice)")
                            }
                            .buttonStyle(PrimaryButton())
                            .disabled(pro.isPurchasing)
                        } else {
                            // Product unavailable (offline / not yet configured).
                            Text("The App Store is unreachable right now — try again later.")
                                .font(.footnote)
                                .foregroundStyle(Theme.secondaryLabel)
                                .frame(maxWidth: .infinity)
                        }

                        Button {
                            Task {
                                await pro.restore()
                                if pro.isPro { dismiss() }
                            }
                        } label: {
                            Text("Restore purchase")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(Theme.accent)
                        }
                        .disabled(pro.isPurchasing)

                        Button {
                            showsCodeRedemption = true
                        } label: {
                            Text("Redeem code")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(Theme.accent)
                        }
                        .disabled(pro.isPurchasing)

                        Text("Everything you already use stays free: workouts on iPhone and Apple Watch, plans, zones, Apple Health sync.")
                            .font(.caption2)
                            .foregroundStyle(Theme.secondaryLabel)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(Spacing.lg)
            }
            .background(Theme.background)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .tint(Theme.accent)
        .offerCodeRedemption(isPresented: $showsCodeRedemption)
        .onChange(of: pro.isPro) { _, isPro in
            if isPro { dismiss() }
        }
    }

    private func featureRow(_ icon: String, _ title: LocalizedStringKey, _ detail: LocalizedStringKey) -> some View {
        IconDetailRow(icon: icon, title: title, detail: detail)
    }
}

/// A quiet, tappable teaser shown where a Pro feature would render for free
/// users — one line + chevron, never a nag.
struct ProTeaserRow: View {
    let title: LocalizedStringKey
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundStyle(Theme.accent)
                    .accessibilityHidden(true)
                Text(title)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.label)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Theme.separator)
                    .accessibilityHidden(true)
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .fill(Theme.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .strokeBorder(Theme.separator, lineWidth: 0.75)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ProPaywallView()
        .environment(ProStore())
}
