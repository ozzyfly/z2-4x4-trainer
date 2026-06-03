import Foundation

/// Progress of an actual value against a target (minutes, energy, sessions…).
public struct TargetProgress: Sendable, Equatable {
    public let done: Int
    public let target: Int

    public init(done: Int, target: Int) {
        self.done = done
        self.target = target
    }

    /// 0…1, clamped. A non-positive target reads as complete.
    public var fraction: Double {
        guard target > 0 else { return 1 }
        return min(Double(done) / Double(target), 1)
    }

    public var isMet: Bool { done >= target }

    /// Remaining amount, never negative.
    public var remaining: Int { max(target - done, 0) }
}
