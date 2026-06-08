import SwiftUI
import WatchKit
import SharedCore

/// The active-session screen: big live heart rate, zone label, and — for the
/// Norwegian 4×4 — the current interval kind and countdown.
struct LiveWorkoutView: View {
    @State var manager: WorkoutSessionManager
    let kind: WatchWorkoutKind

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                if kind.isStructured, let engine = manager.intervalEngine {
                    IntervalBanner(engine: engine)
                }

                heartRate

                zoneLabel

                inZoneIndicator

                elapsedTime

                Button(role: .destructive) {
                    manager.end()
                    dismiss()
                } label: {
                    Text("End")
                        .frame(maxWidth: .infinity)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle(kind.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            manager.start(kind: kind)
        }
        // Buzz when the training zone changes during the session.
        .onChange(of: manager.currentZone) { old, new in
            if let new, new != old {
                WKInterfaceDevice.current().play(.notification)
            }
        }
    }

    private var heartRate: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Image(systemName: "heart.fill")
                .foregroundStyle(.red)
            Text(manager.currentHR > 0 ? "\(manager.currentHR)" : "--")
                .font(.system(.largeTitle, design: .rounded).weight(.bold))
                .monospacedDigit()
            Text("BPM")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Heart rate")
        .accessibilityValue(manager.currentHR > 0 ? "\(manager.currentHR) beats per minute" : "No reading")
    }

    private var zoneLabel: some View {
        let zone = manager.currentZone
        return HStack(spacing: 4) {
            if let zone {
                // Glyph conveys the zone by shape, not color alone.
                Image(systemName: zone.glyph)
                    .accessibilityHidden(true)
            }
            Text(zone?.displayName ?? "—")
        }
        .font(.headline)
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(
            Capsule().fill(zone?.color ?? .gray)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(zone?.displayName ?? "No zone")
    }

    @ViewBuilder
    private var inZoneIndicator: some View {
        if let target = manager.targetRange {
            let inZone = manager.currentHR > 0 && (target.lower...target.upper).contains(manager.currentHR)
            HStack(spacing: 4) {
                Image(systemName: inZone ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    .foregroundStyle(inZone ? .green : .orange)
                Text("Target \(target.lower)–\(target.upper)")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(inZone ? "In zone" : "Out of zone")
            .accessibilityValue("Target \(target.lower) to \(target.upper)")
        }
    }

    @ViewBuilder
    private var elapsedTime: some View {
        // Open-ended Zone 2 sessions have no interval countdown — show elapsed time.
        if !kind.isStructured, let start = manager.startDate {
            TimelineView(.periodic(from: start, by: 1)) { context in
                let elapsed = max(0, Int(context.date.timeIntervalSince(start)))
                Text(Self.elapsedString(elapsed))
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Elapsed time")
                    .accessibilityValue("\(elapsed / 60) minutes \(elapsed % 60) seconds")
            }
        }
    }

    private static func elapsedString(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}

/// Current interval kind + countdown ("HARD 2:13").
private struct IntervalBanner: View {
    var engine: IntervalEngine

    var body: some View {
        let kind = engine.currentInterval?.kind
        HStack(spacing: 6) {
            if let kind {
                Image(systemName: kind.glyph)
                    .accessibilityHidden(true)
            }
            Text(engine.countdownLabel)
                .font(.system(.title2, design: .rounded).weight(.heavy))
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill((kind?.bannerColor ?? .gray).opacity(0.85))
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(kind.map { $0.rawValue.capitalized } ?? "Interval")
        .accessibilityValue(engine.countdownLabel)
    }
}

// HRZone / IntervalKind color + glyph tokens now live in SharedCore
// (HRZone+UI.swift, IntervalKind+UI.swift) so phone and watch share one source.

#Preview {
    NavigationStack {
        LiveWorkoutView(
            manager: WorkoutSessionManager(
                calculator: HRZoneCalculator(maxHR: 185)
            ),
            kind: .fourByFour
        )
    }
}
