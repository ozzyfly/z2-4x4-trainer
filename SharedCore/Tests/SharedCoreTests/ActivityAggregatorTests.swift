import Foundation
import Testing
@testable import SharedCore

@Suite("Activity aggregation")
struct ActivityAggregatorTests {
    private var cal: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "UTC")!
        return c
    }()

    private func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
        DateComponents(calendar: cal, year: y, month: m, day: d, hour: 12).date!
    }

    @Test("daily minutes sum only that day")
    func dailyMinutes() {
        let mon = date(2026, 6, 1)
        let samples = [
            ActivitySample(date: mon, minutes: 30),
            ActivitySample(date: mon, minutes: 15),
            ActivitySample(date: date(2026, 6, 2), minutes: 40),
        ]
        #expect(ActivityAggregator.minutes(in: samples, on: mon, calendar: cal) == 45)
    }

    @Test("daily energy sums kcal, treating nil as zero")
    func dailyEnergy() {
        let mon = date(2026, 6, 1)
        let samples = [
            ActivitySample(date: mon, minutes: 30, energyKcal: 300),
            ActivitySample(date: mon, minutes: 15, energyKcal: nil),
        ]
        #expect(ActivityAggregator.energy(in: samples, on: mon, calendar: cal) == 300)
    }

    @Test("weekly minutes sum across the week")
    func weeklyMinutes() {
        // 2026-06-01 Mon … 2026-06-07 Sun are one week.
        let samples = [
            ActivitySample(date: date(2026, 6, 1), minutes: 40),
            ActivitySample(date: date(2026, 6, 3), minutes: 43),
            ActivitySample(date: date(2026, 6, 8), minutes: 50),   // next week
        ]
        #expect(ActivityAggregator.weeklyMinutes(in: samples, for: date(2026, 6, 1), calendar: cal) == 83)
    }

    @Test("minutes bucketed by weekday, Monday first")
    func byWeekday() {
        let samples = [
            ActivitySample(date: date(2026, 6, 1), minutes: 40),   // Mon → index 0
            ActivitySample(date: date(2026, 6, 3), minutes: 43),   // Wed → index 2
        ]
        let buckets = ActivityAggregator.weeklyMinutesByWeekday(in: samples, for: date(2026, 6, 1), calendar: cal)
        #expect(buckets == [40, 0, 43, 0, 0, 0, 0])
    }
}
