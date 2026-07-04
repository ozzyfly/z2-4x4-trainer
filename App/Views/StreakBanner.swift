import SwiftUI
import SharedCore

/// Compact card showing the user's current weekly training streak and their best ever.
/// When there is no active streak it nudges the user to start one this week.
struct StreakBanner: View {
    let currentWeeks: Int
    let longestWeeks: Int

    private var hasStreak: Bool { currentWeeks > 0 }

    var body: some View {
        if hasStreak {
            activeCard
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(accessibilityText)
        } else {
            // Keep children accessible so the CTA button is reachable by VoiceOver.
            emptyCard
        }
    }

    private var activeCard: some View {
        Card {
            HStack(spacing: Spacing.md) {
                streakIcon
                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "\(currentWeeks)-week streak"))
                        .font(.serif(.title2, weight: .bold))
                        .foregroundStyle(Theme.label)
                    Text(String(localized: "Longest: \(longestWeeks)"))
                        .font(.subheadline)
                        .foregroundStyle(Theme.secondaryLabel)
                }
                Spacer(minLength: 0)
            }
        }
    }

    private var emptyCard: some View {
        Card {
            HStack(spacing: Spacing.md) {
                streakIcon
                VStack(alignment: .leading, spacing: 2) {
                    Text("Start a streak this week")
                        .font(.serif(.title3, weight: .semibold))
                        .foregroundStyle(Theme.label)
                    Text(longestWeeks > 0 ? String(localized: "Your best: \(longestWeeks) weeks") : "Log a workout to begin.")
                        .font(.subheadline)
                        .foregroundStyle(Theme.secondaryLabel)
                }
                Spacer(minLength: 0)
                NavigationLink {
                    ManualEntryView()
                } label: {
                    Text("Log")
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.bordered)
                .tint(Theme.accent)
            }
        }
    }

    private var streakIcon: some View {
        Image(systemName: hasStreak ? "flame.fill" : "flame")
            .font(.title)
            .foregroundStyle(Theme.accent)
            .frame(width: 44, height: 44)
            .background(Theme.accent.opacity(0.12), in: Circle())
    }

    private var accessibilityText: String {
        if hasStreak {
            let weekWord = currentWeeks == 1 ? String(localized: "week") : String(localized: "weeks")
            return String(localized: "Current streak \(currentWeeks) \(weekWord). Longest streak \(longestWeeks) weeks.")
        } else if longestWeeks > 0 {
            return String(localized: "No active streak. Start one this week. Your longest streak was \(longestWeeks) weeks.")
        } else {
            return String(localized: "No active streak. Log a workout to start one this week.")
        }
    }
}

#Preview {
    VStack(spacing: Spacing.lg) {
        StreakBanner(currentWeeks: 4, longestWeeks: 7)
        StreakBanner(currentWeeks: 0, longestWeeks: 3)
        StreakBanner(currentWeeks: 0, longestWeeks: 0)
    }
    .padding(Spacing.lg)
    .background(Theme.background)
}
