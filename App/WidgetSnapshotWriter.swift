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
    static func update(context: ModelContext, readiness: ReadinessScore? = nil) {
        guard let profile = try? context.fetch(FetchDescriptor<ProfileRecord>()).first else { return }
        // This runs after every mutation (manual log, watch sync, Health import…).
        // Newest-first with a generous cap: the week rollup needs days, the streak
        // needs recent consecutive weeks — never the unbounded full history.
        var logQuery = FetchDescriptor<WorkoutLog>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        logQuery.fetchLimit = 1000
        let logs = (try? context.fetch(logQuery)) ?? []

        let p = profile.domain
        let plan = TrainingPlan.weekly(for: p.goal)
        let today = plan.session(on: .now)
        let weekly = TargetsCalculator.weekly(profile: p, plan: plan)

        let cal = Calendar.current
        let thisWeek = logs.filter { cal.isDate($0.date, equalTo: .now, toGranularity: .weekOfYear) }
        let weekDone = thisWeek.reduce(0) { $0 + $1.durationMin }
        // A 4×4 only counts as a hard session if it wasn't a low-quality (mostly
        // missed) effort. Legacy/manual logs have no score and always count.
        let hardDone = thisWeek.filter {
            $0.type == .norwegian4x4
                && ($0.qualityScore ?? FourByFourSummary.creditQualityThreshold) >= FourByFourSummary.creditQualityThreshold
        }.count

        let history = logs.map {
            WorkoutRecord(date: $0.date, type: $0.type, durationMin: $0.durationMin, energyKcal: $0.activeEnergyKcal)
        }

        // Only the Health-driven path (RootView's readiness recompute) passes a
        // readiness score; every other mutation (watch sync, manual entry, guided
        // log, Health import) passes nil. Carry today's previous value forward so
        // those writes don't wipe readiness off the widgets — and off the watch,
        // whose 4×4 rep reduction reads the snapshot's readiness label.
        var readinessValue = readiness?.value
        var readinessLabel = readiness?.label
        if readiness == nil,
           let previous = WidgetSnapshotStore.read(),
           cal.isDateInToday(previous.generatedAt) {
            readinessValue = previous.readinessValue
            readinessLabel = previous.readinessLabel
        }

        let snapshot = WidgetSnapshot(
            todayType: today.type,
            todayMinutes: today.type == .rest ? 0 : today.durationMin,
            weekDoneMinutes: weekDone,
            weekTargetMinutes: weekly.trainingMinutes,
            hardDone: hardDone,
            hardTarget: weekly.hardSessions,
            generatedAt: .now,
            readinessValue: readinessValue,
            readinessLabel: readinessLabel,
            streakWeeks: StreakCalculator.currentWeeks(in: history)
        )
        WidgetSnapshotStore.write(snapshot)
        WidgetCenter.shared.reloadAllTimelines()
        PhoneStatusPublisher.publish(snapshot: snapshot, profile: p)
    }
}
