import SwiftUI
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

                if let target = manager.targetRange {
                    Text("Target \(target.lower)–\(target.upper)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

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
    }

    private var heartRate: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Image(systemName: "heart.fill")
                .foregroundStyle(.red)
            Text(manager.currentHR > 0 ? "\(manager.currentHR)" : "--")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .monospacedDigit()
            Text("BPM")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var zoneLabel: some View {
        let zone = manager.currentZone
        return Text(zone?.displayName ?? "—")
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(
                Capsule().fill(zone?.color ?? .gray)
            )
    }
}

/// Current interval kind + countdown ("HARD 2:13").
private struct IntervalBanner: View {
    var engine: IntervalEngine

    var body: some View {
        let kind = engine.currentInterval?.kind
        VStack(spacing: 2) {
            Text(engine.countdownLabel)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill((kind?.bannerColor ?? .gray).opacity(0.85))
        )
    }
}

// MARK: - Styling

extension HRZone {
    var displayName: String {
        switch self {
        case .zone1: return "Zone 1"
        case .zone2: return "Zone 2"
        case .zone3: return "Zone 3"
        case .zone4: return "Zone 4"
        case .zone5: return "Zone 5"
        }
    }

    var color: Color {
        switch self {
        case .zone1: return .gray
        case .zone2: return .green
        case .zone3: return .blue
        case .zone4: return .orange
        case .zone5: return .red
        }
    }
}

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
