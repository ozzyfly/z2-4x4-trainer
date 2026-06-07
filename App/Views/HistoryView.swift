import SwiftUI
import SwiftData
import Charts
import SharedCore

/// Charts this week's training minutes by weekday and the recent body-weight trend.
struct HistoryView: View {
    let health: HealthStore
    @Query(sort: \WorkoutLog.date, order: .reverse) private var logs: [WorkoutLog]

    private struct DayMinutes: Identifiable {
        let id: Int          // 0 = Mon … 6 = Sun
        let label: String
        let minutes: Int
    }

    private struct WeightPoint: Identifiable {
        let id = UUID()
        let date: Date
        let kg: Double
    }

    private struct FitnessPoint: Identifiable {
        let id = UUID()
        let date: Date
        let value: Double
    }

    private static let weekdayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    private var weeklyByWeekday: [DayMinutes] {
        let samples = logs.map { ActivitySample(date: $0.date, minutes: $0.durationMin, energyKcal: $0.activeEnergyKcal) }
        let totals = ActivityAggregator.weeklyMinutesByWeekday(in: samples, for: .now)
        return totals.enumerated().map { idx, mins in
            DayMinutes(id: idx, label: Self.weekdayLabels[idx], minutes: mins)
        }
    }

    private var weightPoints: [WeightPoint] {
        health.weightSeries.map { WeightPoint(date: $0.date, kg: $0.kg) }
    }

    private var hasTrainingData: Bool {
        weeklyByWeekday.contains { $0.minutes > 0 }
    }

    // MARK: - Share summary

    /// This week's logged records mapped to the pure-domain type.
    private var weekRecords: [WorkoutRecord] {
        logs.map {
            WorkoutRecord(
                date: $0.date,
                type: $0.type,
                durationMin: $0.durationMin,
                energyKcal: $0.activeEnergyKcal
            )
        }
    }

    private var thisWeekMinutes: Int {
        ActivityAggregator.weeklyMinutes(in: weekRecords.map(\.sample), for: .now)
    }

    private var thisWeekSessions: Int {
        let cal = Calendar.current
        return logs.filter { cal.isDate($0.date, equalTo: .now, toGranularity: .weekOfYear) }.count
    }

    private var streakWeeks: Int {
        StreakCalculator.currentWeeks(in: weekRecords)
    }

    private var shareCard: ShareCard {
        ShareCard(
            weekStart: .now,
            minutes: thisWeekMinutes,
            sessions: thisWeekSessions,
            streakWeeks: streakWeeks
        )
    }

    private var textSummary: String {
        "Z2/4×4 Trainer — this week: \(thisWeekMinutes) min across \(thisWeekSessions) session(s), \(streakWeeks)-week streak."
    }

    /// Renders the share card to a `UIImage` on the main actor. `ImageRenderer`
    /// is `@MainActor`; this is only called from the main-actor `body`.
    @MainActor
    private func renderShareImage() -> UIImage? {
        let renderer = ImageRenderer(content: shareCard)
        renderer.proposedSize = ProposedViewSize(ShareCard.size)
        // 1x of a 1080-pt-wide card is already crisp; bump for extra sharpness.
        renderer.scale = 2
        return renderer.uiImage
    }

    private var shareLink: some View {
        Group {
            if let image = renderShareImage() {
                ShareLink(
                    item: Image(uiImage: image),
                    preview: SharePreview("This week on Z2/4×4 Trainer", image: Image(uiImage: image))
                ) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            } else {
                // Fallback: share a plain text summary if rendering fails.
                ShareLink(item: textSummary) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    minutesSection
                    fitnessSection
                    weightSection
                }
                .padding(Spacing.lg)
            }
            .background(Theme.background)
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    shareLink
                }
            }
        }
        .tint(Theme.accent)
    }

    // MARK: - Sections

    private var minutesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("This week's training minutes")
            Card {
                if hasTrainingData {
                    Chart(weeklyByWeekday) { day in
                        BarMark(
                            x: .value("Day", day.label),
                            y: .value("Minutes", day.minutes)
                        )
                        .foregroundStyle(Theme.accent)
                        .cornerRadius(Radius.sm)
                    }
                    .frame(height: 200)
                } else {
                    ContentUnavailableView(
                        "No workouts yet",
                        systemImage: "chart.bar.fill",
                        description: Text("Log a workout or connect Apple Health to see your week.")
                    )
                }
            }
        }
    }

    private var fitnessSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("VO2 max trend")
            Card {
                if let trend = health.fitness {
                    let points = trend.samples.map { FitnessPoint(date: $0.date, value: $0.value) }
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Chart(points) { point in
                            LineMark(
                                x: .value("Date", point.date),
                                y: .value("VO2 max", point.value)
                            )
                            .foregroundStyle(Theme.accent)
                            .interpolationMethod(.catmullRom)
                            PointMark(
                                x: .value("Date", point.date),
                                y: .value("VO2 max", point.value)
                            )
                            .foregroundStyle(Theme.accent)
                        }
                        .chartYScale(domain: .automatic(includesZero: false))
                        .frame(height: 200)

                        HStack(spacing: Spacing.xs) {
                            Text("Latest \(trend.latest, format: .number.precision(.fractionLength(1)))")
                                .numericStyle(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.label)
                            Text("·")
                                .foregroundStyle(Theme.secondaryLabel)
                            Image(systemName: trend.deltaFromFirst >= 0 ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                                .font(.caption2)
                                .foregroundStyle(trend.deltaFromFirst >= 0 ? Theme.accent : .orange)
                            Text(abs(trend.deltaFromFirst), format: .number.precision(.fractionLength(1)))
                                .numericStyle(.subheadline)
                                .foregroundStyle(Theme.secondaryLabel)
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "No fitness data",
                        systemImage: "heart.text.square.fill",
                        description: Text("Connect Apple Health to see your fitness trend.")
                    )
                }
            }
        }
    }

    private var weightSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Body weight trend")
            Card {
                if weightPoints.count > 1 {
                    Chart(weightPoints) { point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("Weight (kg)", point.kg)
                        )
                        .foregroundStyle(HRZone.zone2.color)
                        .interpolationMethod(.catmullRom)
                        PointMark(
                            x: .value("Date", point.date),
                            y: .value("Weight (kg)", point.kg)
                        )
                        .foregroundStyle(HRZone.zone2.color)
                    }
                    .chartYScale(domain: .automatic(includesZero: false))
                    .frame(height: 200)
                } else {
                    ContentUnavailableView(
                        "No weight data",
                        systemImage: "scalemass.fill",
                        description: Text("Connect Apple Health in Settings to track your weight.")
                    )
                }
            }
        }
    }
}

#Preview {
    HistoryView(health: HealthStore(provider: PreviewHealthService()))
        .modelContainer(for: [ProfileRecord.self, WorkoutLog.self], inMemory: true)
}
