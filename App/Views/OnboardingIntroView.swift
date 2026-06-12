import SwiftUI

/// Step 0 of onboarding: what the app is and its three core points, shown
/// before any data entry. `onContinue` advances to the profile form.
struct OnboardingIntroView: View {
    let onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Image(systemName: "bolt.heart.fill")
                        .font(.title)
                        .foregroundStyle(Theme.accent)
                        .frame(width: 52, height: 52)
                        .background(Theme.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
                    Text("Z2 / 4×4 Trainer")
                        .font(.rounded(.largeTitle, weight: .bold))
                        .foregroundStyle(Theme.label)
                    Text("Your personal cardio coach for building an aerobic base and lifting your fitness.")
                        .font(.subheadline)
                        .foregroundStyle(Theme.secondaryLabel)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Card {
                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        introPoint(
                            icon: "figure.run",
                            title: String(localized: "Workouts tuned to you"),
                            detail: String(localized: "Zone 2 easy days and Norwegian 4×4 intervals, prescribed from your personal heart-rate zones.")
                        )
                        introPoint(
                            icon: "heart.fill",
                            title: String(localized: "Works with Apple Health"),
                            detail: String(localized: "Pull heart rate, energy, and workouts from Apple Health — or log everything by hand.")
                        )
                        introPoint(
                            icon: "lock.fill",
                            title: String(localized: "Your data stays on your device"),
                            detail: String(localized: "No account, no server. Everything lives on your iPhone and Apple Watch.")
                        )
                    }
                }

                Button(action: onContinue) {
                    Label("Continue", systemImage: "arrow.right.circle.fill")
                }
                .buttonStyle(PrimaryButton())
            }
            .padding(Spacing.lg)
        }
        .background(Theme.background)
    }

    private func introPoint(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(Theme.accent)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(.rounded(.headline, weight: .semibold))
                    .foregroundStyle(Theme.label)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(Theme.secondaryLabel)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    OnboardingIntroView(onContinue: {})
}
