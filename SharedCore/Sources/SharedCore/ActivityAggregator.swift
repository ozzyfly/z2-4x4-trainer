import Foundation

/// A completed bit of activity, from any source (manual log or Apple Health).
public struct ActivitySample: Sendable, Equatable {
    public let date: Date
    public let minutes: Int
    public let energyKcal: Int?

    public init(date: Date, minutes: Int, energyKcal: Int? = nil) {
        self.date = date
        self.minutes = minutes
        self.energyKcal = energyKcal
    }
}

/// Pure aggregation of activity samples into daily / weekly totals.
public enum ActivityAggregator {
    /// Total minutes on the same calendar day as `day`.
    public static func minutes(in samples: [ActivitySample], on day: Date,
                               calendar: Calendar = .current) -> Int {
        samples.filter { calendar.isDate($0.date, inSameDayAs: day) }
            .reduce(0) { $0 + $1.minutes }
    }

    /// Total minutes in the same week as `week`.
    public static func weeklyMinutes(in samples: [ActivitySample], for week: Date,
                                     calendar: Calendar = .current) -> Int {
        samples.filter { calendar.isDate($0.date, equalTo: week, toGranularity: .weekOfYear) }
            .reduce(0) { $0 + $1.minutes }
    }

    /// Total active energy in the same calendar day as `day`.
    public static func energy(in samples: [ActivitySample], on day: Date,
                              calendar: Calendar = .current) -> Int {
        samples.filter { calendar.isDate($0.date, inSameDayAs: day) }
            .reduce(0) { $0 + ($1.energyKcal ?? 0) }
    }

    /// Minutes per weekday for the week containing `week`, indexed 0 = Monday … 6 = Sunday.
    public static func weeklyMinutesByWeekday(in samples: [ActivitySample], for week: Date,
                                              calendar: Calendar = .current) -> [Int] {
        var totals = [Int](repeating: 0, count: 7)
        for s in samples where calendar.isDate(s.date, equalTo: week, toGranularity: .weekOfYear) {
            let cw = calendar.component(.weekday, from: s.date)   // 1=Sun…7=Sat
            let index = (cw + 5) % 7                              // 0=Mon…6=Sun
            totals[index] += s.minutes
        }
        return totals
    }
}
