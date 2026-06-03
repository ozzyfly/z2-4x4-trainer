import SwiftUI
import SharedCore

/// Entry screen: pick a session to start.
struct WorkoutListView: View {
    @State private var manager: WorkoutSessionManager

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
            .task {
                try? await manager.requestAuthorization()
            }
        }
    }
}

private struct WorkoutRow: View {
    let kind: WatchWorkoutKind

    var body: some View {
        HStack {
            Image(systemName: kind == .zone2 ? "heart.fill" : "bolt.heart.fill")
                .foregroundStyle(kind == .zone2 ? .green : .orange)
            Text(kind.title)
                .font(.headline)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    WorkoutListView()
}
