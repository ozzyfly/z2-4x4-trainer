import SwiftUI
import SharedCore

/// On-iPhone guided workout player: a big live clock, the current/next interval
/// (4×4) or elapsed time (Zone 2), transition haptics, and spoken cues from the
/// `GuidedSessionEngine`.
struct GuidedPlayerView: View {
    let type: SessionType
    @State private var engine: GuidedSessionEngine
    @Environment(\.dismiss) private var dismiss

    init(type: SessionType, calc: HRZoneCalculator) {
        self.type = type
        _engine = State(initialValue: GuidedSessionEngine(type: type, calc: calc))
    }

    var body: some View {
        VStack(spacing: Spacing.xl) {
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
        .onAppear { engine.start() }
        .onDisappear { engine.stop() }
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
