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

                // Glanceable first: the session's ONE number on top — countdown
                // for a 4×4, banked in-zone time for open-ended Zone 2 — then HR.
                if kind.isStructured, let engine = manager.intervalEngine {
                    IntervalBanner(engine: engine)
                } else {
                    Zone2Banner(manager: manager)
                }

                heartRatePanel

                if !kind.isStructured, manager.zone2Blind {
                    Label("No HR — timed", systemImage: "heart.slash")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("No heart rate, crediting elapsed time")
                }

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
        // The summary owns the whole screen — no nav chrome bleeding through.
        .toolbar(
            showZone2Summary || (manager.intervalEngine?.isFinished ?? false) ? .hidden : .automatic,
            for: .navigationBar
        )
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
                    .minimumScaleFactor(0.6) // "Waiting for heart rate" must not truncate
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

}

/// The Zone 2 headline: banked in-zone time, big and on top (mirrors the 4×4
/// countdown banner). Green while crediting, dimmed while the clock is paused
/// out-of-zone, heart-slash while blind (crediting wall-clock time).
private struct Zone2Banner: View {
    var manager: WorkoutSessionManager

    var body: some View {
        let secs = manager.zone2InZoneSeconds
        let counting = manager.zone2Counting
        let fill: Color = counting ? HRZone.zone2.color : .gray
        HStack(spacing: 6) {
            Image(systemName: manager.zone2Blind
                  ? "heart.slash"
                  : (counting ? "checkmark.circle.fill" : "pause.circle.fill"))
                .accessibilityHidden(true)
            Text(String(format: "%d:%02d", secs / 60, secs % 60))
                .font(.system(.title2, design: .rounded).weight(.heavy))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(fill.opacity(counting ? 0.85 : 0.45))
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Time in Zone 2")
        .accessibilityValue("\(secs / 60) minutes \(secs % 60) seconds\(counting ? "" : ", paused")")
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

/// Full-screen "you finished" summary for a completed 4×4: the quality score is
/// the hero, everything else is one quiet block. Opaque black + scrollable.
private struct CompletionOverlay: View {
    let summary: FourByFourSummary
    let onDone: () -> Void

    private var qualityColor: Color {
        summary.qualityScore >= FourByFourSummary.creditQualityThreshold ? .green : .orange
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 6) {
                Text("Nice work!")
                    .font(.system(.caption2, design: .serif))
                    .foregroundStyle(WatchTheme.taupe)
                    .padding(.top, 10)

                Text("\(summary.qualityScore)")
                    .font(.system(size: 44, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(qualityColor)

                Text("Quality")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                VStack(spacing: 2) {
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
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

                Button("Done", action: onDone)
                    .buttonStyle(.borderedProminent)
                    .tint(WatchTheme.accent)
                    .padding(.top, 6)
            }
            .padding(.horizontal, 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Workout complete. Quality \(summary.qualityScore). \(summary.repsCompletedFully) of \(summary.hardReps.count) full reps, average hard heart rate \(summary.avgHardHR), peak \(summary.peakHR).")
    }
}

/// One hero number (effective Zone 2 time), one quiet line of context, two
/// buttons. Opaque black + scrollable so nothing bleeds through or clips.
private struct Zone2CompletionOverlay: View {
    let inZoneSeconds: Int
    let totalSeconds: Int
    let averageHR: Int
    let inZonePercent: Int
    let onDone: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 6) {
                Text("Effective Zone 2")
                    .font(.system(.caption2, design: .serif))
                    .foregroundStyle(WatchTheme.taupe)
                    .padding(.top, 10)

                Text(Self.elapsedString(inZoneSeconds))
                    .font(.system(size: 44, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.green)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

                VStack(spacing: 2) {
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
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.top, 6)
            }
            .padding(.horizontal, 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
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
