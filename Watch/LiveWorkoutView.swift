import SwiftUI
import WatchKit
import SharedCore

/// The active-session screen: big live heart rate, zone label, and — for the
/// Norwegian 4×4 — the current interval kind, countdown, and overall progress.
struct LiveWorkoutView: View {
    @State var manager: WorkoutSessionManager
    let kind: WatchWorkoutKind

    @Environment(\.dismiss) private var dismiss
    @State private var showEndConfirm = false
    @State private var showZone2Summary = false
    /// Escalates the "waiting for heart rate" hint after 30s with no reading —
    /// at that point it's almost always permissions or band fit, not warm-up.
    @State private var hrHintEscalated = false
    private static let hrEscalateAfterSec: TimeInterval = 30

    private enum TargetFeedback: Equatable {
        case noTarget
        case noReading
        case tooLow(lower: Int, upper: Int)
        case inZone(lower: Int, upper: Int)
        case tooHigh(lower: Int, upper: Int)

        var isActionable: Bool {
            switch self {
            case .tooLow, .inZone, .tooHigh: return true
            case .noTarget, .noReading: return false
            }
        }

        var title: String {
            switch self {
            case .noTarget:
                return String(localized: "No target")
            case .noReading:
                return String(localized: "Waiting for heart rate")
            case .tooLow:
                return String(localized: "Too low")
            case .inZone:
                return String(localized: "In zone")
            case .tooHigh:
                return String(localized: "Too high")
            }
        }

        var detail: String {
            switch self {
            case .noTarget:
                return String(localized: "Start a session to see your target.")
            case .noReading:
                return String(localized: "Keep moving while Apple Watch locks onto your heart rate.")
            case let .tooLow(lower, upper):
                return String(localized: "Build toward \(lower)–\(upper) bpm.")
            case let .inZone(lower, upper):
                return String(localized: "Hold \(lower)–\(upper) bpm.")
            case let .tooHigh(lower, upper):
                return String(localized: "Ease back to \(lower)–\(upper) bpm.")
            }
        }

        var icon: String {
            switch self {
            case .noTarget: return "target"
            case .noReading: return "heart.slash"
            case .tooLow: return "arrow.up.circle.fill"
            case .inZone: return "checkmark.circle.fill"
            case .tooHigh: return "arrow.down.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .noTarget, .noReading: return .gray
            case .tooLow: return .blue
            case .inZone: return .green
            case .tooHigh: return .orange
            }
        }
    }

    private var targetFeedback: TargetFeedback {
        guard let target = manager.targetRange else { return .noTarget }
        guard manager.currentHR > 0 else { return .noReading }
        if manager.currentHR < target.lower { return .tooLow(lower: target.lower, upper: target.upper) }
        if manager.currentHR > target.upper { return .tooHigh(lower: target.lower, upper: target.upper) }
        return .inZone(lower: target.lower, upper: target.upper)
    }

    /// In/out of the current target band: nil when there's no target or no reading yet.
    private var inZone: Bool? {
        targetFeedback == .inZone(lower: manager.targetRange?.lower ?? 0, upper: manager.targetRange?.upper ?? 0)
    }

    private var zoneBorderColor: Color {
        targetFeedback.isActionable ? targetFeedback.color : .clear
    }

