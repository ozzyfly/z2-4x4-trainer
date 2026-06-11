import Foundation
import WatchConnectivity
import WidgetKit
import SharedCore

/// Sends a completed workout from the Watch to the paired iPhone over WatchConnectivity.
/// Uses an immediate message when the phone is reachable, otherwise the guaranteed
/// background `transferUserInfo` queue so nothing is lost.
final class WatchWorkoutSender: NSObject, WCSessionDelegate, @unchecked Sendable {
    static let shared = WatchWorkoutSender()

    private override init() {
        super.init()
        activate()
    }

    private func activate() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func send(_ transfer: WorkoutTransfer) {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        let info = transfer.toUserInfo()
        if session.activationState == .activated, session.isReachable {
            session.sendMessage(info, replyHandler: nil) { _ in
                // Immediate delivery failed → fall back to the background queue.
                session.transferUserInfo(info)
            }
        } else {
            session.transferUserInfo(info)
        }
    }

    // MARK: WCSessionDelegate

    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        guard activationState == .activated else { return }
        // The last context the phone pushed may have arrived while we weren't running.
        apply(applicationContext: session.receivedApplicationContext)
    }

    /// The phone publishes its latest widget snapshot (and profile basics) via the
    /// application context after every snapshot write.
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        apply(applicationContext: applicationContext)
    }

    /// Decodes the pushed snapshot/profile and caches them in the watch App Group so
    /// the app UI and complications can read them while the phone is unreachable.
    /// Malformed or missing payloads are ignored — never a crash.
    private func apply(applicationContext: [String: Any]) {
        if let data = applicationContext["snapshot"] as? Data,
           let snapshot = try? JSONDecoder().decode(WidgetSnapshot.self, from: data) {
            WidgetSnapshotStore.write(snapshot)
            WidgetCenter.shared.reloadAllTimelines()
        }
        if let data = applicationContext["profile"] as? Data,
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            SyncedProfileStore.write(profile)
        }
    }
}

/// Caches the profile synced from the phone in the watch App Group container so
/// zone calculations can use the user's real age / max-HR override / zone method.
/// Same fail-soft contract as `WidgetSnapshotStore`: no container → nil / no-op.
enum SyncedProfileStore {
    private static let filename = "synced-profile.json"

    private static var fileURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: WidgetSnapshotStore.appGroupID)?
            .appendingPathComponent(filename)
    }

    static func write(_ profile: UserProfile) {
        guard let fileURL, let data = try? JSONEncoder().encode(profile) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    static func read() -> UserProfile? {
        guard let fileURL, let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(UserProfile.self, from: data)
    }
}
