import Foundation

/// A completed workout in pure-domain form. The app maps its SwiftData `WorkoutLog`
/// onto this so the coach and streak logic stay free of persistence types.
public struct WorkoutRecord: Sendable, Equatable {
    public let date: Date
    public let type: SessionType
    public let durationMin: Int
    public let energyKcal: Int?

    public init(date: Date, type: SessionType, durationMin: Int, energyKcal: Int? = nil) {
        self.date = date
        self.type = type
        self.durationMin = durationMin
        self.energyKcal = energyKcal
    }

    /// Bridges to `ActivitySample` so existing aggregation reuse applies unchanged.
    public var sample: ActivitySample {
        ActivitySample(date: date, minutes: durationMin, energyKcal: energyKcal)
    }
}
