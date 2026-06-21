import SwiftUI
import SwiftData
import SharedCore

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
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    init(type: SessionType, prescribedMinutes: Int, calc: HRZoneCalculator) {
        self.type = type
        self.prescribedMinutes = prescribedMinutes
        _engine = State(initialValue: GuidedSessionEngine(type: type, calc: calc))
    }

    /// Records the session as a `WorkoutLog` once, when it qualifies (4×4 finished,
    /// or Zone 2 past its prescribed duration). Safe to call repeatedly.
    private func logIfCompleted() {
        guard !didLog else { return }
        let logger = GuidedSessionLogger(context: context)
        if logger.log(type: type, isFinished: engine.isFinished,
                      elapsedSec: engine.elapsedSec, prescribedMinutes: prescribedMinutes) {
            didLog = true
        }
    }

    var body: some View {
        VStack(spacing: Spacing.xl) {
            if engine.audioUnavailable {
                audioUnavailableBanner
            }

            header

            Text(engine.clockText)
                .font(.system(size: 76, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(Theme.label)
                .accessibilityLabel(engine.isStructured ? "Time remaining" : "Elapsed time")
                .accessibilityValue(engine.clockText)

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

            Spacer()

            Button("End") {
                engine.stop()
                dismiss()
            }
            .buttonStyle(PrimaryButton())
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Theme.background)
        .navigationTitle(type.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .tint(Theme.accent)
        .sensoryFeedback(.impact, trigger: engine.hapticTrigger)
        .onChange(of: engine.isFinished) { _, finished in
            if finished { logIfCompleted() }
        }
        .onAppear { engine.start() }
        .onDisappear {
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
                    .font(.rounded(.title, weight: .bold))
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
                    .font(.rounded(.title, weight: .bold))
                    .foregroundStyle(Theme.label)
                Text("Keep it conversational")
                    .font(.subheadline)
                    .foregroundStyle(Theme.secondaryLabel)
            }
            .accessibilityElement(children: .combine)
        }
    }
}
