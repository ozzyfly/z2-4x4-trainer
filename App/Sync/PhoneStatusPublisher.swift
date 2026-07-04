import Foundation
import WatchConnectivity
import SharedCore
import os

private let log = Logger(subsystem: "ca.logolo.z24x4", category: "PhoneStatusPublisher")

/// Pushes the latest widget snapshot (and the user's profile basics) to the paired
/// Apple Watch via the WCSession application context. Application context has
/// latest-state semantics: a new payload replaces the previous one, which is exactly
/// what the watch needs — only the freshest snapshot matters.
///
/// Fails soft everywhere: when WCSession is unsupported (iPad), not yet activated,
/// or the transfer is rejected, the error is logged and the app carries on.
enum PhoneStatusPublisher {
    @MainActor
    static func publish(snapshot: WidgetSnapshot, profile: UserProfile? = nil) {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        guard session.activationState == .activated else { return }

        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        var context: [String: Any] = ["snapshot": data]
        if let profile, let profileData = try? JSONEncoder().encode(profile) {
            context["profile"] = profileData
        }
        do {
            try session.updateApplicationContext(context)
        } catch {
            log.error("updateApplicationContext failed: \(error)")
        }
    }
}
