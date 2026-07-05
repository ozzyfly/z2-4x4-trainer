import Foundation
import Testing
@testable import SharedCore

@Suite("Readiness — wrist temperature and sleep signals")
struct ReadinessExtendedSignalsTests {
    private let cal = Calendar.current
    private let now = Date(timeIntervalSinceReferenceDate: 790_000_000)

    private func daily(_ daysAgo: Int, _ value: Double) -> MetricSample {
        MetricSample(date: cal.date(byAdding: .day, value: -daysAgo, to: now)!, value: value)
    }

    /// Neutral HRV/RHR history (today == baseline) so the base score is ~50 and
    /// the new signals' contribution is isolated.
    private var neutralHRV: [MetricSample] { (0...14).map { daily($0, 60) } }
    private var neutralRHR: [MetricSample] { (0...14).map { daily($0, 55) } }

    private func baselineScore() -> Int {
        ReadinessCalculator.score(hrv: neutralHRV, restingHR: neutralRHR, now: now)!.value
    }

    @Test("elevated wrist temperature subtracts and adds the signal")
    func tempElevated() {
        // 14-day baseline at 34.0°C, today at +0.6°C.
        var temps = (1...14).map { daily($0, 34.0) }
        temps.append(daily(0, 34.6))
        let s = ReadinessCalculator.score(
            hrv: neutralHRV, restingHR: neutralRHR, wristTemp: temps, now: now)!
        #expect(s.value == baselineScore() - 25)
        #expect(s.signals.contains(.wristTempElevated))
    }

    @Test("mildly elevated temperature applies the smaller penalty")
    func tempMild() {
        var temps = (1...14).map { daily($0, 34.0) }
        temps.append(daily(0, 34.35))
        let s = ReadinessCalculator.score(
            hrv: neutralHRV, restingHR: neutralRHR, wristTemp: temps, now: now)!
        #expect(s.value == baselineScore() - 15)
    }

    @Test("normal temperature changes nothing")
    func tempNormal() {
        var temps = (1...14).map { daily($0, 34.0) }
        temps.append(daily(0, 34.1))
        let s = ReadinessCalculator.score(
            hrv: neutralHRV, restingHR: neutralRHR, wristTemp: temps, now: now)!
        #expect(s.value == baselineScore())
        #expect(!s.signals.contains(.wristTempElevated))
    }

    @Test("too few temperature baseline samples are ignored")
    func tempThinBaseline() {
        // Only 3 baseline days — below minimumTempSamples; a big spike must not count.
        var temps = (1...3).map { daily($0, 34.0) }
        temps.append(daily(0, 35.0))
        let s = ReadinessCalculator.score(
            hrv: neutralHRV, restingHR: neutralRHR, wristTemp: temps, now: now)!
        #expect(s.value == baselineScore())
    }

    @Test("short sleep penalises in two tiers; zero/unknown never counts")
    func sleep() {
        let base = baselineScore()
        let short = ReadinessCalculator.score(
            hrv: neutralHRV, restingHR: neutralRHR, sleepHours: 5.5, now: now)!
        #expect(short.value == base - 10)
        #expect(short.signals.contains(.sleepShort))

        let veryShort = ReadinessCalculator.score(
            hrv: neutralHRV, restingHR: neutralRHR, sleepHours: 4.0, now: now)!
        #expect(veryShort.value == base - 20)

        let normal = ReadinessCalculator.score(
            hrv: neutralHRV, restingHR: neutralRHR, sleepHours: 7.5, now: now)!
        #expect(normal.value == base)

        // 0 means "no sleep data written", not a 0-hour night.
        let zero = ReadinessCalculator.score(
            hrv: neutralHRV, restingHR: neutralRHR, sleepHours: 0, now: now)!
        #expect(zero.value == base)
    }

    @Test("existing two-argument call sites are unaffected")
    func backwardCompatible() {
        let s = ReadinessCalculator.score(hrv: neutralHRV, restingHR: neutralRHR, now: now)
        #expect(s != nil)
        #expect(s!.value == baselineScore())
    }
}
