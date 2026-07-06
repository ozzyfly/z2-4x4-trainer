import SwiftUI
import SwiftData
import SharedCore

/// Detail for a single logged workout: date, duration, energy, source, and — for a
/// watch-recorded Norwegian 4×4 — the quality score and heart-rate breakdown. Allows
/// deleting the entry (any source), recording a tombstone so it isn't re-imported.
struct WorkoutLogDetailView: View {
    @Bindable var log: WorkoutLog
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [ProfileRecord]
    @State private var showDeleteConfirm = false

    private var hasQuality: Bool {
        log.type == .norwegian4x4 && log.qualityScore != nil
    }

    private var hasZone2Stats: Bool {
        log.type == .zone2 && (log.avgHR != nil || log.totalSec != nil)
    }

    private var hasHeartRate: Bool {
        (log.avgHR ?? 0) > 0 || (log.avgHardHR ?? 0) > 0 || (log.peakHR ?? 0) > 0
    }

    private var zone2InZonePercent: Int? {
        guard log.type == .zone2,
              let total = log.totalSec,
              total > 0 else { return nil }
        return min(100, Int((Double(log.durationMin * 60) / Double(total) * 100).rounded()))
    }

    private var sessionInsight: (title: String, detail: String, icon: String, color: Color) {
        switch log.type {
        case .zone2:
            if let pct = zone2InZonePercent {
                if pct >= 80 {
                    return (
                        String(localized: "Strong aerobic session"),
                        String(localized: "Most of this workout stayed in Zone 2. This is the kind of steady work that builds your base."),
                        "checkmark.circle.fill",
                        Theme.success
                    )
                }
                if pct >= 60 {
                    return (
                        String(localized: "Useful Zone 2 work"),
                        String(localized: "You spent a solid share of the session in range. Next time, settle into the band a little earlier."),
                        "scope",
                        Theme.accent
                    )
                }
                return (
                    String(localized: "More time in range next time"),
                    String(localized: "This still counts, but the main opportunity is holding Zone 2 longer once your heart rate reaches the target."),
                    "arrow.up.circle.fill",
                    Theme.warning
                )
            }
            return (
                String(localized: "Aerobic base session"),
                String(localized: "Use the Watch target band during the workout to turn easy minutes into measurable Zone 2 time."),
                "figure.run",
                Theme.accent
            )
        case .norwegian4x4:
            if let score = log.qualityScore {
                if score >= FourByFourSummary.creditQualityThreshold {
                    return (
                        String(localized: "High-quality 4×4"),
                        String(localized: "You completed enough hard work near target. Keep the next day easy so the adaptation can land."),
                        "bolt.heart.fill",
                        Theme.success
                    )
                }
                return (
                    String(localized: "Incomplete hard stimulus"),
                    String(localized: "The session was useful, but the hard intervals did not spend enough time near target. Try a longer warm-up or slightly easier opening pace."),
                    "exclamationmark.triangle.fill",
                    Theme.warning
                )
            }
            if hasHeartRate {
                return (
                    String(localized: "Imported hard session"),
                    String(localized: "Apple Health provided heart-rate data, but not enough interval detail for a full 4×4 quality score."),
                    "heart.text.square.fill",
                    Theme.accent
                )
            }
            return (
                String(localized: "Imported workout"),
                String(localized: "This has duration and energy from Apple Health. Start 4×4 from the Watch app to capture reps, peak HR, and quality."),
                "square.and.arrow.down.fill",
                Theme.secondaryLabel
            )
        case .rest:
            return (
                String(localized: "Recovery day"),
                String(localized: "Rest is part of the plan. Keep it easy and let the next hard session feel sharper."),
                "moon.zzz.fill",
                Theme.secondaryLabel
            )
        }
    }

    /// The athlete's max HR, for showing intensities as a percentage.
    private var maxHR: Int? {
        guard let p = profiles.first else { return nil }
        return HRZoneCalculator(profile: p.domain).maxHR
    }

