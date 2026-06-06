import SwiftUI
import SharedCore

/// Entry screen: pick a session to start.
struct WorkoutListView: View {
    @State private var manager: WorkoutSessionManager
    /// Honors `-autostart4x4` to auto-open the 4×4 live screen for UI screenshots.
    @State private var autoStart4x4 = ProcessInfo.processInfo.arguments.contains("-autostart4x4")

    init() {
        // A sensible default profile; on a real device this would come from
        // WatchConnectivity / a stored profile synced from the phone.
        let calculator = HRZoneCalculator(profile: Self.defaultProfile)
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
                try? await manager.requestAuthorization()
            }
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
            Text(kind.title)
                .font(.headline)
                .fontWeight(.semibold)
            Spacer(minLength: 0)
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    WorkoutListView()
}
