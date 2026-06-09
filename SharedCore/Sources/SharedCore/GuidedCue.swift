import Foundation

/// Spoken cue strings for the guided workout player, kept out of any view so they
/// can be unit-tested and reused by phone (and potentially watch).
public enum GuidedCue {
    /// Cue spoken when entering an interval.
    public static func text(entering kind: IntervalKind) -> String {
        switch kind {
        case .warmup: return "Warm up. Ease into it."
        case .hard: return "Hard. Four minutes, push."
        case .recovery: return "Recover. Easy now."
        case .cooldown: return "Cool down. Bring it down."
        }
    }

    /// Reminder spoken during an open-ended Zone 2 session.
    public static let zone2Reminder = "Zone 2. Keep it conversational."

    /// Cue spoken when the session finishes.
    public static let finished = "Session complete. Well done."
}
