import Foundation
import WatchConnectivity
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

    // MARK: WCSessionDelegate (watchOS requires only activation)
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {}
}
