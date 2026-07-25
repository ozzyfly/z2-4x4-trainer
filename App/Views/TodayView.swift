import SwiftUI
import SwiftData
import SharedCore

/// Today's prescribed workout, personalised zones, and progress toward the daily target.
struct TodayView: View {
    let profile: ProfileRecord
    let health: HealthStore
    @Environment(\.modelContext) private var context
    @Environment(ProStore.self) private var pro
    @State private var showsPaywall = false
    @Query(sort: \WorkoutLog.date, order: .reverse) private var logs: [WorkoutLog]

    /// Prescribed minutes for the off-plan easy Zone 2 offered on a rest day.
    private static let easyZone2Minutes = 40

    /// Today's recommended 4×4 hard-block count, reduced on low-readiness days.
    private var recommendedFourByFourRepeats: Int {
        Norwegian4x4.recommendedRepeats(for: health.readiness?.label)
    }

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
        // Adaptive progression (auto progress/deload) is the Pro coach; free
        // users train on the solid base plan.
        let adapted = pro.isPro ? PlanProgression.adjust(base: plan, history: history, profile: p) : plan

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    header

                    // First run gets the welcome card; returning users get the
                    // session hero with a single, primary "Start" up top.
                    if logs.isEmpty {
                        welcomeSection(today: today, calc: calc, isRest: isRest)
                    } else {
                        sessionSection(today: today, calc: calc, isRest: isRest)
                    }

                    if let readiness = health.readiness {
                        readinessSection(readiness)
                    }

                    // Overtraining early warning that needs no sensors at all:
                    // acute (7-day) vs chronic (28-day) load from the logs alone.
                    trainingLoadSection(history: history)

                    coachSection(base: plan, adapted: adapted)

                    zonesSection(calc: calc)

                    targetSection(progress: progress)

