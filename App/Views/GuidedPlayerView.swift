import SwiftUI
import SwiftData
import SharedCore
import UIKit

/// On-iPhone guided workout player: a big live clock, the current/next interval
/// (4×4) or elapsed time (Zone 2), transition haptics, and spoken cues from the
/// `GuidedSessionEngine`. A normally-completed session is recorded as a `WorkoutLog`
/// (see `GuidedSessionLogger`); an early exit records nothing.
struct GuidedPlayerView: View {
    let type: SessionType
    /// Planned minutes for this session; a Zone 2 run is only recorded once its
    /// elapsed time reaches this. Unused for the structured 4×4.
    let prescribedMinutes: Int
    @State private var engine: GuidedSessionEngine
    @State private var didLog = false
    @State private var loggedWorkout: WorkoutLog?
    @State private var showsEffortFeedback = false
    @State private var liveHR = LiveHRStore.shared
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    init(type: SessionType, prescribedMinutes: Int, calc: HRZoneCalculator, repeats: Int = Norwegian4x4.repeats) {
        self.type = type
        self.prescribedMinutes = prescribedMinutes
        _engine = State(initialValue: GuidedSessionEngine(type: type, calc: calc, repeats: repeats))
    }

    /// Records the session as a `WorkoutLog` once, when it qualifies (4×4 finished,
    /// or Zone 2 past its prescribed duration). Safe to call repeatedly.
    @discardableResult
    private func logIfCompleted() -> WorkoutLog? {
        guard !didLog else { return loggedWorkout }
        let logger = GuidedSessionLogger(context: context)
        if let log = logger.logWorkout(type: type, isFinished: engine.isFinished,
                                       elapsedSec: engine.elapsedSec,
                                       prescribedMinutes: prescribedMinutes) {
            didLog = true
            loggedWorkout = log
            return log
        }
        return nil
    }

    private func finishSession() {
        engine.stop()
        if let log = logIfCompleted() {
            loggedWorkout = log
            showsEffortFeedback = true
        } else {
            dismiss()
        }
    }

