import SwiftUI
import SwiftData

@main
struct Z24x4TrainerApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [ProfileRecord.self, WorkoutLog.self])
    }
}