                    if !logs.isEmpty {
                        actionsSection(today: today, calc: calc, isRest: isRest)
                    }
                }
                .padding(Spacing.lg)
            }
            .background(Theme.background)
            .navigationTitle("Today")
            .refreshable {
                if health.authorized {
                    await health.refresh(context: context)
                }
            }
            .sheet(isPresented: $showsPaywall) {
                ProPaywallView()
            }
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

    /// First-run welcome card: explains today's plan and offers the two ways to
    /// get a first workout in. Disappears once anything is logged.
    private func welcomeSection(today: PlannedSession, calc: HRZoneCalculator, isRest: Bool) -> some View {
        Card {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Label {
                    Text("Welcome! Let's get started.")
                        .font(.serif(.title3, weight: .semibold))
                        .foregroundStyle(Theme.label)
                } icon: {
                    Image(systemName: "hand.wave.fill")
                        .foregroundStyle(Theme.accent)
                }
                Text(isRest
                     ? String(localized: "Today is a rest day — but you can start with an easy Zone 2 session whenever you're ready.")
                     : String(localized: "Today's plan: \(today.type.displayName), \(today.durationMin) min. Start a guided session, or log a workout you've already done."))
                    .font(.subheadline)
                    .foregroundStyle(Theme.secondaryLabel)
                    .fixedSize(horizontal: false, vertical: true)

                NavigationLink {
                    WorkoutDetailView(type: isRest ? .zone2 : today.type,
                                      prescribedMinutes: isRest ? Self.easyZone2Minutes : today.durationMin,
                                      calc: calc, repeats: recommendedFourByFourRepeats)
                } label: {
                    Label("Start workout", systemImage: "play.fill")
                }
                .buttonStyle(PrimaryButton())

                NavigationLink {
                    ManualEntryView(defaultType: isRest ? .zone2 : today.type)
                } label: {
                    Label("Log manually", systemImage: "plus.circle.fill")
                }
                .buttonStyle(SecondaryButton())
            }
        }
    }

    private var header: some View {
        Text(Self.dateFormatter.string(from: .now))
            .font(.serif(.title3))
            .foregroundStyle(Theme.secondaryLabel)
    }

    @ViewBuilder
    private func readinessSection(_ readiness: ReadinessScore) -> some View {
        if pro.isPro {
            readinessFullSection(readiness)
        } else {
            // The safety layer stays free: today's label and its one-line
            // recommendation. The score, signals and explanation are Pro.
            let color = readinessColor(readiness.label)
            VStack(alignment: .leading, spacing: Spacing.sm) {
                SectionHeader("Readiness")
                Card {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: readinessGlyph(readiness.label))
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(color)
                            Text(readinessTitle(readiness.label))
                                .font(.serif(.title3, weight: .semibold))
                                .foregroundStyle(Theme.label)
                        }
                        Text(readiness.label.recommendation)
                            .font(.subheadline)
                            .foregroundStyle(Theme.secondaryLabel)
                        ProTeaserRow(title: "See your score and why") { showsPaywall = true }
                    }
                    .accessibilityElement(children: .contain)
                }
            }
        }
    }

    private func readinessFullSection(_ readiness: ReadinessScore) -> some View {
        let color = readinessColor(readiness.label)
        return VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Readiness")
            Card {
                HStack(alignment: .center, spacing: Spacing.md) {
                    ZStack {
                        Circle()
                            .stroke(Theme.separator, lineWidth: 5)
                        Circle()
                            .trim(from: 0, to: min(1, max(0, CGFloat(readiness.value) / 100)))
                            .stroke(color, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        Text("\(readiness.value)")
                            .font(.serif(.title3, weight: .bold))
                            .monospacedDigit()
                            .contentTransition(.numericText())
                            .foregroundStyle(color)
                    }
                    .frame(width: 56, height: 56)
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        HStack(spacing: Spacing.xs) {
                            // Glyph + text carry the state without relying on color.
                            Image(systemName: readinessGlyph(readiness.label))
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(color)
                            Text(readinessTitle(readiness.label))
                                .font(.serif(.title3, weight: .semibold))
                                .foregroundStyle(Theme.label)
                        }
                        Text(readiness.label.recommendation)
                            .font(.subheadline)
                            .foregroundStyle(Theme.secondaryLabel)
                        Text(readiness.explanation)
                            .font(.caption)
                            .foregroundStyle(Theme.secondaryLabel)
                            .fixedSize(horizontal: false, vertical: true)
                        Label {
                            Text(readiness.actionRecommendation)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Theme.label)
                                .fixedSize(horizontal: false, vertical: true)
                        } icon: {
                            Image(systemName: "figure.cooldown")
                                .foregroundStyle(color)
                        }
                    }
                    Spacer(minLength: 0)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(
                    "Readiness \(readiness.value), \(readinessTitle(readiness.label)), \(readiness.label.recommendation) \(readiness.explanation) \(readiness.actionRecommendation)"
                )
            }
        }
    }

    private func readinessTitle(_ label: ReadinessLabel) -> String {
        switch label {
        case .goHard: return String(localized: "Go hard")
        case .steady: return String(localized: "Steady")
        case .easy:   return String(localized: "Take it easy")
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

    /// Shown only when the acute:chronic workload ratio is in the caution or
    /// high-risk zone — silence is the normal state.
    @ViewBuilder
    private func trainingLoadSection(history: [WorkoutRecord]) -> some View {
        let load = TrainingLoad.assess(history: history)
        if load.level != .ok, let ratio = load.ratio {
            let color = load.level == .highRisk ? Theme.danger : Theme.warning
            VStack(alignment: .leading, spacing: Spacing.sm) {
                SectionHeader("Training load")
                Card {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        HStack(alignment: .top, spacing: Spacing.md) {
                            Image(systemName: "gauge.with.needle.fill")
                                .font(.title2)
                                .foregroundStyle(color)
                                .frame(width: 44, height: 44)
                                .background(color.opacity(0.12), in: Circle())
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                // The warning itself is free — it's a safety signal.
                                Text(load.level == .highRisk
                                     ? String(localized: "Ramping too fast")
                                     : String(localized: "Ramping fast"))
                                    .font(.serif(.title3, weight: .semibold))
                                    .foregroundStyle(Theme.label)
                                if pro.isPro {
                                    Text(String(localized: "This week is \(ratio.formatted(.number.precision(.fractionLength(1))))× your 4-week norm (\(load.acuteMinutes) vs ~\(load.chronicWeeklyMinutes) min). Consider easing — big jumps drive overtraining and injury."))
                                        .font(.subheadline)
                                        .foregroundStyle(Theme.secondaryLabel)
                                        .fixedSize(horizontal: false, vertical: true)
                                } else {
                                    Text("Consider easing this week.")
                                        .font(.subheadline)
                                        .foregroundStyle(Theme.secondaryLabel)
                                }
                            }
                            Spacer(minLength: 0)
                        }
                        if !pro.isPro {
                            ProTeaserRow(title: "See the load analysis") { showsPaywall = true }
                        }
                    }
                    .accessibilityElement(children: .contain)
                }
            }
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
                            .font(.serif(.title3, weight: .semibold))
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
        return String(localized: "This week: \(zone2Count) Zone 2 + \(hardCount) × 4×4, ~\(plan.weeklyTrainingMinutes) min")
    }

    private func coachingTip(base: TrainingPlan, adapted: TrainingPlan) -> String {
        let baseMin = base.weeklyTrainingMinutes
        let adaptedMin = adapted.weeklyTrainingMinutes
        if adaptedMin > baseMin {
            return String(localized: "Progressing — nice consistency!")
        } else if adaptedMin < baseMin {
            return String(localized: "Deload week — keep it easy.")
        } else {
            return String(localized: "Holding steady — finish this week strong.")
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
                                .font(.serif(.title2, weight: .semibold))
                                .foregroundStyle(Theme.label)
                            Text("Recover well.")
                                .font(.subheadline)
                                .foregroundStyle(Theme.secondaryLabel)
                        }
                        Spacer()
                    }
                }
            } else {
                Card {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        HStack(spacing: Spacing.md) {
                            Image(systemName: today.type.systemImage)
                                .font(.title2)
                                .foregroundStyle(Theme.accent)
                                .frame(width: 44, height: 44)
                                .background(Theme.accent.opacity(0.12), in: Circle())
                            VStack(alignment: .leading, spacing: 2) {
                                Text(today.type.displayName)
                                    .font(.serif(.title2, weight: .semibold))
                                    .foregroundStyle(Theme.label)
                                Text("\(today.durationMin) min")
                                    .numericStyle(.subheadline)
                                    .foregroundStyle(Theme.secondaryLabel)
                            }
                            Spacer()
                        }
                        NavigationLink {
                            WorkoutDetailView(type: today.type, prescribedMinutes: today.durationMin,
                                              calc: calc, repeats: recommendedFourByFourRepeats)
                        } label: {
                            Label("Start workout", systemImage: "play.fill")
                        }
                        .buttonStyle(PrimaryButton())
                    }
                }
            }

            // Let the athlete start the other main session on demand, any day.
            alternateWorkoutLink(today: today, calc: calc)
        }
    }

    /// A quiet link to start the *other* main workout (e.g. a Norwegian 4×4 on a
    /// Zone 2 day), so either is always one tap away regardless of today's plan.
    @ViewBuilder
    private func alternateWorkoutLink(today: PlannedSession, calc: HRZoneCalculator) -> some View {
        let altType: SessionType = today.type == .norwegian4x4 ? .zone2 : .norwegian4x4
        let altMinutes = altType == .norwegian4x4
            ? Norwegian4x4.totalDurationSec / 60
            : Self.easyZone2Minutes
        NavigationLink {
            WorkoutDetailView(type: altType, prescribedMinutes: altMinutes,
                              calc: calc, repeats: recommendedFourByFourRepeats)
        } label: {
            HStack(spacing: Spacing.xs) {
                Image(systemName: altType.systemImage)
                Text("Start a \(altType.displayName) instead")
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Theme.accent)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
    }

    private func zonesSection(calc: HRZoneCalculator) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Your zones")
            Card {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    // Side by side normally; stacks when large Dynamic Type would clip them.
                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: Spacing.sm) {
                            ZoneChip(title: "Zone 2", range: rangeText(calc.zone2), color: HRZone.zone2.color)
                            ZoneChip(title: "4×4 hard", range: rangeText(calc.fourByFourHard), color: HRZone.zone4.color)
                        }
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            ZoneChip(title: "Zone 2", range: rangeText(calc.zone2), color: HRZone.zone2.color)
                            ZoneChip(title: "4×4 hard", range: rangeText(calc.fourByFourHard), color: HRZone.zone4.color)
                        }
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
                                    .foregroundStyle(Theme.accent)
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

    private func actionsSection(today: PlannedSession, calc: HRZoneCalculator, isRest: Bool) -> some View {
        // Primary "Start" now lives in the session hero; this is the secondary log action.
        NavigationLink {
            ManualEntryView(defaultType: isRest ? .zone2 : today.type)
        } label: {
            Label("Log a workout", systemImage: "plus.circle.fill")
        }
        .buttonStyle(SecondaryButton())
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
        case .zone2: return String(localized: "Zone 2")
        case .norwegian4x4: return String(localized: "Norwegian 4×4")
        case .rest: return String(localized: "Rest")
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

extension ActivityLevel {
    /// Localized display name; the raw value is a storage detail, not UI text.
    var displayName: String {
        switch self {
        case .sedentary: return String(localized: "Sedentary")
        case .light: return String(localized: "Light")
        case .moderate: return String(localized: "Moderate")
        case .active: return String(localized: "Active")
        case .veryActive: return String(localized: "Very active")
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
        .environment(ProStore())
}
