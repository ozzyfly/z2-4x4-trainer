import SwiftUI
import SwiftData

@main
struct Z24x4TrainerApp: App {
    private let container: ModelContainer = {
        try! ModelContainer(for: ProfileRecord.self, WorkoutLog.self, AchievementRecord.self)
    }()
    @State private var receiver: PhoneSessionReceiver?
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .task {
                    if receiver == nil {
                        receiver = PhoneSessionReceiver(context: container.mainContext)
                    }
                }
        }
        .modelContainer(container)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                WidgetSnapshotWriter.update(context: container.mainContext)
            }
        }
    }
}
