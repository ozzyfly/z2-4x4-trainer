import Foundation

/// One segment of a structured workout.
public enum IntervalKind: String, Sendable, Equatable {
    case warmup
    case hard
    case recovery
    case cooldown
}

public struct WorkoutInterval: Sendable, Equatable {
    public let kind: IntervalKind
    public let durationSec: Int
    /// Target HR band for this segment, when one applies.
    public let targetHR: HRRange?

    public init(kind: IntervalKind, durationSec: Int, targetHR: HRRange?) {
        self.kind = kind
        self.durationSec = durationSec
        self.targetHR = targetHR
    }
}

/// Builds the classic Norwegian 4×4 interval session:
/// 5 min warmup → 4 × (4 min hard @ 85–95% + 3 min recovery @ 60–70%) → 3 min cooldown.
public enum Norwegian4x4 {
    public static let warmupSec = 5 * 60
    public static let hardSec = 4 * 60
    public static let recoverySec = 3 * 60
    public static let cooldownSec = 3 * 60
    public static let repeats = 4

    public static func build(using calc: HRZoneCalculator) -> [WorkoutInterval] {
        build(using: calc, repeats: repeats)
    }

    /// Builds the session with a specific number of hard+recovery blocks (e.g. a
    /// reduced 3-block session on a low-readiness day).
    public static func build(using calc: HRZoneCalculator, repeats: Int) -> [WorkoutInterval] {
        var intervals: [WorkoutInterval] = []
        intervals.append(.init(kind: .warmup, durationSec: warmupSec, targetHR: calc.zone2))
        for _ in 0..<max(1, repeats) {
            intervals.append(.init(kind: .hard, durationSec: hardSec, targetHR: calc.fourByFourHard))
            intervals.append(.init(kind: .recovery, durationSec: recoverySec, targetHR: calc.zone2))
        }
        intervals.append(.init(kind: .cooldown, durationSec: cooldownSec, targetHR: calc.range(for: .zone1)))
        return intervals
    }

    /// Recommended number of hard blocks for the day's readiness: a low-readiness day
    /// drops to 3 to protect recovery; otherwise the full 4.
    public static func recommendedRepeats(for readiness: ReadinessLabel?) -> Int {
        readiness == .easy ? 3 : repeats
    }

    /// Total wall-clock duration of the session, in seconds.
    public static var totalDurationSec: Int {
        warmupSec + repeats * (hardSec + recoverySec) + cooldownSec
    }
}
