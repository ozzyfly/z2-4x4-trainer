import SwiftUI
import SharedCore

/// Entry screen: pick a session to start.
struct WorkoutListView: View {
    @State private var manager: WorkoutSessionManager
    /// Latest snapshot pushed from the phone; nil until the first sync lands.
    @State private var snapshot: WidgetSnapshot?
    /// Honors `-autostart4x4` to auto-open the 4×4 live screen for UI screenshots.
    @State private var autoStart4x4 = ProcessInfo.processInfo.arguments.contains("-autostart4x4")

    init() {
        // Prefer the profile synced from the phone (real age / max-HR override /
        // zone method); fall back to a sensible default before the first sync.
        let profile = SyncedProfileStore.read() ?? Self.defaultProfile
        let calculator = HRZoneCalculator(profile: profile)
        _manager = State(initialValue: WorkoutSessionManager(calculator: calculator))
    }

    private static let defaultProfile = UserProfile(
        age: 35,
        sex: .male,
        weightKg: 75,
        heightCm: 178
    )

    var body: some View {
        NavigationStack {
            List {
                StatusSection(snapshot: snapshot)
                ForEach(WatchWorkoutKind.allCases) { kind in
                    NavigationLink {
                        LiveWorkoutView(manager: manager, kind: kind)
                    } label: {
                        WorkoutRow(kind: kind)
                    }
                }
            }
            .navigationTitle("Train")
            .navigationDestination(isPresented: $autoStart4x4) {
                LiveWorkoutView(manager: manager, kind: .fourByFour)
            }
            .task {
                snapshot = WidgetSnapshotStore.read()
                try? await manager.requestAuthorization()
            }
        }
    }
}

/// Readiness, streak and weekly-minutes insight synced from the phone.
/// Shows a neutral placeholder until the first snapshot arrives.
private struct StatusSection: View {
    let snapshot: WidgetSnapshot?

    var body: some View {
        Section {
            if let s = snapshot {
                readinessRow(s)
                streakRow(s)
                weekRow(s)
            } else {
                Text("Waiting for iPhone sync")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Status")
        }
    }

    private func readinessRow(_ s: WidgetSnapshot) -> some View {
        HStack(spacing: 8) {
            Image(systemName: s.readinessLabel.map(glyph) ?? "bolt.heart")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(s.readinessLabel.map(tint) ?? .secondary)
                .frame(width: 22)
                .accessibilityHidden(true)
            if let value = s.readinessValue, let label = s.readinessLabel {
                Text("\(value)")
                    .font(.headline.monospacedDigit())
                Text(title(for: label))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                Text("Readiness")
                    .font(.footnote)
                Text(verbatim: "—")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }

    private func streakRow(_ s: WidgetSnapshot) -> some View {
        HStack(spacing: 8) {
            Image(systemName: (s.streakWeeks ?? 0) > 0 ? "flame.fill" : "flame")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.orange)
                .frame(width: 22)
                .accessibilityHidden(true)
            if let weeks = s.streakWeeks, weeks > 0 {
                Text("\(weeks)-week streak")
                    .font(.footnote)
            } else {
                Text("No streak yet")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }

    private func weekRow(_ s: WidgetSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("This week")
                    .font(.footnote)
                Spacer(minLength: 0)
                Text("\(s.weekDoneMinutes)/\(s.weekTargetMinutes) min")
                    .font(.footnote.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: s.weekFraction)
                .tint(.green)
        }
        .accessibilityElement(children: .combine)
    }

    private func title(for label: ReadinessLabel) -> String {
        switch label {
        case .goHard: return String(localized: "Go hard")
        case .steady: return String(localized: "Steady")
        case .easy:   return String(localized: "Take it easy")
        }
    }

    private func glyph(_ label: ReadinessLabel) -> String {
        switch label {
        case .goHard: return "bolt.fill"
        case .steady: return "equal.circle.fill"
        case .easy:   return "moon.fill"
        }
    }

    private func tint(_ label: ReadinessLabel) -> Color {
        switch label {
        case .goHard: return .green
        case .steady: return .blue
        case .easy:   return .yellow
        }
    }
}

private struct WorkoutRow: View {
    let kind: WatchWorkoutKind

    private var tint: Color { kind == .zone2 ? .green : .orange }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: kind == .zone2 ? "heart.fill" : "bolt.heart.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 30, height: 30)
                .background(tint.opacity(0.18), in: Circle())
                .accessibilityHidden(true)
            Text(kind.title)
                .font(.headline)
                .fontWeight(.semibold)
            Spacer(minLength: 0)
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(kind.title) workout")
    }
}

#Preview {
    WorkoutListView()
}
