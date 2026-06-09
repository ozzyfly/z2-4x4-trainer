import Foundation
import SwiftData
import SharedCore
import WidgetKit

/// Computes the current `WidgetSnapshot` from the stored profile + this week's
/// logs, writes it to the shared App Group container, and asks WidgetKit to
/// reload. Called on app activation, after logging a workout, and after a watch
/// session syncs in.
enum WidgetSnapshotWriter {
    @MainActor
    static func update(context: ModelContext) {
        guard let profile = try? context.fetch(FetchDescriptor<ProfileRecord>()).first else { return }
        let logs = (try? context.fetch(FetchDescriptor<WorkoutLog>())) ?? []

        let p = profile.domain
        let plan = TrainingPlan.weekly(for: p.goal)
        let today = plan.session(on: .now)
        let weekly = TargetsCalculator.weekly(profile: p, plan: plan)

        let cal = Calendar.current
        let thisWeek = logs.filter { cal.isDate($0.date, equalTo: .now, toGranularity: .weekOfYear) }
        let weekDone = thisWeek.reduce(0) { $0 + $1.durationMin }
        let hardDone = thisWeek.filter { $0.type == .norwegian4x4 }.count

        WidgetSnapshotStore.write(
            WidgetSnapshot(
                todayType: today.type,
                todayMinutes: today.type == .rest ? 0 : today.durationMin,
                weekDoneMinutes: weekDone,
                weekTargetMinutes: weekly.trainingMinutes,
                hardDone: hardDone,
                hardTarget: weekly.hardSessions,
                generatedAt: .now
            )
        )
        WidgetCenter.shared.reloadAllTimelines()
    }
}
