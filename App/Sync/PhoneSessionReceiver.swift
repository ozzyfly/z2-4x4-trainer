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
        let existing = (try? context.fetch(FetchDescriptor<WorkoutLog>())) ?? []
        let uuids = Set(existing.compactMap { $0.healthUUID })
        guard WorkoutSyncDedupe.shouldInsert(transfer, existingHealthUUIDs: uuids) else { return false }
        context.insert(WorkoutLog(
            date: transfer.date,
            type: transfer.type,
            durationMin: transfer.durationMin,
            activeEnergyKcal: transfer.energyKcal,
            healthUUID: transfer.healthUUID
        ))
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
