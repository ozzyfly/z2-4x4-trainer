import SwiftUI

@main
struct Z24x4WatchApp: App {
    init() {
        // Activate WatchConnectivity at launch so the watch can receive the phone's
        // status pushes (and is reachable) immediately — not only after the first
        // workout finishes, which is the only other place the sender is created.
        _ = WatchWorkoutSender.shared
    }

    var body: some Scene {
        WindowGroup {
            WorkoutListView()
        }
    }
}
