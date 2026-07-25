import SwiftUI
import SharedCore

/// "How this app works" — why Zone 2, why Norwegian 4×4, and what makes this
/// app's approach to both different from a plain interval timer.
struct GuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Training guide")
                        .font(.serif(.largeTitle, weight: .semibold))
                        .foregroundStyle(Theme.label)
                    Text("Two sessions, one purpose: a bigger aerobic engine. Here's why each works, and what this app does differently.")
                        .font(.subheadline)
                        .foregroundStyle(Theme.secondaryLabel)
                        .fixedSize(horizontal: false, vertical: true)
                }

                guideSection(
                    "Zone 2 — why it works",
                    intro: "A steady, conversational effort at roughly 60–70% max heart rate. It feels easy — that's the point.",
                    rows: [
                        GuideRow(icon: "leaf.fill", title: "Builds the aerobic base",
                                 detail: "Trains your body to burn fat efficiently and grows the mitochondria and capillaries that power every other workout."),
                        GuideRow(icon: "battery.100percent", title: "Recovers, doesn't drain",
                                 detail: "Low enough intensity to train often without digging a fatigue hole — the volume that actually moves fitness."),
                        GuideRow(icon: "heart.fill", title: "Raises the ceiling underneath",
                                 detail: "A bigger base means harder efforts like the 4×4 start from a stronger foundation and recover faster between sessions."),
                    ]
                )

                guideSection(
                    "Norwegian 4×4 — why it works",
                    intro: "Four 4-minute efforts at 85–95% max heart rate, each followed by 3 minutes of easy recovery. Hard, but controlled — not an all-out sprint.",
                    rows: [
                        GuideRow(icon: "chart.line.uptrend.xyaxis", title: "The most efficient way to raise VO₂max",
                                 detail: "The interval length and intensity is the specific protocol shown to lift VO₂max — the single strongest predictor of long-term cardiovascular health — more per minute than steady running."),
                        GuideRow(icon: "arrow.down.heart.fill", title: "Recovery is part of the stimulus",
                                 detail: "The 3-minute drop lets heart rate fall before the next effort, so you can hold true hard intensity four times instead of fading by the second."),
                        GuideRow(icon: "calendar.badge.clock", title: "A little goes a long way",
                                 detail: "One or two sessions a week is enough — the adaptation happens in the recovery between sessions, not by doing it every day."),
                    ]
                )

                guideSection(
                    "What this app does differently",
                    rows: [
                        GuideRow(icon: "waveform.path.ecg", title: "Heart-rate adaptive, not just a timer",
                                 detail: "The 4×4 clock only counts down while you're actually in the target band — it banks in-zone time, not wall-clock minutes, so the workout reflects real effort."),
                        GuideRow(icon: "gauge.with.needle.fill", title: "Reads your readiness first",
                                 detail: "HRV, resting heart rate, and sleep from Apple Health inform a daily readiness score that can reduce a hard day automatically — with your final say on whether to override it."),
                        GuideRow(icon: "applewatch", title: "Runs standalone on Apple Watch",
                                 detail: "Start a session from your wrist with no phone nearby; heart rate, haptics, and coaching cues all work independently."),
                        GuideRow(icon: "lock.shield.fill", title: "Local-only, no account",
                                 detail: "Everything lives on your device and syncs only through Apple Health and your own iCloud — no server, no sign-up, no ads."),
                        GuideRow(icon: "square.and.arrow.up", title: "Your data, exportable anytime",
                                 detail: "Full workout history as CSV or JSON whenever you want it — nothing locked in."),
                    ]
                )
            }
            .padding(Spacing.lg)
        }
        .background(Theme.background)
        .navigationTitle("Guide")
        .navigationBarTitleDisplayMode(.inline)
        .tint(Theme.accent)
    }

    // MARK: - Helpers

    private struct GuideRow {
        let icon: String
        let title: LocalizedStringKey
        let detail: LocalizedStringKey
    }

    private func guideSection(_ title: LocalizedStringKey, intro: LocalizedStringKey? = nil, rows: [GuideRow]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader(title)
            Card {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    if let intro {
                        Text(intro)
                            .font(.subheadline)
                            .foregroundStyle(Theme.label)
                            .fixedSize(horizontal: false, vertical: true)
                        Divider()
                    }
                    ForEach(rows.indices, id: \.self) { index in
                        IconDetailRow(icon: rows[index].icon, title: rows[index].title, detail: rows[index].detail)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        GuideView()
    }
}
