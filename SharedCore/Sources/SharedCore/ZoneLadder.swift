import Foundation

/// Validation + repair helpers for a set of custom heart-rate zone bands.
///
/// Manual entry can produce bands that aren't a clean ascending ladder (e.g. Zone 2's
/// upper above Zone 4's lower, or Zone 5's ceiling below Zone 4's floor). That breaks
/// `HRZoneCalculator.zone(forBPM:)` (which scans zones by their lower bound) and the
/// custom 4×4 hard band (Zone 4 floor → Zone 5 ceiling), so the UI warns and offers a fix.
public extension Array where Element == HRRange {
    /// True when the bands form an ascending ladder: each zone's lower and upper are
    /// ≥ the previous zone's. A single band (or none) is trivially ordered.
    var isAscendingZoneLadder: Bool {
        guard count > 1 else { return true }
        for i in 1..<count where self[i].lower < self[i - 1].lower || self[i].upper < self[i - 1].upper {
            return false
        }
        return true
    }

    /// Reorders the bands into a valid ascending ladder: sorted by lower bound, with
    /// each upper raised to at least its own lower and the previous band's upper so
    /// the result always satisfies `isAscendingZoneLadder`.
    func sortedAscendingLadder() -> [HRRange] {
        var ladder = sorted { $0.lower < $1.lower }
        var prevUpper = Int.min
        for i in ladder.indices {
            let lower = ladder[i].lower
            let upper = Swift.max(ladder[i].upper, lower, prevUpper)
            ladder[i] = HRRange(lower: lower, upper: upper)
            prevUpper = upper
        }
        return ladder
    }
}
