import SwiftUI
import SharedCore

/// Instructions for a Zone 2 or Norwegian 4×4 session with personalised HR bands.
struct WorkoutDetailView: View {
    let type: SessionType
    let calc: HRZoneCalculator

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
        }
    }

    // MARK: - Norwegian 4×4

    private var fourByFourContent: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            instructionSection(
                "Norwegian 4×4",
                "Four 4-minute hard intervals at 85–95% max HR, each followed by 3 minutes of easy recovery. Warm up and cool down properly."
            )

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
                    let intervals = Norwegian4x4.build(using: calc)
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
        }
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
                            .font(.rounded(.title3, weight: .semibold))
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

    private func instructionSection(_ title: String, _ body: String) -> some View {
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

    private func rangeText(_ range: HRRange) -> String {
        "\(range.lower)–\(range.upper) bpm"
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

            VStack(alignment: .leading, spacing: 2) {
                Text(interval.kind.rawValue.capitalized)
                    .font(.rounded(.subheadline, weight: .semibold))
                    .foregroundStyle(Theme.label)
                Text("\(interval.durationSec / 60) min")
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
        .accessibilityLabel("\(interval.kind.rawValue.capitalized), \(interval.durationSec / 60) minutes, \(rangeText)")
    }

    private var rangeText: String {
        guard let r = interval.targetHR else { return "—" }
        return "\(r.lower)–\(r.upper) bpm"
    }
}

/// iOS-target interval colors, mirroring `Watch/LiveWorkoutView.swift`'s `IntervalKind.bannerColor`.
extension IntervalKind {
    var bannerColor: Color {
        switch self {
        case .warmup: return .blue
        case .hard: return .red
        case .recovery: return .green
        case .cooldown: return .teal
        }
    }
}
