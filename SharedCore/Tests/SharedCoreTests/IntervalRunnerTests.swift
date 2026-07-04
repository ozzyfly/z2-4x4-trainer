import Testing
@testable import SharedCore

@Suite("IntervalRunner (adaptive timing)")
struct IntervalRunnerTests {
    private let z2 = HRRange(lower: 120, upper: 140)
    private let hardBand = HRRange(lower: 160, upper: 180)

    // MARK: Warmup

    @Test("warmup ends at the minimum once HR reaches Zone 2")
    func warmupEndsWhenWarm() {
        var r = IntervalRunner(
            intervals: [
                .init(kind: .warmup, durationSec: 300, targetHR: z2),
                .init(kind: .hard, durationSec: 240, targetHR: hardBand),
            ],
            warmupMinSec: 120
        )
        // At the top of Zone 2 from the start, but the floor keeps us warming until 120 s.
        for _ in 0..<119 { _ = r.tick(heartRate: 140) }
        #expect(r.currentIndex == 0)

        let events = r.tick(heartRate: 140) // 120th second
        #expect(events == [.enteredSegment(.hard)])
        #expect(r.currentIndex == 1)
    }

    @Test("warmup holds past the minimum until HR reaches Zone 2")
    func warmupWaitsForHR() {
        var r = IntervalRunner(
            intervals: [
                .init(kind: .warmup, durationSec: 300, targetHR: z2),
                .init(kind: .hard, durationSec: 240, targetHR: hardBand),
            ],
            warmupMinSec: 120
        )
        // Never warm enough → can't end early; runs to the prescribed max.
        for _ in 0..<299 { _ = r.tick(heartRate: 100) }
        #expect(r.currentIndex == 0)
        let events = r.tick(heartRate: 100) // 300th second → hard max cap
        #expect(events == [.enteredSegment(.hard)])
        #expect(r.currentIndex == 1)
    }

    // MARK: Hard

    @Test("hard budget only counts time in the target band")
    func hardCountsInZoneOnly() {
        var r = IntervalRunner(
            intervals: [
                .init(kind: .hard, durationSec: 3, targetHR: hardBand),
                .init(kind: .cooldown, durationSec: 1, targetHR: nil),
            ],
            hardWallCapSec: 1000
        )
        // Below target: clock holds, PUSH cue appears once.
        #expect(r.tick(heartRate: 100) == [.cue(.push)])
        #expect(r.tick(heartRate: 100) == []) // cue already showing
        #expect(r.secondsRemaining == 3)      // budget untouched
        #expect(r.currentIndex == 0)

        // In zone: budget ticks down; 3 in-zone seconds complete the effort.
        _ = r.tick(heartRate: 170)
        #expect(r.coachingCue == nil)
        #expect(r.secondsRemaining == 2)
        _ = r.tick(heartRate: 170)
        #expect(r.secondsRemaining == 1)
        let done = r.tick(heartRate: 170)
        #expect(done == [.enteredSegment(.cooldown)])
        #expect(r.currentIndex == 1)
    }

    @Test("hard ends at the wall-clock cap when the zone is never reached")
    func hardWallCap() {
        var r = IntervalRunner(
            intervals: [
                .init(kind: .hard, durationSec: 240, targetHR: hardBand),
                .init(kind: .cooldown, durationSec: 1, targetHR: nil),
            ],
            hardWallCapSec: 5
        )
        for _ in 0..<4 { _ = r.tick(heartRate: 100) }
        #expect(r.currentIndex == 0)
        let events = r.tick(heartRate: 100) // 5th second → cap
        #expect(events == [.enteredSegment(.cooldown)])
        #expect(r.currentIndex == 1)
    }

    // MARK: Recovery

    @Test("recovery advances once HR drops back into Zone 2")
    func recoveryAdvancesWhenRecovered() {
        var r = IntervalRunner(
            intervals: [
                .init(kind: .recovery, durationSec: 180, targetHR: z2),
                .init(kind: .cooldown, durationSec: 1, targetHR: nil),
            ],
            recoveryMinSec: 30
        )
        // Already recovered, but the floor keeps recovery going to 30 s.
        for _ in 0..<29 { _ = r.tick(heartRate: 130) }
        #expect(r.currentIndex == 0)
        let events = r.tick(heartRate: 130) // 30th second
        #expect(events == [.enteredSegment(.cooldown)])
    }

    @Test("recovery raises an ease-off cue until HR settles, capped by duration")
    func recoveryEaseOffAndMaxCap() {
        var r = IntervalRunner(
            intervals: [
                .init(kind: .recovery, durationSec: 180, targetHR: z2),
                .init(kind: .cooldown, durationSec: 1, targetHR: nil),
            ],
            recoveryMinSec: 30
        )
        #expect(r.tick(heartRate: 165) == [.cue(.easeOff)])
        #expect(r.coachingCue == .easeOff)
        // Stays elevated → only the prescribed max ends it.
        for _ in 0..<178 { _ = r.tick(heartRate: 165) }
        #expect(r.currentIndex == 0)
        let events = r.tick(heartRate: 165) // 180th second → max cap
        #expect(events == [.enteredSegment(.cooldown)])
    }

    // MARK: Cooldown + completion

    @Test("cooldown is a plain countdown that finishes the session")
    func cooldownFinishes() {
        var r = IntervalRunner(
            intervals: [.init(kind: .cooldown, durationSec: 2, targetHR: nil)]
        )
        #expect(r.tick(heartRate: 90) == [])
        #expect(r.secondsRemaining == 1)
        let events = r.tick(heartRate: 90)
        #expect(events == [.finished])
        #expect(r.isFinished)
        #expect(r.currentInterval == nil)
    }

