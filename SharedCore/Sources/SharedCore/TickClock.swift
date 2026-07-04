import Foundation

/// Converts wall-clock time into whole-second "ticks" for the interval engines.
///
/// Hosts previously advanced their state machines once per `Timer` fire, which
/// drifts on watchOS: with the wrist down or the app inactive, timers are throttled
/// and seconds silently go missing, stretching a 4-minute hard segment. Instead,
/// anchor on `Date` and ask how many whole seconds are due; the timer (or an
/// incoming heart-rate sample) merely triggers the check, and any missed seconds
/// are replayed as catch-up ticks.
///
/// Pure value type — no timer, fully testable by passing explicit dates.
public struct TickClock: Sendable, Equatable {
    private var anchor: Date?

    /// Upper bound on ticks returned by a single `consumeDue` call. If more time
    /// than this has passed (system clock jump, absurd stall) the excess is
    /// dropped rather than replayed.
    public let maxCatchUp: Int

    public init(maxCatchUp: Int = 900) {
        self.maxCatchUp = maxCatchUp
    }

    /// True between `start` and `pause`.
    public var isRunning: Bool { anchor != nil }

    /// Starts (or restarts) counting from `now`. Any time before this is forgotten.
    public mutating func start(at now: Date = Date()) {
        anchor = now
    }

    /// Stops counting; time passing while paused yields no ticks.
    public mutating func pause() {
        anchor = nil
    }

    /// Returns the number of whole seconds elapsed since the last consume/start and
    /// advances the anchor by exactly that many seconds, so fractional remainders
    /// carry over to the next call (no long-run drift).
    public mutating func consumeDue(at now: Date = Date()) -> Int {
        guard let anchor else { return 0 }
        let elapsed = now.timeIntervalSince(anchor)
        if elapsed < 0 {
            // Clock went backwards — re-anchor rather than stalling forever.
            self.anchor = now
            return 0
        }
        guard elapsed >= 1 else { return 0 }
        let ticks = Int(elapsed)
        if ticks > maxCatchUp {
            self.anchor = now
            return maxCatchUp
        }
        self.anchor = anchor.addingTimeInterval(TimeInterval(ticks))
        return ticks
    }
}
