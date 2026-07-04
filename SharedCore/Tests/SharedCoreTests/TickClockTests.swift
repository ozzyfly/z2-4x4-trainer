import Foundation
import Testing
@testable import SharedCore

@Suite("Tick clock")
struct TickClockTests {
    private let t0 = Date(timeIntervalSinceReferenceDate: 1_000_000)

    @Test("not running yields no ticks")
    func idle() {
        var clock = TickClock()
        #expect(!clock.isRunning)
        #expect(clock.consumeDue(at: t0) == 0)
    }

    @Test("one tick per elapsed second")
    func steady() {
        var clock = TickClock()
        clock.start(at: t0)
        #expect(clock.consumeDue(at: t0.addingTimeInterval(1)) == 1)
        #expect(clock.consumeDue(at: t0.addingTimeInterval(2)) == 1)
        #expect(clock.consumeDue(at: t0.addingTimeInterval(3)) == 1)
    }

    @Test("missed seconds are replayed as catch-up ticks")
    func catchUp() {
        var clock = TickClock()
        clock.start(at: t0)
        // Timer stalled for 7.5s (wrist down) → 7 whole ticks due.
        #expect(clock.consumeDue(at: t0.addingTimeInterval(7.5)) == 7)
        // The 0.5s fraction carries: 1s later another whole tick is due.
        #expect(clock.consumeDue(at: t0.addingTimeInterval(8.5)) == 1)
    }

    @Test("fractional remainders never drift long-run")
    func noDrift() {
        var clock = TickClock()
        clock.start(at: t0)
        var total = 0
        // 100 fires at 1.3s apart = 130s of wall time.
        for i in 1...100 {
            total += clock.consumeDue(at: t0.addingTimeInterval(Double(i) * 1.3))
        }
        #expect(total == 130)
    }

    @Test("pause stops ticking; restart forgets paused time")
    func pauseResume() {
        var clock = TickClock()
        clock.start(at: t0)
        _ = clock.consumeDue(at: t0.addingTimeInterval(5))
        clock.pause()
        #expect(clock.consumeDue(at: t0.addingTimeInterval(60)) == 0)
        clock.start(at: t0.addingTimeInterval(60))
        // Only time after the restart counts.
        #expect(clock.consumeDue(at: t0.addingTimeInterval(62)) == 2)
    }

    @Test("huge stalls are capped and the excess dropped")
    func capped() {
        var clock = TickClock(maxCatchUp: 10)
        clock.start(at: t0)
        #expect(clock.consumeDue(at: t0.addingTimeInterval(1000)) == 10)
        // Excess was dropped — next second yields exactly one tick.
        #expect(clock.consumeDue(at: t0.addingTimeInterval(1001)) == 1)
    }

    @Test("clock going backwards re-anchors instead of stalling")
    func backwards() {
        var clock = TickClock()
        clock.start(at: t0)
        #expect(clock.consumeDue(at: t0.addingTimeInterval(-30)) == 0)
        // Re-anchored at t0-30 → 2s later, 2 ticks.
        #expect(clock.consumeDue(at: t0.addingTimeInterval(-28)) == 2)
    }
}
