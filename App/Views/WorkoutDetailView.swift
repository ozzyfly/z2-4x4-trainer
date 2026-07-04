import SwiftUI
import SharedCore

/// Instructions for a Zone 2 or Norwegian 4×4 session with personalised HR bands.
struct WorkoutDetailView: View {
    let type: SessionType
    /// Planned minutes for this session, forwarded to the guided player so a Zone 2
    /// run is only recorded once it reaches its prescribed duration.
    let prescribedMinutes: Int
    let calc: HRZoneCalculator
    /// Number of 4×4 hard blocks (reduced on low-readiness days).
    var repeats: Int = Norwegian4x4.repeats

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                switch type {
                case .zone2:
                    zone2Content
                case .norwegian4x4:
                    fourByFourContent
                case .rest:
                    restContent
                }
            }
            .padding(Spacing.lg)
        }
        .background(Theme.background)
        .navigationTitle(type.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .tint(Theme.accent)
    }

    // MARK: - Zone 2

    private var zone2Content: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            instructionSection(
                "Zone 2 — aerobic base",
                "Hold a steady, conversational effort. Stay in your Zone 2 band for the whole session."
            )

            VStack(alignment: .leading, spacing: Spacing.sm) {
                SectionHeader("Target band")
                Card {
                    ZoneChip(title: "Target HR", range: rangeText(calc.zone2), color: HRZone.zone2.color)
                }
            }

            educationSection(
                "Why Zone 2 matters",
                points: [
                    ("lungs.fill", String(localized: "Builds aerobic base without piling on fatigue.")),
                    ("message.fill", String(localized: "You should be able to speak in short sentences.")),
                    ("speedometer", String(localized: "Heart-rate zones matter more than pace on easy days."))
                ]
            )

            guidedSessionButton
        }
    }

    // MARK: - Norwegian 4×4

    private var fourByFourContent: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            instructionSection(
                "Norwegian 4×4",
                "Four 4-minute hard intervals at 85–95% max HR, each followed by 3 minutes of easy recovery. Warm up and cool down properly."
            )

            if repeats < Norwegian4x4.repeats {
                Label {
                    Text("Readiness is low — today's session is reduced to \(repeats) hard blocks.")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.warning)
                        .fixedSize(horizontal: false, vertical: true)
                } icon: {
                    Image(systemName: "moon.fill").foregroundStyle(Theme.warning)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            VStack(alignment: .leading, spacing: Spacing.sm) {
                SectionHeader("Target bands")
                Card {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        ZoneChip(title: "Hard band", range: rangeText(calc.fourByFourHard), color: HRZone.zone4.color)
                        ZoneChip(title: "Recovery band", range: rangeText(calc.zone2), color: HRZone.zone2.color)
                    }
                }
            }

            VStack(alignment: .leading, spacing: Spacing.sm) {
                SectionHeader("Structure")
                Card(padding: Spacing.xs) {
                    let intervals = Norwegian4x4.build(using: calc, repeats: repeats)
                    VStack(spacing: 0) {
                        ForEach(Array(intervals.enumerated()), id: \.offset) { index, interval in
                            IntervalRow(interval: interval)
                            if index < intervals.count - 1 {
                                Divider().padding(.leading, Spacing.xl)
                            }
                        }
                    }
                }
            }

            educationSection(
                "How 4×4 should feel",
                points: [
                    ("flame.fill", String(localized: "Hard means controlled: strong breathing, not an all-out sprint.")),
                    ("arrow.down.heart.fill", String(localized: "Recoveries matter because your heart rate needs room to drop.")),
                    ("calendar.badge.clock", String(localized: "Do not chase hard intervals every day; adaptation happens between sessions."))
                ]
            )

            guidedSessionButton
        }
    }

    /// Starts the on-iPhone guided player for this workout.
    private var guidedSessionButton: some View {
        NavigationLink {
            GuidedPlayerView(type: type, prescribedMinutes: prescribedMinutes, calc: calc)
        } label: {
            Label("Start guided session", systemImage: "play.circle.fill")
        }
        .buttonStyle(PrimaryButton())
    }

    // MARK: - Rest

    private var restContent: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Today")
            Card {
                HStack(spacing: Spacing.md) {
                    Image(systemName: "moon.zzz.fill")
                        .font(.title2)
                        .foregroundStyle(Theme.accent)
                        .frame(width: 44, height: 44)
                        .background(Theme.accent.opacity(0.12), in: Circle())
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Rest day")
                            .font(.serif(.title3, weight: .semibold))
                            .foregroundStyle(Theme.label)
                        Text("Recover well.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.secondaryLabel)
                    }
                    Spacer()
                }
            }
        }
    }

    // MARK: - Helpers

    private func instructionSection(_ title: LocalizedStringKey, _ body: LocalizedStringKey) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader(title)
            Card {
                Text(body)
                    .font(.subheadline)
                    .foregroundStyle(Theme.label)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func educationSection(_ title: LocalizedStringKey, points: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader(title)
            Card {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    ForEach(Array(points.enumerated()), id: \.offset) { _, point in
                        HStack(alignment: .top, spacing: Spacing.md) {
                            Image(systemName: point.0)
                                .foregroundStyle(Theme.accent)
                                .frame(width: 24)
                            Text(point.1)
                                .font(.subheadline)
                                .foregroundStyle(Theme.label)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
            }
        }
    }

    private func rangeText(_ range: HRRange) -> String {
        String(localized: "\(range.lower)–\(range.upper) bpm")
    }
}

/// A single interval segment, color-coded by kind, matching the watch's banner colors.
struct IntervalRow: View {
    let interval: WorkoutInterval

    var body: some View {
        HStack(spacing: Spacing.md) {
            RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                .fill(interval.kind.bannerColor)
                .frame(width: 4)
                .frame(maxHeight: .infinity)

            // Glyph conveys the interval kind by shape, not color alone.
            Image(systemName: interval.kind.glyph)
                .font(.subheadline)
                .foregroundStyle(interval.kind.bannerColor)
                .frame(width: 22)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(interval.kind.rawValue.capitalized)
                    .font(.rounded(.subheadline, weight: .semibold))
                    .foregroundStyle(Theme.label)
                Text(String(localized: "\(interval.durationSec / 60) min"))
                    .numericStyle(.caption)
                    .foregroundStyle(Theme.secondaryLabel)
            }

            Spacer()

            Text(rangeText)
                .numericStyle(.caption)
                .foregroundStyle(Theme.secondaryLabel)
        }
        .padding(.vertical, Spacing.md)
        .padding(.horizontal, Spacing.md)
        .frame(maxWidth: .infinity)
        .fixedSize(horizontal: false, vertical: true)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(localized: "\(interval.kind.rawValue.capitalized), \(interval.durationSec / 60) minutes, \(rangeText)"))
    }

    private var rangeText: String {
        guard let r = interval.targetHR else { return String(localized: "—") }
        return String(localized: "\(r.lower)–\(r.upper) bpm")
    }
}
