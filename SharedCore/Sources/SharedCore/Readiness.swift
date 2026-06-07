import Foundation

/// How hard the body looks ready to train today.
public enum ReadinessLabel: Sendable {
    case goHard
    case steady
    case easy

    /// A short, one-line training recommendation for the day.
    public var recommendation: String {
        switch self {
        case .goHard: return "Great day for a hard 4×4."
        case .steady: return "Steady aerobic work today."
        case .easy:   return "Prioritise recovery — keep it easy or rest."
        }
    }
}

/// A 0–100 readiness score with its qualitative label.
public struct ReadinessScore: Sendable, Equatable {
    /// Clamped to 0...100.
    public let value: Int
    public let label: ReadinessLabel

    public init(value: Int, label: ReadinessLabel) {
        self.value = value
        self.label = label
    }
}

/// Derives a daily readiness score from recent HRV and resting heart rate,
/// each compared against the user's own trailing baseline. Pure + deterministic.
public enum ReadinessCalculator {
    /// Trailing baseline window (days before today) used to establish a personal baseline.
    static let baselineWindowDays = 28
    /// Most recent slice of the window excluded so "today" isn't part of its own baseline.
    static let excludeRecentDays = 1
    /// Minimum HRV baseline samples required to produce a score.
    static let minimumHRVSamples = 3

    /// Computes a readiness score, or nil when there isn't enough history.
    ///
    /// Higher HRV vs baseline raises readiness; higher resting HR vs baseline lowers it.
    /// - Returns: A `ReadinessScore` in 0...100, or nil when HRV history is insufficient.
    public static func score(
        hrv: [MetricSample],
        restingHR: [MetricSample],
        now: Date = .now,
        calendar: Calendar = .current
    ) -> ReadinessScore? {
        let today = calendar.startOfDay(for: now)
        guard let windowStart = calendar.date(byAdding: .day, value: -baselineWindowDays, to: today),
              let baselineEnd = calendar.date(byAdding: .day, value: -excludeRecentDays, to: today) else {
            return nil
        }

        let hrvSorted = hrv.sorted { $0.date < $1.date }
        let hrvBaselineSamples = hrvSorted.filter { $0.date >= windowStart && $0.date < baselineEnd }
        guard hrvBaselineSamples.count >= minimumHRVSamples,
              let todayHRV = hrvSorted.last?.value else {
            return nil
        }
        let hrvBaseline = mean(hrvBaselineSamples)
        guard hrvBaseline > 0 else { return nil }

        // HRV component: ratio of today vs baseline, centred on 0 (1.0 ratio = neutral).
        // ±25% swing maps to roughly ±50 points before clamping.
        let hrvRatio = todayHRV / hrvBaseline
        let hrvComponent = (hrvRatio - 1.0) * 200.0

        // Resting-HR component (optional): higher than baseline subtracts readiness.
        var rhrComponent = 0.0
        let rhrSorted = restingHR.sorted { $0.date < $1.date }
        let rhrBaselineSamples = rhrSorted.filter { $0.date >= windowStart && $0.date < baselineEnd }
        if let todayRHR = rhrSorted.last?.value, !rhrBaselineSamples.isEmpty {
            let rhrBaseline = mean(rhrBaselineSamples)
            if rhrBaseline > 0 {
                let rhrRatio = todayRHR / rhrBaseline
                // Elevated RHR penalises; a lower-than-baseline RHR gives a small bonus.
                rhrComponent = -(rhrRatio - 1.0) * 200.0
            }
        }

        let raw = 50.0 + hrvComponent + rhrComponent
        let value = Int(raw.rounded()).clamped(to: 0...100)
        return ReadinessScore(value: value, label: label(for: value))
    }

    static func label(for value: Int) -> ReadinessLabel {
        if value >= 67 { return .goHard }
        if value >= 34 { return .steady }
        return .easy
    }

    private static func mean(_ samples: [MetricSample]) -> Double {
        guard !samples.isEmpty else { return 0 }
        return samples.reduce(0) { $0 + $1.value } / Double(samples.count)
    }
}

private extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
