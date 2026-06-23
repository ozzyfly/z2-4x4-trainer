import SwiftUI
import SwiftData
import SharedCore

/// The weekly plan plus progress toward the weekly target.
struct WeekView: View {
    let profile: ProfileRecord
    @Query(sort: \WorkoutLog.date, order: .reverse) private var logs: [WorkoutLog]

    private static let weekdayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    var body: some View {
        let p = profile.domain
        let calc = HRZoneCalculator(profile: p)
        let plan = TrainingPlan.weekly(for: p.goal)
        let weekly = TargetsCalculator.weekly(profile: p, plan: plan)
        let sessions = plan.sessions.sorted { $0.day < $1.day }

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    planSection(sessions: sessions, calc: calc)
                    targetSection(weekly: weekly)
                }
                .padding(Spacing.lg)
            }
            .background(Theme.background)
            .navigationTitle("Week")
        }
        .tint(Theme.accent)
    }

    // MARK: - Sections

    private func planSection(sessions: [PlannedSession], calc: HRZoneCalculator) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("This week's plan")
            Card(padding: Spacing.xs) {
                VStack(spacing: 0) {
                    ForEach(Array(sessions.enumerated()), id: \.element.day) { index, s in
                        dayRow(session: s, calc: calc)
                        if index < sessions.count - 1 {
                            Divider()
                                .padding(.leading, Spacing.md)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func dayRow(session s: PlannedSession, calc: HRZoneCalculator) -> some View {
        let weekday = Self.weekdayNames[s.day - 1]
        if s.type == .rest {
            DayRow(weekday: weekday, title: "Rest", detail: nil, isRest: true, showsChevron: false)
        } else {
            NavigationLink {
                WorkoutDetailView(type: s.type, prescribedMinutes: s.durationMin, calc: calc)
            } label: {
                DayRow(
                    weekday: weekday,
                    title: s.type.displayName,
                    detail: "\(s.durationMin) min",
                    isRest: false,
                    showsChevron: true
                )
            }
            .buttonStyle(.plain)
        }
    }

    private func targetSection(weekly: WeeklyTargets) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Weekly target")
            Card {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    TargetBar(
                        done: weekMinutes,
                        target: weekly.trainingMinutes,
                        label: "Weekly target"
                    )

                    Divider()

                    statRow(
                        icon: "bolt.heart.fill",
                        iconColor: HRZone.zone4.color,
                        title: "Hard (4×4) sessions",
                        value: String(localized: "\(weekly.hardSessions)/week")
                    )

                    if let energy = weekly.activeEnergyKcal {
                        Divider()
                        statRow(
                            icon: "flame.fill",
                            iconColor: .orange,
                            title: "Exercise energy",
                            value: String(localized: "\(energy) kcal/week")
                        )
                    }
                }
            }
        }
    }

    private func statRow(icon: String, iconColor: Color, title: LocalizedStringKey, value: String) -> some View {
        HStack {
            Label {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(Theme.secondaryLabel)
            } icon: {
                Image(systemName: icon)
                    .foregroundStyle(iconColor)
            }
            Spacer()
            Text(value)
                .numericStyle(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.label)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(title) + Text(", \(value)"))
    }

    private var weekMinutes: Int {
        let cal = Calendar.current
        return logs
            .filter { cal.isDate($0.date, equalTo: .now, toGranularity: .weekOfYear) }
            .reduce(0) { $0 + $1.durationMin }
    }
}

/// A single weekday row in the plan card.
private struct DayRow: View {
    let weekday: String
    let title: String
    let detail: String?
    let isRest: Bool
    let showsChevron: Bool

    var body: some View {
        HStack(spacing: Spacing.md) {
            Text(weekday)
                .font(.rounded(.subheadline, weight: .semibold))
                .foregroundStyle(isRest ? Theme.secondaryLabel : Theme.label)
                // No hard width cap: let it scale with Dynamic Type instead of clipping.
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(minWidth: 40, alignment: .leading)

            Text(title)
                .font(.subheadline)
                .foregroundStyle(isRest ? Theme.secondaryLabel : Theme.label)

            Spacer()

            if let detail {
                Text(detail)
                    .numericStyle(.subheadline)
                    .foregroundStyle(Theme.secondaryLabel)
            }

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.secondaryLabel)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.md)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        if let detail {
            return "\(weekday), \(title), \(detail)"
        }
        return "\(weekday), \(title)"
    }
}