    // MARK: No heart rate

    @Test("falls back to timed intervals after heart rate is lost")
    func noHeartRateFallback() {
        var r = IntervalRunner(
            intervals: [
                .init(kind: .hard, durationSec: 10, targetHR: hardBand),
                .init(kind: .cooldown, durationSec: 1, targetHR: nil),
            ],
            hardWallCapSec: 1000,
            noHRGraceSec: 5
        )
        #expect(r.tick(heartRate: 0) == [.cue(.push)]) // tick 1
        for _ in 0..<3 { _ = r.tick(heartRate: 0) }    // ticks 2–4
        #expect(!r.isBlind)

        let lost = r.tick(heartRate: 0) // tick 5 → grace exceeded
        #expect(lost.contains(.heartRateLost))
        #expect(r.isBlind)
        #expect(r.coachingCue == nil)

        // Blind, the hard segment ends at its prescribed 10 s — not the 1000 s cap.
        var advanced = false
        for _ in 0..<5 where r.tick(heartRate: 0).contains(.enteredSegment(.cooldown)) {
            advanced = true
        }
        #expect(advanced)
    }

    @Test("resumes adaptive timing when heart rate returns")
    func heartRateRestored() {
        var r = IntervalRunner(
            intervals: [
                .init(kind: .hard, durationSec: 10, targetHR: hardBand),
                .init(kind: .cooldown, durationSec: 1, targetHR: nil),
            ],
            hardWallCapSec: 1000,
            noHRGraceSec: 3
        )
        for _ in 0..<3 { _ = r.tick(heartRate: 0) } // → blind on the 3rd
        #expect(r.isBlind)
        let restored = r.tick(heartRate: 170)
        #expect(restored.contains(.heartRateRestored))
        #expect(!r.isBlind)
    }

    // MARK: Recovery individualization

    @Test("recovery completes via drop-from-peak even while above Zone 2")
    func recoveryDropFromPeak() {
        var r = IntervalRunner(
            intervals: [
                .init(kind: .hard, durationSec: 2, targetHR: hardBand),
                .init(kind: .recovery, durationSec: 180, targetHR: z2),
                .init(kind: .cooldown, durationSec: 1, targetHR: nil),
            ],
            recoveryMinSec: 30,
            recoveryDropBpm: 30
        )
        _ = r.tick(heartRate: 190) // bank the hard effort at peak 190…
        #expect(r.tick(heartRate: 190).contains(.enteredSegment(.recovery)))
        // 158 is above Zone 2 (140) but ≥30 below the 190 peak → counts as recovered.
        var advanced = false
        for _ in 0..<30 where r.tick(heartRate: 158).contains(.enteredSegment(.cooldown)) {
            advanced = true
        }
        #expect(advanced)
        #expect(r.recoveriesCompleted == 1)
    }

    // MARK: Quality summary

    @Test("a fully completed session scores 100 and records every rep")
    func summaryFullQuality() {
        var r = IntervalRunner(
            intervals: [
                .init(kind: .hard, durationSec: 4, targetHR: hardBand),
                .init(kind: .recovery, durationSec: 5, targetHR: z2),
                .init(kind: .hard, durationSec: 4, targetHR: hardBand),
                .init(kind: .recovery, durationSec: 5, targetHR: z2),
                .init(kind: .cooldown, durationSec: 2, targetHR: nil),
            ],
            recoveryMinSec: 1
        )
        for _ in 0..<200 {
            guard let seg = r.currentInterval else { break }
            _ = r.tick(heartRate: seg.kind == .hard ? 170 : 130)
            if r.isFinished { break }
        }
        let s = r.summary
        #expect(s.hardReps.count == 2)
        #expect(s.repsCompletedFully == 2)
        #expect(s.recoveriesCompleted == 2)
        #expect(s.qualityScore == 100)
        #expect(s.peakHR == 170)
    }

    @Test("quitting after one rep scores low")
    func summaryPartial() {
        var r = IntervalRunner(
            intervals: [
                .init(kind: .hard, durationSec: 4, targetHR: hardBand),
                .init(kind: .recovery, durationSec: 5, targetHR: z2),
                .init(kind: .hard, durationSec: 4, targetHR: hardBand),
                .init(kind: .recovery, durationSec: 5, targetHR: z2),
                .init(kind: .cooldown, durationSec: 2, targetHR: nil),
            ],
            recoveryMinSec: 1
        )
        for _ in 0..<4 { _ = r.tick(heartRate: 170) } // only the first hard effort
        let s = r.summary
        #expect(s.hardReps.count == 1)
        // 4 of 8 planned hard seconds (0.5) · 0.8 + 0 recovery · 0.2 = 0.4 → 40
        #expect(s.qualityScore == 40)
    }

    // MARK: Full session

    @Test("a compliant athlete completes the whole Norwegian 4×4")
    func fullSessionCompletes() {
        let calc = HRZoneCalculator(maxHR: 190)
        var r = IntervalRunner(intervals: Norwegian4x4.build(using: calc))

        var finished = false
        // Simulate an athlete who always sits at each segment's target floor.
        for _ in 0..<10_000 {
            guard let seg = r.currentInterval else { break }
            let hr = seg.targetHR?.lower ?? 100
            for event in r.tick(heartRate: hr) where event == .finished {
                finished = true
            }
            if finished { break }
        }
        #expect(finished)
        #expect(r.isFinished)
        #expect(r.currentInterval == nil)
    }
}
