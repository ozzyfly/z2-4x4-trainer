import SwiftUI
import SwiftData
import SharedCore

/// Grid of unlockable achievement badges plus the weekly-streak banner.
/// Evaluates `Achievement.catalog` against logged workouts + fitness, renders unlocked
/// badges in accent and locked ones greyed with a lock overlay, and persists any newly
/// unlocked ids so future launches can tell new badges from celebrated ones.
struct AchievementsView: View {
    let profile: ProfileRecord
    let health: HealthStore

    @Environment(\.modelContext) private var context
    @Query(sort: \WorkoutLog.date, order: .reverse) private var logs: [WorkoutLog]
    @Query private var unlocks: [AchievementRecord]

    @State private var celebrate = false

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.md),
        GridItem(.flexible(), spacing: Spacing.md),
    ]

    /// Pure-domain history bridged from the SwiftData logs.
    private var history: [WorkoutRecord] {
        logs.map {
            WorkoutRecord(
                date: $0.date,
                type: $0.type,
                durationMin: $0.durationMin,
                energyKcal: $0.activeEnergyKcal
            )
        }
    }

    private var unlockedIds: Set<String> {
        AchievementEvaluator.unlocked(
            history: history,
            fitness: health.fitness,
            profile: profile.domain
        )
    }

    var body: some View {
        let unlocked = unlockedIds

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    streakSection

                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        SectionHeader("Badges")
                        LazyVGrid(columns: columns, spacing: Spacing.md) {
                            ForEach(Achievement.catalog) { achievement in
                                BadgeCard(
                                    achievement: achievement,
                                    isUnlocked: unlocked.contains(achievement.id)
                                )
                            }
                        }
                    }
                }
                .padding(Spacing.lg)
            }
            .background(Theme.background)
            .navigationTitle("Achievements")
        }
        .tint(Theme.accent)
        .celebration(isActive: $celebrate)
        .onAppear { persistNewlyUnlocked(unlocked) }
    }

    // MARK: - Sections

    private var streakSection: some View {
        StreakBanner(
            currentWeeks: StreakCalculator.currentWeeks(in: history),
            longestWeeks: StreakCalculator.longestWeeks(in: history)
        )
    }

    // MARK: - Persistence

    /// Inserts an `AchievementRecord` for any unlocked id not already persisted, and
    /// fires the celebration when at least one badge is newly unlocked.
    private func persistNewlyUnlocked(_ unlocked: Set<String>) {
        let known = Set(unlocks.map(\.id))
        let fresh = unlocked.subtracting(known)
        guard !fresh.isEmpty else { return }
        for id in fresh {
            context.insert(AchievementRecord(id: id))
        }
        celebrate = true
    }
}

// MARK: - BadgeCard

/// A single achievement badge: accent-filled when unlocked, greyed with a lock overlay when not.
private struct BadgeCard: View {
    let achievement: Achievement
    let isUnlocked: Bool

    var body: some View {
        Card {
            VStack(spacing: Spacing.sm) {
                ZStack(alignment: .bottomTrailing) {
                    Image(systemName: achievement.systemImage)
                        .font(.title)
                        .foregroundStyle(isUnlocked ? Theme.accent : Theme.secondaryLabel)
                        .frame(width: 56, height: 56)
                        .background(
                            (isUnlocked ? Theme.accent.opacity(0.15) : Theme.secondaryLabel.opacity(0.12)),
                            in: Circle()
                        )

                    if !isUnlocked {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundStyle(.white)
                            .padding(5)
                            .background(Theme.secondaryLabel, in: Circle())
                    }
                }

                Text(achievement.title)
                    .font(.rounded(.subheadline, weight: .semibold))
                    .foregroundStyle(isUnlocked ? Theme.label : Theme.secondaryLabel)
                    .multilineTextAlignment(.center)

                Text(achievement.detail)
                    .font(.caption)
                    .foregroundStyle(Theme.secondaryLabel)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .opacity(isUnlocked ? 1 : 0.6)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(achievement.title), \(isUnlocked ? "unlocked" : "locked"). \(achievement.detail)"
        )
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: ProfileRecord.self, WorkoutLog.self, AchievementRecord.self,
        configurations: config
    )
    let profile = ProfileRecord(age: 30, sex: .male, weightKg: 80, heightCm: 180)
    container.mainContext.insert(profile)
    container.mainContext.insert(WorkoutLog(type: .norwegian4x4, durationMin: 35, activeEnergyKcal: 320))
    return AchievementsView(profile: profile, health: HealthStore(provider: PreviewHealthService()))
        .modelContainer(container)
}
