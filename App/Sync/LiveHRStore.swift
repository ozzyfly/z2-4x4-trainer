import Foundation
import Observation

/// Holds the latest heart rate streamed from the paired Apple Watch during a
/// workout. Best-effort and ephemeral: updated via WCSession messages while the
/// watch is reachable, and considered stale after a few seconds of silence.
@Observable
@MainActor
final class LiveHRStore {
    static let shared = LiveHRStore()

    private(set) var bpm: Int = 0
    private(set) var updatedAt: Date = .distantPast

    private init() {}

    func update(_ bpm: Int) {
        self.bpm = bpm
        self.updatedAt = .now
    }

    /// A reading is fresh if it arrived within the last few seconds.
    var isFresh: Bool { bpm > 0 && Date().timeIntervalSince(updatedAt) < 8 }
}
