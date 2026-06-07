import Foundation
import Testing
@testable import SharedCore

@Suite("Readiness")
struct ReadinessTests {
    let cal = Calendar(identifier: .gregorian)
    let now = Date(timeIntervalSince1970: 1_700_000_000)  // fixed reference

    /// Builds samples at `value` for `daysAgo` from `now` (0 = today).
    private func series(_ pairs: [(daysAgo: Int, value: Double)]) -> [MetricSample] {
        let today = cal.startOfDay(for: now)
        return pairs.compactMap { pair in
            guard let d = cal.date(byAdding: .day, value: -pair.daysAgo, to: today) else { return nil }
            return MetricSample(date: d, value: pair.value)
        }
    }

    @Test("Above baseline reads high and labels Go hard")
    func aboveBaseline() {
        // Baseline HRV ~50ms across prior week; today spikes to 70ms. RHR at/below baseline.
        let hrv = series([
            (7, 50), (6, 49), (5, 51), (4, 50), (3, 50), (2, 49), (0, 70)
        ])
        let rhr = series([
            (7, 55), (6, 55), (5, 54), (4, 56), (3, 55), (2, 55), (0, 52)
        ])
        let score = ReadinessCalculator.score(hrv: hrv, restingHR: rhr, now: now, calendar: cal)
        let s = try! #require(score)
        #expect(s.value >= 67)
        #expect(s.label == .goHard)
    }

    @Test("Below baseline (low HRV, high RHR) reads low and labels easy")
    func belowBaseline() {
        let hrv = series([
            (7, 50), (6, 51), (5, 49), (4, 50), (3, 50), (2, 51), (0, 32)
        ])
        let rhr = series([
            (7, 54), (6, 54), (5, 55), (4, 54), (3, 55), (2, 54), (0, 64)
        ])
        let score = ReadinessCalculator.score(hrv: hrv, restingHR: rhr, now: now, calendar: cal)
        let s = try! #require(score)
        #expect(s.value < 34)
        #expect(s.label == .easy)
    }

    @Test("Insufficient HRV history returns nil")
    func insufficientData() {
        let hrv = series([(2, 50), (0, 55)])  // only 1 baseline sample (< minimum)
        let rhr = series([(2, 55), (0, 54)])
        #expect(ReadinessCalculator.score(hrv: hrv, restingHR: rhr, now: now, calendar: cal) == nil)
    }

    @Test("Empty HRV returns nil")
    func emptyData() {
        #expect(ReadinessCalculator.score(hrv: [], restingHR: [], now: now, calendar: cal) == nil)
    }

    @Test("At baseline reads steady")
    func atBaseline() {
        let hrv = series([
            (7, 50), (6, 50), (5, 50), (4, 50), (3, 50), (2, 50), (0, 50)
        ])
        let rhr = series([
            (7, 55), (6, 55), (5, 55), (4, 55), (3, 55), (2, 55), (0, 55)
        ])
        let s = try! #require(ReadinessCalculator.score(hrv: hrv, restingHR: rhr, now: now, calendar: cal))
        #expect(s.value == 50)
        #expect(s.label == .steady)
    }

    @Test("Recommendations are distinct per label")
    func recommendations() {
        #expect(ReadinessLabel.goHard.recommendation != ReadinessLabel.steady.recommendation)
        #expect(ReadinessLabel.steady.recommendation != ReadinessLabel.easy.recommendation)
    }
}