    /// "173 bpm · 94% max" when a max HR is known, otherwise just "173 bpm".
    private func hrWithPercent(_ hr: Int) -> String {
        if let m = maxHR, m > 0 {
            return "\(hr) bpm · \(Int((Double(hr) / Double(m) * 100).rounded()))% max"
        }
        return "\(hr) bpm"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                header
                insightSection
                if hasQuality { qualitySection }
                if hasZone2Stats { zone2Section }
                if log.type == .norwegian4x4 && hasHeartRate && !hasQuality { heartRateSection }
                detailsSection
                if let note = log.note, !note.isEmpty { noteSection(note) }
                deleteButton
            }
            .padding(Spacing.lg)
        }
        .background(Theme.background)
        .navigationTitle(log.type.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .tint(Theme.accent)
        .confirmationDialog("Delete this workout?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete workout", role: .destructive) { deleteLog() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes it from your history. It won't be re-imported from Apple Health.")
        }
    }

    private var header: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: log.type.systemImage)
                .font(.title2)
                .foregroundStyle(Theme.accent)
                .frame(width: 48, height: 48)
                .background(Theme.accent.opacity(0.12), in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(log.type.displayName)
                    .font(.serif(.title2, weight: .semibold))
                    .foregroundStyle(Theme.label)
                Text(log.date, format: .dateTime.weekday(.wide).month().day().hour().minute())
                    .font(.subheadline)
                    .foregroundStyle(Theme.secondaryLabel)
            }
            Spacer()
        }
    }

    private var qualitySection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("4×4 quality")
            Card {
                VStack(spacing: Spacing.md) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("\(log.qualityScore ?? 0)")
                            .font(.system(size: 52, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle((log.qualityScore ?? 0) >= FourByFourSummary.creditQualityThreshold ? Theme.success : Theme.warning)
                        Text("/ 100")
                            .font(.headline)
                            .foregroundStyle(Theme.secondaryLabel)
                        Spacer()
                    }
                    Divider()
                    if let reps = log.repsCompleted {
                        statRow("Completed reps", "\(reps)")
                    }
                    if let peak = log.peakHR {
                        statRow("Peak HR", hrWithPercent(peak))
                    }
                    if let avg = log.avgHardHR, avg > 0 {
                        statRow("Avg hard HR", hrWithPercent(avg))
                    }
                }
            }
        }
    }

    private var insightSection: some View {
        Card {
            HStack(alignment: .top, spacing: Spacing.md) {
                Image(systemName: sessionInsight.icon)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(sessionInsight.color)
                    .frame(width: 36, height: 36)
                    .background(sessionInsight.color.opacity(0.14), in: Circle())
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(sessionInsight.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.label)
                    Text(sessionInsight.detail)
                        .font(.footnote)
                        .foregroundStyle(Theme.secondaryLabel)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var zone2Section: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Zone 2")
            Card {
                VStack(spacing: Spacing.md) {
                    if let avg = log.avgHR, avg > 0 {
                        statRow("Avg HR", hrWithPercent(avg))
                    }
                    if let total = log.totalSec, total > 0 {
                        if (log.avgHR ?? 0) > 0 { Divider() }
                        statRow("Time in Zone 2",
                                "\(log.durationMin) / \(Int((Double(total) / 60).rounded())) min")
                        Divider()
                        if let pct = zone2InZonePercent {
                            statRow("In zone", "\(pct)%")
                        }
                    }
                }
            }
        }
    }

    private var heartRateSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Heart rate")
            Card {
                VStack(spacing: Spacing.md) {
                    if let avg = log.avgHR, avg > 0 {
                        statRow("Avg HR", hrWithPercent(avg))
                    }
                    if let peak = log.peakHR, peak > 0 {
                        if (log.avgHR ?? 0) > 0 { Divider() }
                        statRow("Peak HR", hrWithPercent(peak))
                    }
                }
            }
        }
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Details")
            Card {
                VStack(spacing: Spacing.md) {
                    statRow("Duration", "\(log.durationMin) min")
                    // Zone 2's Duration is *credited in-zone* minutes; show the
                    // wall-clock total too so "35 min" next to a 40-minute run
                    // reads as a feature, not a discrepancy.
                    if log.type == .zone2, let total = log.totalSec, total / 60 > log.durationMin {
                        Divider()
                        statRow("Total time", "\(Int((Double(total) / 60).rounded())) min")
                    }
                    if let kcal = log.activeEnergyKcal, kcal > 0 {
                        Divider()
                        statRow("Active energy", "\(kcal) kcal")
                    }
                    if log.type != .zone2, let avg = log.avgHR, avg > 0 {
                        Divider()
                        statRow("Avg HR", hrWithPercent(avg))
                    }
                    Divider()
                    statRow("Source", sourceLabel(log.source))
                }
            }
        }
    }

    private func noteSection(_ note: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Note")
            Card {
                Text(note)
                    .font(.subheadline)
                    .foregroundStyle(Theme.label)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            showDeleteConfirm = true
        } label: {
            Label("Delete workout", systemImage: "trash")
                .frame(maxWidth: .infinity)
                .font(.subheadline.weight(.semibold))
                .padding(.vertical, Spacing.sm)
        }
        .tint(Theme.danger)
        .buttonStyle(.bordered)
    }

    private func statRow(_ title: LocalizedStringKey, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(Theme.secondaryLabel)
            Spacer()
            Text(value)
                .numericStyle(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.label)
        }
    }

    private func sourceLabel(_ source: WorkoutSource) -> String {
        switch source {
        case .manual: String(localized: "Logged manually")
        case .health: String(localized: "Apple Health")
        case .watch: String(localized: "Apple Watch")
        case .guided: String(localized: "Guided session")
        }
    }

    private func deleteLog() {
        if let uuid = log.healthUUID, !uuid.isEmpty {
            context.insert(DeletedWorkout(healthUUID: uuid))
        }
        context.delete(log)
        try? context.save()
        WidgetSnapshotWriter.update(context: context)
        dismiss()
    }
}