    var body: some View {
        VStack(spacing: Spacing.xl) {
            if engine.audioUnavailable {
                audioUnavailableBanner
            }

            header

            Text(engine.clockText)
                .font(.system(size: 76, weight: .semibold))
                .monospacedDigit()
                .foregroundStyle(Theme.label)
                .accessibilityLabel(engine.isStructured ? "Time remaining" : "Elapsed time")
                .accessibilityValue(engine.clockText)

            if liveHR.isFresh {
                Label {
                    Text("\(liveHR.bpm) bpm · Apple Watch")
                        .numericStyle(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.label)
                } icon: {
                    Image(systemName: "heart.fill").foregroundStyle(Theme.danger)
                }
                .accessibilityLabel("Live heart rate \(liveHR.bpm) from Apple Watch")
            }

            if engine.isStructured {
                if !engine.progressText.isEmpty {
                    Text(engine.progressText)
                        .numericStyle(.headline)
                        .foregroundStyle(Theme.secondaryLabel)
                }
                if let next = engine.nextInterval {
                    Text(String(localized: "Next: \(next.kind.displayName)"))
                        .font(.subheadline)
                        .foregroundStyle(Theme.secondaryLabel)
                } else if engine.isFinished {
                    Label("Session complete", systemImage: "checkmark.seal.fill")
                        .font(.headline)
                        .foregroundStyle(Theme.success)
                }
            }

            if engine.isPaused {
                Label("Paused", systemImage: "pause.circle.fill")
                    .font(.headline)
                    .foregroundStyle(Theme.warning)
            }

            Spacer()

            VStack(spacing: Spacing.md) {
                Button {
                    engine.isPaused ? engine.resume() : engine.pause()
                } label: {
                    Label(engine.isPaused ? "Resume" : "Pause",
                          systemImage: engine.isPaused ? "play.fill" : "pause.fill")
                }
                .buttonStyle(SecondaryButton())

                Button("End") {
                    finishSession()
                }
                .buttonStyle(PrimaryButton())
            }
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Theme.background)
        .navigationTitle(type.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .tint(Theme.accent)
        .sensoryFeedback(.impact, trigger: engine.hapticTrigger)
        .overlay {
            if showsEffortFeedback, let loggedWorkout {
                EffortFeedbackOverlay(log: loggedWorkout) {
                    showsEffortFeedback = false
                    dismiss()
                }
            }
        }
        .onChange(of: engine.isFinished) { _, finished in
            if finished, let log = logIfCompleted() {
                loggedWorkout = log
                showsEffortFeedback = true
            }
        }
        // Forward streamed watch HR to the engine (ready for adaptive phone timing).
        .onChange(of: liveHR.bpm) { _, bpm in
            engine.updateHeartRate(liveHR.isFresh ? bpm : 0)
        }
        .onAppear {
            engine.start()
            // A guided session is a hands-free screen: without this the display
            // auto-locks mid-workout, the app suspends, and voice cues stop.
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            logIfCompleted()
            engine.stop()
        }
    }

    /// Small non-blocking banner: the session keeps timing, only spoken cues are lost.
    private var audioUnavailableBanner: some View {
        Label {
            Text("Voice cues unavailable — the timer still runs.")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.warning)
                .fixedSize(horizontal: false, vertical: true)
        } icon: {
            Image(systemName: "speaker.slash.fill")
                .foregroundStyle(Theme.warning)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.sm)
        .background(Theme.warning.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
        .accessibilityLabel("Voice cues unavailable — the timer still runs.")
    }

    @ViewBuilder
    private var header: some View {
        if let interval = engine.currentInterval {
            VStack(spacing: Spacing.sm) {
                Image(systemName: interval.kind.glyph)
                    .font(.largeTitle)
                    .foregroundStyle(interval.kind.bannerColor)
                Text(interval.kind.displayName)
                    .font(.serif(.title, weight: .bold))
                    .foregroundStyle(Theme.label)
                if let hr = interval.targetHR {
                    Text("\(hr.lower)–\(hr.upper) bpm")
                        .numericStyle(.headline)
                        .foregroundStyle(Theme.secondaryLabel)
                }
            }
            .accessibilityElement(children: .combine)
        } else if !engine.isStructured {
            VStack(spacing: Spacing.sm) {
                Image(systemName: "figure.run")
                    .font(.largeTitle)
                    .foregroundStyle(Theme.accent)
                Text("Zone 2")
                    .font(.serif(.title, weight: .bold))
                    .foregroundStyle(Theme.label)
                Text("Keep it conversational")
                    .font(.subheadline)
                    .foregroundStyle(Theme.secondaryLabel)
            }
            .accessibilityElement(children: .combine)
        }
    }
}

private enum EffortFeedback: CaseIterable, Identifiable {
    case easy
    case good
    case hard
    case tooHard

    var id: String { label }

    var label: String {
        switch self {
        case .easy: return String(localized: "Easy")
        case .good: return String(localized: "Good")
        case .hard: return String(localized: "Hard")
        case .tooHard: return String(localized: "Too hard")
        }
    }

    var icon: String {
        switch self {
        case .easy: return "leaf.fill"
        case .good: return "checkmark.circle.fill"
        case .hard: return "flame.fill"
        case .tooHard: return "exclamationmark.triangle.fill"
        }
    }
}

private struct EffortFeedbackOverlay: View {
    let log: WorkoutLog
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: Spacing.md) {
            Text("How did it feel?")
                .font(.serif(.title2, weight: .bold))
                .foregroundStyle(Theme.label)
            Text("Your answer helps tune future targets without needing more health data.")
                .font(.subheadline)
                .foregroundStyle(Theme.secondaryLabel)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: Spacing.sm) {
                ForEach(EffortFeedback.allCases) { feedback in
                    Button {
                        save(feedback)
                    } label: {
                        Label(feedback.label, systemImage: feedback.icon)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryButton())
                }
            }

            Button("Skip", action: onDone)
                .buttonStyle(PrimaryButton())
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black.opacity(0.35))
        .accessibilityElement(children: .contain)
    }

    private func save(_ feedback: EffortFeedback) {
        let feedbackNote = String(localized: "Felt: \(feedback.label)")
        if let existing = log.note, !existing.isEmpty {
            log.note = "\(existing) · \(feedbackNote)"
        } else {
            log.note = feedbackNote
        }
        onDone()
    }
}
