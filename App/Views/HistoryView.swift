import SwiftUI
import SwiftData
import Charts
import SharedCore
import UniformTypeIdentifiers

/// Workout history as a shareable CSV file (`workouts.csv`).
struct WorkoutCSVExport: Transferable {
    let text: String

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .commaSeparatedText) { Data($0.text.utf8) }
            .suggestedFileName("workouts.csv")
    }
}

/// Workout history as a shareable JSON file (`workouts.json`).
struct WorkoutJSONExport: Transferable {
    let data: Data

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .json) { $0.data }
            .suggestedFileName("workouts.json")
    }
}

/// Charts this week's training minutes by weekday and the recent body-weight trend.
struct HistoryView: View {
    let health: HealthStore
    @Query(sort: \WorkoutLog.date, order: .reverse) private var logs: [WorkoutLog]
    @Query private var profiles: [ProfileRecord]

    /// Display units from the profile; metric when no profile exists.
    private var units: UnitPreference { profiles.first?.units ?? .metric }

    /// Chart height scales with Dynamic Type but is clamped so large accessibility
    /// sizes don't blow the charts up off-screen (or shrink them away).
    @ScaledMetric(relativeTo: .body) private var scaledChartHeight: CGFloat = 200
    private var chartHeight: CGFloat { min(max(scaledChartHeight, 160), 280) }

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

    /// Weight value in the preferred display units (storage stays kg).
    private func displayWeight(_ kg: Double) -> Double {
        units == .imperial ? UnitConvert.kgToLb(kg) : kg
    }

    private var weightAxisLabel: String {
        units == .imperial ? String(localized: "Weight (lb)") : String(localized: "Weight (kg)")
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
        String(localized: "Z2/4×4 Trainer — this week: \(thisWeekMinutes) min across \(thisWeekSessions) session(s), \(streakWeeks)-week streak.")
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

    // MARK: - Export

    /// Every logged workout as a flat export row, oldest first. `source` says
    /// whether the entry is linked to Apple Health (`health`) or app-only (`manual`).
    private var exportRows: [WorkoutExportRow] {
        logs.reversed().map { log in
            WorkoutExportRow(
                date: log.date,
                type: log.type.rawValue,
                durationMin: log.durationMin,
                energyKcal: log.activeEnergyKcal,
                note: log.note,
                source: log.healthUUID != nil ? "health" : "manual"
            )
        }
    }

    private var exportMenu: some View {
        Menu {
            ShareLink(
                item: WorkoutCSVExport(text: WorkoutExport(rows: exportRows).csv()),
                preview: SharePreview("workouts.csv")
            ) {
                Label("Export CSV", systemImage: "tablecells")
            }
            ShareLink(
                item: WorkoutJSONExport(data: WorkoutExport(rows: exportRows).json()),
                preview: SharePreview("workouts.json")
            ) {
                Label("Export JSON", systemImage: "curlybraces")
            }
        } label: {
            Label("Export", systemImage: "square.and.arrow.down")
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
                    exportMenu
                }
                ToolbarItem(placement: .topBarTrailing) {
                    shareLink
                }
            }
        }
        .tint(Theme.accent)
    }

    // MARK: - Sections

    /// Small metric/unit caption shown above a chart so a value can be read in context.
    private func chartCaption(_ text: String) -> some View {
        Text(text)
            .font(.caption2)
            .foregroundStyle(Theme.secondaryLabel)
    }

    private var minutesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("This week's training minutes")
            Card {
                if hasTrainingData {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        chartCaption("Minutes per day")
                        Chart(weeklyByWeekday) { day in
                            BarMark(
                                x: .value("Day", day.label),
                                y: .value("Minutes", day.minutes)
                            )
                            .foregroundStyle(Theme.accent)
                            .cornerRadius(Radius.sm)
                            .accessibilityLabel(day.label)
                            .accessibilityValue("\(day.minutes) minutes")
                        }
                        .chartYAxis { AxisMarks(position: .leading) }
                        .frame(height: chartHeight)
                    }
                } else {
                    ContentUnavailableView {
                        Label("No workouts yet", systemImage: "chart.bar.fill")
                    } description: {
                        Text("Log a workout or connect Apple Health to see your week.")
                    } actions: {
                        NavigationLink {
                            ManualEntryView()
                        } label: {
                            Text("Log a workout")
                        }
                        .buttonStyle(SecondaryButton())
                    }
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
                        chartCaption("VO2 max (ml·kg⁻¹·min⁻¹)")
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
                        .chartYAxis { AxisMarks(position: .leading) }
                        .frame(height: chartHeight)

                        let improving = trend.deltaFromFirst >= 0
                        // Pre-format to keep the view body cheap for the type-checker.
                        let oneDP = FloatingPointFormatStyle<Double>.number.precision(.fractionLength(1))
                        let latestText = trend.latest.formatted(oneDP)
                        let deltaSignedText = trend.deltaFromFirst.formatted(oneDP.sign(strategy: .always()))
                        let deltaAbsText = abs(trend.deltaFromFirst).formatted(oneDP)
                        let trendA11y = "Latest VO2 max \(latestText), \(improving ? "improved" : "declined") by \(deltaAbsText)"
                        HStack(spacing: Spacing.xs) {
                            Text("Latest \(latestText)")
                                .numericStyle(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.label)
                            Text("·")
                                .foregroundStyle(Theme.secondaryLabel)
                            // Triangle glyph + explicit +/- sign convey direction without color.
                            Image(systemName: improving ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                                .font(.caption2)
                                .foregroundStyle(improving ? Theme.success : Theme.danger)
                            Text(deltaSignedText)
                                .numericStyle(.subheadline)
                                .foregroundStyle(improving ? Theme.success : Theme.danger)
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(trendA11y)
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
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        chartCaption(weightAxisLabel)
                        Chart(weightPoints) { point in
                            LineMark(
                                x: .value("Date", point.date),
                                y: .value(weightAxisLabel, displayWeight(point.kg))
                            )
                            .foregroundStyle(Theme.accent)
                            .interpolationMethod(.catmullRom)
                            PointMark(
                                x: .value("Date", point.date),
                                y: .value(weightAxisLabel, displayWeight(point.kg))
                            )
                            .foregroundStyle(Theme.accent)
                        }
                        .chartYScale(domain: .automatic(includesZero: false))
                        .chartYAxis { AxisMarks(position: .leading) }
                        .frame(height: chartHeight)
                    }
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