    /// The feedback detail line, escalated to an actionable permissions/band
    /// hint once HR has been missing long enough that warm-up can't explain it.
    private var feedbackDetail: String {
        if hrHintEscalated, targetFeedback == .noReading {
            return String(localized: "Still no reading — check Health access in the watch Settings app, and snug the band.")
        }
        return targetFeedback.detail
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                if manager.isPaused {
                    Label("Paused", systemImage: "pause.circle.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.orange)
                }

                // Glanceable first: current interval + countdown, then big HR + zone.
                if kind.isStructured, let engine = manager.intervalEngine {
                    IntervalBanner(engine: engine)
                }

                heartRatePanel

                if kind.isStructured, let engine = manager.intervalEngine {
                    if engine.noHeartRate {
                        Label("No HR — timed", systemImage: "heart.slash")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .accessibilityLabel("No heart rate, using timed intervals")
                    } else if let cue = engine.coachingCue {
                        Text(cue.label)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(cue.tint)
                            .accessibilityLabel(cue.accessibilityLabel)
                    }

                    if engine.hardRepTotal > 0 {
                        ProgressView(value: engine.sessionProgress)
                            .tint(engine.currentInterval?.kind.bannerColor ?? .gray)
                            .accessibilityLabel("Workout progress")
                            .accessibilityValue("\(Int(engine.sessionProgress * 100)) percent")
                    }

                    if let rep = engine.hardRepIndex {
                        Text("Interval \(rep) of \(engine.hardRepTotal)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                compactTargetFeedback

                elapsedTime

                controls
            }
            .padding(.horizontal, 2)
            .padding(.bottom, 6)
        }
        .navigationTitle(kind.title)
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("End workout?", isPresented: $showEndConfirm, titleVisibility: .visible) {
            Button("End workout", role: .destructive) {
                manager.end()
                dismiss()
            }
            Button("Keep going", role: .cancel) {}
        }
        // Celebrate a completed 4×4 before saving + leaving.
        .overlay {
            if showZone2Summary {
                Zone2CompletionOverlay(
                    inZoneSeconds: manager.zone2InZoneSeconds,
                    totalSeconds: manager.zone2TotalSeconds,
                    averageHR: manager.zone2AverageHR,
                    inZonePercent: manager.zone2InZonePercent
                ) {
                    manager.end()
                    dismiss()
                } onCancel: {
                    showZone2Summary = false
                }
            } else if let engine = manager.intervalEngine, engine.isFinished {
                CompletionOverlay(summary: engine.summary) {
                    manager.end()
                    dismiss()
                }
            }
        }
        .onAppear {
            manager.start(kind: kind)
        }
        // No reading after 30s in-session is almost never "still locking on".
        .onReceive(Timer.publish(every: 5, on: .main, in: .common).autoconnect()) { _ in
            hrHintEscalated = manager.isRunning
                && manager.currentHR == 0
                && (manager.startDate.map { Date().timeIntervalSince($0) > Self.hrEscalateAfterSec } ?? false)
        }
        // Give distinct taps as the athlete enters or leaves the target band.
        .onChange(of: targetFeedback) { old, new in
            guard old != new, new.isActionable else { return }
            switch new {
            case .inZone:
                WKInterfaceDevice.current().play(.success)
            case .tooLow:
                WKInterfaceDevice.current().play(.directionUp)
            case .tooHigh:
                WKInterfaceDevice.current().play(.directionDown)
            case .noTarget, .noReading:
                break
            }
        }
    }

    private var heartRatePanel: some View {
        VStack(spacing: 5) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Image(systemName: "heart.fill")
                    .font(.title3)
                    .foregroundStyle(.red)
                Text(manager.currentHR > 0 ? "\(manager.currentHR)" : "--")
                    .font(.system(size: 48, weight: .heavy, design: .rounded))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text("BPM")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            zoneLabel
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(.black.opacity(0.35))
        )
        .overlay(
            // Hairline, not a heavy ring — the color still carries the in/out-of-zone
            // state, at a weight that reads refined rather than alarming.
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .strokeBorder(zoneBorderColor.opacity(targetFeedback.isActionable ? 1 : 0.35), lineWidth: 1.5)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Heart rate")
        .accessibilityValue(manager.currentHR > 0 ? "\(manager.currentHR) beats per minute, \(targetFeedback.title)" : "No reading")
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

    private var compactTargetFeedback: some View {
        HStack(spacing: 6) {
            Image(systemName: targetFeedback.icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(targetFeedback.color)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 1) {
                Text(targetFeedback.title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(targetFeedback.color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(feedbackDetail)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(hrHintEscalated ? 3 : 1)
                    .minimumScaleFactor(0.7)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(targetFeedback.color.opacity(0.18))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(targetFeedback.color.opacity(0.65), lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(targetFeedback.title)
        .accessibilityValue(feedbackDetail)
    }

    private var controls: some View {
        HStack(spacing: 8) {
            Button {
                manager.isPaused ? manager.resume() : manager.pause()
            } label: {
                Image(systemName: manager.isPaused ? "play.fill" : "pause.fill")
                    .font(.headline.weight(.bold))
                    .frame(maxWidth: .infinity)
            }
            .tint(manager.isPaused ? .green : .orange)
            .accessibilityLabel(manager.isPaused ? "Resume" : "Pause")

            Button(role: .destructive) {
                if kind.isStructured {
                    showEndConfirm = true
                } else {
                    showZone2Summary = true
                }
            } label: {
                Image(systemName: "stop.fill")
                    .font(.headline.weight(.bold))
                    .frame(maxWidth: .infinity)
            }
            .accessibilityLabel("End")
        }
        .padding(.top, 2)
    }

    @ViewBuilder
    private var elapsedTime: some View {
        // Open-ended Zone 2 sessions count *time in Zone 2* — the clock pauses when
        // HR eases down into Zone 1, so junk minutes don't pad the session.
        if !kind.isStructured, manager.startDate != nil {
            let secs = manager.zone2InZoneSeconds
            VStack(spacing: 2) {
                Text(Self.elapsedString(secs))
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Time in Zone 2")
                    .accessibilityValue("\(secs / 60) minutes \(secs % 60) seconds")

                if manager.zone2Blind {
                    // Sensor lost — crediting wall-clock time instead of voiding the session.
                    Label("No HR — timed", systemImage: "heart.slash")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("No heart rate, crediting elapsed time")
                } else if manager.zone2Counting {
                    Label("In Zone 2", systemImage: "checkmark.circle.fill")
                        .font(.caption2)
                        .foregroundStyle(.green)
                } else if manager.currentHR > 0, let target = manager.targetRange {
                    if manager.currentHR > target.upper {
                        Label("Above Zone 2 — paused", systemImage: "pause.circle.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    } else {
                        Label("Below Zone 2 — paused", systemImage: "pause.circle.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                } else {
                    Text("Waiting for heart rate")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityElement(children: .combine)
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
                .lineLimit(1)
                .minimumScaleFactor(0.5)
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

/// Full-screen "you finished" celebration + quality summary for a completed 4×4.
private struct CompletionOverlay: View {
    let summary: FourByFourSummary
    let onDone: () -> Void
    @State private var pop = false

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 40))
                .foregroundStyle(.green)
                .scaleEffect(pop ? 1 : 0.4)
                .opacity(pop ? 1 : 0)
            Text("Nice work!")
                .font(.system(.headline, design: .serif))
            Text("Quality \(summary.qualityScore)")
                .font(.system(.title3, design: .rounded).weight(.bold))
                .monospacedDigit()
                .foregroundStyle(summary.qualityScore >= FourByFourSummary.creditQualityThreshold ? .green : .orange)
            VStack(spacing: 3) {
                Text("\(summary.repsCompletedFully)/\(summary.hardReps.count) full reps")
                if summary.avgHardHR > 0 {
                    Text("Avg hard \(summary.avgHardHR) · peak \(summary.peakHR)")
                } else {
                    Text("Peak \(summary.peakHR)")
                }
                Text("Hard time \(summary.totalInZoneSec / 60)m · recoveries \(summary.recoveriesCompleted)/\(summary.recoveryTargets)")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
            Button("Done", action: onDone)
                .buttonStyle(.borderedProminent)
                .tint(WatchTheme.accent)
                .padding(.top, 2)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Workout complete. Quality \(summary.qualityScore). \(summary.repsCompletedFully) of \(summary.hardReps.count) full reps, average hard heart rate \(summary.avgHardHR), peak \(summary.peakHR).")
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { pop = true }
        }
    }
}

private struct Zone2CompletionOverlay: View {
    let inZoneSeconds: Int
    let totalSeconds: Int
    let averageHR: Int
    let inZonePercent: Int
    let onDone: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 7) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 34))
                .foregroundStyle(.green)
            Text("Zone 2 summary")
                .font(.system(.headline, design: .serif))
            Text(Self.elapsedString(inZoneSeconds))
                .font(.system(.title3, design: .rounded).weight(.bold))
                .monospacedDigit()
                .foregroundStyle(.green)
            VStack(spacing: 2) {
                Text("Effective Zone 2")
                if averageHR > 0 { Text("Avg HR \(averageHR)") }
                Text("In zone \(inZonePercent)% of \(Self.elapsedString(totalSeconds))")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
            HStack {
                Button("Keep going", action: onCancel)
                    .buttonStyle(.bordered)
                Button("Done", action: onDone)
                    .buttonStyle(.borderedProminent)
                    .tint(WatchTheme.accent)
            }
            .font(.caption)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Zone 2 summary. \(Self.elapsedString(inZoneSeconds)) effective Zone 2, average heart rate \(averageHR), in zone \(inZonePercent) percent.")
    }

    private static func elapsedString(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
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
