import Foundation

/// A single dated health metric reading (e.g. HRV or resting heart rate), typically from Apple Health.
public struct MetricSample: Sendable, Equatable {
    public let date: Date
    public let value: Double

    public init(date: Date, value: Double) {
        self.date = date
        self.value = value
    }
}
