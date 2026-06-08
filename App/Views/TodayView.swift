import SwiftUI
import SwiftData
import SharedCore

/// Today's prescribed workout, personalised zones, and progress toward the daily target.
struct TodayView: View {
    let profile: ProfileRecord
    let health: HealthStore
    @Environment(\.modelContext) private var context
    @Query(sort: \WorkoutLog.date, order: .reverse) private var logs: [WorkoutLog]

    var body: some View {
        let p = profile.domain
        let calc = HRZoneCalculator(profile: p)
        let plan = TrainingPlan.weekly(for: p.goal)
        let today = plan.session(on: .now)
        let daily = TargetsCalculator.daily(profile: p, plan: plan)
        let progress = TargetProgress(done: todaysMinutes, target: daily.trainingMinutes)
        let isRest = today.type == .rest

        let history = logs.map {
            WorkoutRecord(date: $0.date, type: $0.type, durationMin: $0.durationMin, energyKcal: $0.activeEnergyKcal)
        }
        let adapted = PlanProgression.adjust(base: plan, history: history, profile: p)

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    header

                    if let readiness = health.readiness {
                        readinessSection(readiness)
                    }

                    StreakBanner(
                        currentWeeks: StreakCalculator.currentWeeks(in: history),
                        longestWeeks: StreakCalculator.longestWeeks(in: history)
                    )

                    coachSection(base: plan, adapted: adapted)

                    sessionSection(today: today, calc: calc, isRest: isRest)

                    zonesSection(calc: calc)

                    targetSection(progress: progress)

                    actionsSection(today: today, calc: calc, isRest: isRest)
                }
                .padding(Spacing.lg)
            }
            .background(Theme.background)
            .navigationTitle("Today")
        }
        .tint(Theme.accent)
        .sensoryFeedback(.success, trigger: progress.isMet)
        .task {
            if health.authorized {
                await health.refresh(context: context)
            }
        }
    }

    // MARK: - Sections

    private var header: some View {
        Text(Self.dateFormatter.string(from: .now))
            .font(.rounded(.headline, weight: .medium))
            .foregroundStyle(Theme.secondaryLabel)
    }

    private func readinessSection(_ readiness: ReadinessScore) -> some View {
        let color = readinessColor(readiness.label)
        return VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Readiness")
            Card {
                HStack(alignment: .center, spacing: Spacing.md) {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.12))
                            .frame(width: 56, height: 56)
                        Text("\(readiness.value)")
                            .numericStyle(.title2.weight(.bold))
                            .foregroundStyle(color)
                    }
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        HStack(spacing: Spacing.xs) {
                            // Glyph + text carry the state without relying on color.
                            Image(systemName: readinessGlyph(readiness.label))
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(color)
                            Text(readinessTitle(readiness.label))
                                .font(.rounded(.headline, weight: .semibold))
                                .foregroundStyle(Theme.label)
                        }
                        Text(readiness.label.recommendation)
                            .font(.subheadline)
                            .foregroundStyle(Theme.secondaryLabel)
                    }
                    Spacer(minLength: 0)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(
                    "Readiness \(readiness.value), \(readinessTitle(readiness.label)), \(readiness.label.recommendation)"
                )
            }
        }
    }

    private func readinessTitle(_ label: ReadinessLabel) -> String {
        switch label {
        case .goHard: return "Go hard"
        case .steady: return "Steady"
        case .easy:   return "Take it easy"
        }
    }

    private func readinessColor(_ label: ReadinessLabel) -> Color {
        switch label {
        case .goHard: return Theme.success
        case .steady: return Theme.info
        case .easy:   return Theme.warning
        }
    }

    private func readinessGlyph(_ label: ReadinessLabel) -> String {
        switch label {
        case .goHard: return "bolt.fill"
        case .steady: return "equal.circle.fill"
        case .easy:   return "moon.fill"
        }
    }

    private func coachSection(base: TrainingPlan, adapted: TrainingPlan) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Your coach")
            Card {
                HStack(alignment: .top, spacing: Spacing.md) {
                    Image(systemName: "figure.run.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Theme.accent)
                        .frame(width: 44, height: 44)
                        .background(Theme.accent.opacity(0.12), in: Circle())
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(weekSummary(for: adapted))
                            .font(.rounded(.headline, weight: .semibold))
                            .foregroundStyle(Theme.label)
                        Text(coachingTip(base: base, adapted: adapted))
                            .font(.subheadline)
                            .foregroundStyle(Theme.secondaryLabel)
                    }
                    Spacer(minLength: 0)
                }
            }
        }
    }

    private func weekSummary(for plan: TrainingPlan) -> String {
        let zone2Count = plan.sessions.filter { $0.type == .zone2 }.count
        let hardCount = plan.weeklyHardSessions
        return "This week: \(zone2Count) Zone 2 + \(hardCount) × 4×4, ~\(plan.weeklyTrainingMinutes) min"
    }

    private func coachingTip(base: TrainingPlan, adapted: TrainingPlan) -> String {
        let baseMin = base.weeklyTrainingMinutes
        let adaptedMin = adapted.weeklyTrainingMinutes
        if adaptedMin > baseMin {
            return "Progressing — nice consistency!"
        } else if adaptedMin < baseMin {
            return "Deload week — keep it easy."
        } else {
            return "Holding steady — finish this week strong."
        }
    }

    @ViewBuilder
    private func sessionSection(today: PlannedSession, calc: HRZoneCalculator, isRest: Bool) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Today's session")

            if isRest {
                Card {
                    HStack(spacing: Spacing.md) {
                        Image(systemName: today.type.systemImage)
                            .font(.title2)
                            .foregroundStyle(Theme.accent)
                            .frame(width: 44, height: 44)
                            .background(Theme.accent.opacity(0.12), in: Circle())
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Rest day")
                                .font(.rounded(.title3, weight: .semibold))
                                .foregroundStyle(Theme.label)
                            Text("Recover well.")
                                .font(.subheadline)
                                .foregroundStyle(Theme.secondaryLabel)
                        }
                        Spacer()
                    }
                }
            } else {
                NavigationLink {
                    WorkoutDetailView(type: today.type, calc: calc)
                } label: {
                    HStack(spacing: Spacing.md) {
                        Image(systemName: today.type.systemImage)
                            .font(.title2)
                            .foregroundStyle(Theme.accent)
                            .frame(width: 44, height: 44)
                            .background(Theme.accent.opacity(0.12), in: Circle())
                        VStack(alignment: .leading, spacing: 2) {
                            Text(today.type.displayName)
                                .font(.rounded(.title3, weight: .semibold))
                                .foregroundStyle(Theme.label)
                            Text("\(today.durationMin) min")
                                .numericStyle(.subheadline)
                                .foregroundStyle(Theme.secondaryLabel)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.secondaryLabel)
                    }
                    .card()
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func zonesSection(calc: HRZoneCalculator) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Your zones")
            Card {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    HStack(spacing: Spacing.sm) {
                        ZoneChip(title: "Zone 2", range: rangeText(calc.zone2), color: HRZone.zone2.color)
                        ZoneChip(title: "4×4 hard", range: rangeText(calc.fourByFourHard), color: HRZone.zone4.color)
                    }
                    ZoneChip(title: "Max HR", range: "\(calc.maxHR) bpm", color: HRZone.zone5.color)
                }
            }
        }
    }

    private func targetSection(progress: TargetProgress) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Daily target")
            Card {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    TargetBar(done: progress.done, target: progress.target)
                    if health.todayEnergy > 0 {
                        Divider()
                        HStack {
                            Label {
                                Text("Active energy")
                                    .font(.subheadline)
                                    .foregroundStyle(Theme.secondaryLabel)
                            } icon: {
                                Image(systemName: "flame.fill")
                                    .foregroundStyle(.orange)
                            }
                            Spacer()
                            Text("\(health.todayEnergy) kcal")
                                .numericStyle(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.label)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func actionsSection(today: PlannedSession, calc: HRZoneCalculator, isRest: Bool) -> some View {
        VStack(spacing: Spacing.md) {
            if !isRest {
                NavigationLink {
                    WorkoutDetailView(type: today.type, calc: calc)
                } label: {
                    Label("Start workout", systemImage: "play.fill")
                }
                .buttonStyle(PrimaryButton())
            }

            NavigationLink {
                ManualEntryView(defaultType: isRest ? .zone2 : today.type)
            } label: {
                Label("Log a workout", systemImage: "plus.circle.fill")
            }
            .buttonStyle(SecondaryButton())
        }
    }

    // MARK: - Helpers

    private func rangeText(_ range: HRRange) -> String {
        "\(range.lower)–\(range.upper)"
    }

    private var todaysMinutes: Int {
        let cal = Calendar.current
        return logs.filter { cal.isDateInToday($0.date) }.reduce(0) { $0 + $1.durationMin }
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f
    }()
}

/// Display helpers shared by the workout screens.
extension SessionType {
    var displayName: String {
        switch self {
        case .zone2: return "Zone 2"
        case .norwegian4x4: return "Norwegian 4×4"
        case .rest: return "Rest"
        }
    }

    var systemImage: String {
        switch self {
        case .zone2: return "figure.run"
        case .norwegian4x4: return "bolt.heart.fill"
        case .rest: return "moon.zzz.fill"
        }
    }
}

struct SessionRow: View {
    let type: SessionType
    let durationMin: Int

    var body: some View {
        Label {
            VStack(alignment: .leading) {
                Text(type.displayName).font(.headline)
                Text("\(durationMin) min").font(.caption).foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: type.systemImage)
        }
    }
}

struct ZoneRow: View {
    let title: String
    let range: HRRange

    var body: some View {
        LabeledContent(title, value: "\(range.lower)–\(range.upper) bpm")
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ProfileRecord.self, WorkoutLog.self, configurations: config)
    let profile = ProfileRecord(age: 30, sex: .male, weightKg: 80, heightCm: 180)
    container.mainContext.insert(profile)
    container.mainContext.insert(WorkoutLog(type: .zone2, durationMin: 20, activeEnergyKcal: 180))
    let health = HealthStore(provider: PreviewHealthService())
    return TodayView(profile: profile, health: health)
        .modelContainer(container)
}
