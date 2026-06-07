import Foundation

/// A single dated VO2max reading, typically from Apple Health.
public struct VO2MaxSample: Sendable, Equatable {
    public let date: Date
    public let value: Double

    public init(date: Date, value: Double) {
        self.date = date
        self.value = value
    }
}

/// A summarised VO2max trend: the latest value and how far it has moved since the first.
public struct FitnessTrend: Sendable, Equatable {
    /// Most recent VO2max value.
    public let latest: Double
    /// Latest minus earliest (positive = improving fitness).
    public let deltaFromFirst: Double
    /// All samples, sorted oldest → newest.
    public let samples: [VO2MaxSample]

    public init(latest: Double, deltaFromFirst: Double, samples: [VO2MaxSample]) {
        self.latest = latest
        self.deltaFromFirst = deltaFromFirst
        self.samples = samples
    }

    /// Builds a trend from raw samples, sorting by date. Returns nil when there are none,
    /// so callers can show a friendly empty state instead of an empty chart.
    public static func from(_ samples: [VO2MaxSample]) -> FitnessTrend? {
        guard !samples.isEmpty else { return nil }
        let sorted = samples.sorted { $0.date < $1.date }
        let earliest = sorted.first!.value
        let latest = sorted.last!.value
        return FitnessTrend(
            latest: latest,
            deltaFromFirst: latest - earliest,
            samples: sorted
        )
    }
}
