import Foundation

/// How hard the body looks ready to train today.
/// String raw values keep the label codec-stable for widget snapshots and sync payloads.
public enum ReadinessLabel: String, Codable, Sendable, CaseIterable {
    case goHard
    case steady
    case easy

    /// A short, one-line training recommendation for the day.
    public var recommendation: String {
        switch self {
        case .goHard: return String(localized: "Great day for a hard 4×4.", bundle: .module)
        case .steady: return String(localized: "Steady aerobic work today.", bundle: .module)
        case .easy:   return String(localized: "Prioritise recovery — keep it easy or rest.", bundle: .module)
        }
    }
}

/// Inputs that most influenced today's readiness score.
public enum ReadinessSignal: String, Sendable, Equatable {
    case hrvAboveBaseline
    case hrvNearBaseline
    case hrvBelowBaseline
    case restingHRBelowBaseline
    case restingHRNearBaseline
    case restingHRAboveBaseline
    case restingHRMissing

    public var explanation: String {
        switch self {
        case .hrvAboveBaseline:
            return String(localized: "HRV is above your 28-day baseline.", bundle: .module)
        case .hrvNearBaseline:
            return String(localized: "HRV is close to your 28-day baseline.", bundle: .module)
        case .hrvBelowBaseline:
            return String(localized: "HRV is below your 28-day baseline.", bundle: .module)
        case .restingHRBelowBaseline:
            return String(localized: "Resting heart rate is below baseline.", bundle: .module)
        case .restingHRNearBaseline:
            return String(localized: "Resting heart rate is near baseline.", bundle: .module)
        case .restingHRAboveBaseline:
            return String(localized: "Resting heart rate is elevated.", bundle: .module)
        case .restingHRMissing:
            return String(localized: "Resting heart-rate history is still limited.", bundle: .module)
        }
    }
}

/// A 0–100 readiness score with its qualitative label.
public struct ReadinessScore: Sendable, Equatable {
    /// Clamped to 0...100.
    public let value: Int
    public let label: ReadinessLabel
    /// Short, user-facing signals explaining why the score landed here.
    public let signals: [ReadinessSignal]

    public init(value: Int, label: ReadinessLabel, signals: [ReadinessSignal] = []) {
        self.value = value
        self.label = label
        self.signals = signals
    }

    public var explanation: String {
        guard !signals.isEmpty else {
            return String(localized: "Based on your recent HRV and resting heart-rate trend.", bundle: .module)
        }
        return signals.map(\.explanation).joined(separator: " ")
    }

    public var actionRecommendation: String {
        if signals.contains(.hrvBelowBaseline) && signals.contains(.restingHRAboveBaseline) {
            return String(localized: "Make today Zone 2 or rest; save 4×4 for a fresher day.", bundle: .module)
        }
        switch label {
        case .goHard:
            return String(localized: "Good day to follow the planned hard session if one is scheduled.", bundle: .module)
        case .steady:
            return String(localized: "Follow the plan, but keep the first interval honest before pushing harder.", bundle: .module)
        case .easy:
            return String(localized: "Reduce intensity today: easy Zone 2, mobility, or rest.", bundle: .module)
        }
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
        var signals = [hrvSignal(for: hrvRatio)]

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
                signals.append(rhrSignal(for: rhrRatio))
            } else {
                signals.append(.restingHRMissing)
            }
        } else {
            signals.append(.restingHRMissing)
        }

        let raw = 50.0 + hrvComponent + rhrComponent
        let value = Int(raw.rounded()).clamped(to: 0...100)
        return ReadinessScore(value: value, label: label(for: value), signals: signals)
    }

    static func label(for value: Int) -> ReadinessLabel {
        if value >= 67 { return .goHard }
        if value >= 34 { return .steady }
        return .easy
    }

    private static func hrvSignal(for ratio: Double) -> ReadinessSignal {
        if ratio >= 1.08 { return .hrvAboveBaseline }
        if ratio <= 0.92 { return .hrvBelowBaseline }
        return .hrvNearBaseline
    }

    private static func rhrSignal(for ratio: Double) -> ReadinessSignal {
        if ratio >= 1.05 { return .restingHRAboveBaseline }
        if ratio <= 0.95 { return .restingHRBelowBaseline }
        return .restingHRNearBaseline
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
