import Foundation
import SwiftData
import WatchConnectivity
import SharedCore

/// Receives completed workouts sent from the Apple Watch and stores them as `WorkoutLog`s,
/// skipping any whose Health UUID is already present (no duplicates).
@MainActor
final class PhoneSessionReceiver: NSObject, WCSessionDelegate {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
        super.init()
        activate()
    }

    private func activate() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    /// Inserts the transfer unless a log with the same `healthUUID` already exists.
    /// Returns true when a new `WorkoutLog` was created (used by tests).
    @discardableResult
    func ingest(_ transfer: WorkoutTransfer) -> Bool {
        // Both lookups are keyed on the UUID so the store can index the fetch —
        // no full-table scan per incoming workout.
        let uuid = transfer.healthUUID
        // `WorkoutLog.healthUUID` is optional; the predicate macro needs matching types.
        let optionalUUID: String? = transfer.healthUUID
        // Honor a user deletion: never resurrect a workout they removed.
        var tombstoneQuery = FetchDescriptor<DeletedWorkout>(
            predicate: #Predicate { $0.healthUUID == uuid }
        )
        tombstoneQuery.fetchLimit = 1
        guard ((try? context.fetchCount(tombstoneQuery)) ?? 0) == 0 else { return false }

        var matchQuery = FetchDescriptor<WorkoutLog>(
            predicate: #Predicate { $0.healthUUID == optionalUUID }
        )
        matchQuery.fetchLimit = 1

        // If the same workout already exists (e.g. a Health import that mislabeled a
        // 4×4 as Zone 2), the watch is authoritative — upgrade it in place rather than
        // duplicate. A prior watch entry is already authoritative, so skip.
        if let match = ((try? context.fetch(matchQuery)) ?? []).first {
            guard match.source != .watch else { return false }
            match.type = transfer.type
            match.durationMin = transfer.durationMin
            match.qualityScore = transfer.qualityScore ?? match.qualityScore
            match.peakHR = transfer.peakHR ?? match.peakHR
            match.avgHardHR = transfer.avgHardHR ?? match.avgHardHR
            match.repsCompleted = transfer.repsCompleted ?? match.repsCompleted
            match.avgHR = transfer.avgHR ?? match.avgHR
            match.totalSec = transfer.totalSec ?? match.totalSec
            match.source = .watch
            WidgetSnapshotWriter.update(context: context)
            return true
        }

        context.insert(WorkoutLog(
            date: transfer.date,
            type: transfer.type,
            durationMin: transfer.durationMin,
            activeEnergyKcal: transfer.energyKcal,
            healthUUID: transfer.healthUUID,
            source: .watch,
            qualityScore: transfer.qualityScore,
            peakHR: transfer.peakHR,
            avgHardHR: transfer.avgHardHR,
            repsCompleted: transfer.repsCompleted,
            avgHR: transfer.avgHR,
            totalSec: transfer.totalSec
        ))
        WidgetSnapshotWriter.update(context: context)
        return true
    }

    // MARK: WCSessionDelegate

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        handle(message)
    }

    nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        handle(userInfo)
    }

    private nonisolated func handle(_ payload: [String: Any]) {
        // Live heart-rate ping from the watch mid-workout (not a finished workout).
        if let hr = payload["liveHR"] as? Int {
            Task { @MainActor in LiveHRStore.shared.update(hr) }
            return
        }
        guard let transfer = WorkoutTransfer(userInfo: payload) else { return }
        Task { @MainActor in self.ingest(transfer) }
    }

    nonisolated func session(_ session: WCSession,
                             activationDidCompleteWith activationState: WCSessionActivationState,
                             error: Error?) {}
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}
    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
}
