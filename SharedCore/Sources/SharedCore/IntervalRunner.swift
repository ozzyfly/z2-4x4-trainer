import Foundation

/// A live coaching nudge for the current moment.
public enum CoachingCue: Equatable, Sendable {
    /// Hard effort, but HR is below the target band — work harder.
    case push
    /// Recovery, but HR hasn't dropped back into Zone 2 yet — slow down.
    case easeOff
}

/// Per-hard-effort statistics captured during a session.
public struct HardRepStat: Sendable, Equatable {
    /// In-zone seconds actually banked for this effort.
    public let bankedInZoneSec: Int
    /// The prescribed in-zone budget for this effort.
    public let budgetSec: Int
    /// Peak heart rate seen during the effort.
    public let peakHR: Int
    /// Average heart rate over the in-zone seconds (0 if none).
    public let avgHR: Int

    public init(bankedInZoneSec: Int, budgetSec: Int, peakHR: Int, avgHR: Int) {
        self.bankedInZoneSec = bankedInZoneSec
        self.budgetSec = budgetSec
        self.peakHR = peakHR
        self.avgHR = avgHR
    }

    /// True when the full in-zone budget was banked.
    public var completedFully: Bool { bankedInZoneSec >= budgetSec }
}

/// End-of-session quality summary for a Norwegian 4×4.
public struct FourByFourSummary: Sendable, Equatable {
    /// A 4×4 at or above this quality counts toward the weekly hard-session target.
    public static let creditQualityThreshold = 60

    public let hardReps: [HardRepStat]
    /// Total prescribed in-zone budget across all hard efforts (the denominator).
    public let plannedHardBudgetSec: Int
    /// Number of recovery segments in the plan.
    public let recoveryTargets: Int
    /// Recovery segments where HR actually settled back down.
    public let recoveriesCompleted: Int

    public init(hardReps: [HardRepStat], plannedHardBudgetSec: Int, recoveryTargets: Int, recoveriesCompleted: Int) {
        self.hardReps = hardReps
        self.plannedHardBudgetSec = plannedHardBudgetSec
        self.recoveryTargets = recoveryTargets
        self.recoveriesCompleted = recoveriesCompleted
    }

    /// Hard efforts that banked their full budget.
    public var repsCompletedFully: Int { hardReps.filter(\.completedFully).count }
    /// In-zone seconds banked across all efforts.
    public var totalInZoneSec: Int { hardReps.reduce(0) { $0 + $1.bankedInZoneSec } }
    /// Highest HR seen across all efforts.
    public var peakHR: Int { hardReps.map(\.peakHR).max() ?? 0 }
    /// Average of the per-rep in-zone average HRs (0 if none).
    public var avgHardHR: Int {
        let valid = hardReps.filter { $0.avgHR > 0 }
        guard !valid.isEmpty else { return 0 }
        return valid.reduce(0) { $0 + $1.avgHR } / valid.count
    }

    /// 0…100: 80% how much of the prescribed hard budget was banked, 20% recovery
    /// completeness. Reflects the *whole* prescribed session, so quitting early scores low.
    public var qualityScore: Int {
        let hardFrac = plannedHardBudgetSec > 0 ? Double(totalInZoneSec) / Double(plannedHardBudgetSec) : 0
        let recFrac = recoveryTargets > 0 ? Double(recoveriesCompleted) / Double(recoveryTargets) : 1
        let score = 0.8 * min(1, hardFrac) + 0.2 * min(1, recFrac)
        return Int((score * 100).rounded())
    }
}

/// Pure, synchronous state machine that drives a structured `Norwegian4x4` session
/// with **heart-rate adaptive** timing, so the athlete banks the HIIT stimulus
/// rather than the wall clock. No timer, no HealthKit, no haptics — fully testable.
///
/// The host advances it once per second with the latest heart rate via `tick(heartRate:)`,
/// reads the published state (`currentIndex`, `secondsRemaining`, `coachingCue`,
/// `isFinished`, `summary`), and reacts to the returned `Event`s (e.g. play haptics).
///
/// - **Warmup**: ends once HR reaches the *top* of Zone 2 (properly primed), bounded
///   by `warmupMinSec` as a minimum and the prescribed duration as a maximum.
/// - **Hard**: counts *time in the target band*. The budget only ticks down while HR
///   is in/above the target; drop out and the clock pauses with a `.push` cue. A
///   wall-clock safety cap (`hardWallCapSec`) ends the effort even if the zone is
///   never sustained.
/// - **Recovery**: advances once HR drops back into Zone 2 *or* falls `recoveryDropBpm`
///   below the effort's peak, bounded by `recoveryMinSec` and the prescribed duration.
/// - **Cooldown**: plain countdown.
public struct IntervalRunner: Sendable, Equatable {
    /// One thing that happened on a `tick`, for the host to react to (haptics, etc.).
    public enum Event: Equatable, Sendable {
        /// Advanced into a new segment of the given kind.
        case enteredSegment(IntervalKind)
        /// A coaching cue just appeared (fires once, on change).
        case cue(CoachingCue)
        /// No usable heart rate for a while — timing fell back to the wall clock.
        case heartRateLost
        /// Heart rate came back — adaptive timing resumed.
        case heartRateRestored
        /// The final segment elapsed; the session is complete.
        case finished
    }

    /// The full prescribed timeline (warmup → 4×(hard+recovery) → cooldown).
    public let intervals: [WorkoutInterval]

    /// Index of the segment currently in progress, or `intervals.count` once finished.
    public private(set) var currentIndex: Int

    /// Whole seconds left in the current segment. For hard segments this is the
    /// remaining *in-zone* budget (frozen whenever HR is below target).
    public private(set) var secondsRemaining: Int

    /// Live coaching nudge for the current moment, or nil.
    public private(set) var coachingCue: CoachingCue?

    /// True once the final segment has elapsed.
    public private(set) var isFinished: Bool

    /// Captured per-hard-effort stats (one entry per completed/abandoned hard segment).
    public private(set) var hardReps: [HardRepStat]
    /// Recovery segments where HR settled back down.
    public private(set) var recoveriesCompleted: Int

    /// Wall-clock seconds spent in the current segment.
    private var phaseElapsedSec: Int
    /// Remaining in-zone budget for the current hard effort.
    private var hardInZoneRemaining: Int
    /// In-zone seconds banked so far for the current hard effort.
    private var hardBankedSec: Int
    /// Stats accumulators for the current hard effort.
    private var hardPeakHR: Int
    private var hardSumHR: Int
    private var hardSampleCount: Int
    /// Peak HR of the most recently finished hard effort (for recovery's drop criterion).
    private var lastHardPeakHR: Int
    /// Whether the current recovery has reached the "recovered" state.
    private var recoveryRecovered: Bool
    /// Consecutive seconds without a usable heart-rate reading (bpm ≤ 0).
    private var noHRSeconds: Int

    // MARK: Adaptive guards (tunable)

    /// Don't end the warmup before this, even once HR is up.
    public let warmupMinSec: Int
    /// Hard-effort wall-clock safety cap (ends even if the zone isn't sustained).
    public let hardWallCapSec: Int
    /// Don't end a recovery before this, even if HR is already low.
    public let recoveryMinSec: Int
    /// Recovery also completes once HR falls this many bpm below the effort's peak.
    public let recoveryDropBpm: Int
    /// After this many seconds with no heart rate, fall back to wall-clock timing.
    public let noHRGraceSec: Int

    /// True when we've lost heart rate long enough to be timing by the wall clock.
    public var isBlind: Bool { noHRSeconds >= noHRGraceSec }

    public init(
        intervals: [WorkoutInterval],
        warmupMinSec: Int = 180,
        hardWallCapSec: Int = 8 * 60,
        recoveryMinSec: Int = 30,
        recoveryDropBpm: Int = 30,
        noHRGraceSec: Int = 15
    ) {
        self.intervals = intervals
        self.warmupMinSec = warmupMinSec
        self.hardWallCapSec = hardWallCapSec
        self.recoveryMinSec = recoveryMinSec
        self.recoveryDropBpm = recoveryDropBpm
        self.noHRGraceSec = noHRGraceSec
        self.currentIndex = 0
        self.secondsRemaining = 0
        self.coachingCue = nil
        self.isFinished = false
        self.hardReps = []
        self.recoveriesCompleted = 0
        self.phaseElapsedSec = 0
        self.hardInZoneRemaining = 0
        self.hardBankedSec = 0
        self.hardPeakHR = 0
        self.hardSumHR = 0
        self.hardSampleCount = 0
        self.lastHardPeakHR = 0
        self.recoveryRecovered = false
        self.noHRSeconds = 0
        configureForEntering(at: 0)
    }

    /// The segment the athlete is currently in, or nil when finished/empty.
    public var currentInterval: WorkoutInterval? {
        guard currentIndex < intervals.count else { return nil }
        return intervals[currentIndex]
    }

    /// End-of-session quality summary, valid at any time (grows as efforts complete).
    public var summary: FourByFourSummary {
        let plannedBudget = intervals.lazy.filter { $0.kind == .hard }.reduce(0) { $0 + $1.durationSec }
        let recoveryTargets = intervals.lazy.filter { $0.kind == .recovery }.count
        return FourByFourSummary(
            hardReps: hardReps,
            plannedHardBudgetSec: plannedBudget,
            recoveryTargets: recoveryTargets,
            recoveriesCompleted: recoveriesCompleted
        )
    }

    /// Advance one second with the latest heart rate (bpm). Returns the events that
    /// occurred (segment transitions, cue changes, completion) so the host can react.
    public mutating func tick(heartRate: Int) -> [Event] {
        guard let interval = currentInterval else { return [] }

        // Track heart-rate availability; crossing the blind threshold is announced once.
        let wasBlind = isBlind
        noHRSeconds = heartRate > 0 ? 0 : noHRSeconds + 1
        var events: [Event] = []
        if isBlind != wasBlind {
            events.append(isBlind ? .heartRateLost : .heartRateRestored)
        }

        phaseElapsedSec += 1

        // No usable HR → time every segment by the wall clock so the workout still runs.
        if isBlind {
            events += tickBlind(interval)
            return events
        }

        switch interval.kind {
        case .warmup: events += tickWarmup(interval, hr: heartRate)
        case .hard: events += tickHard(interval, hr: heartRate)
        case .recovery: events += tickRecovery(interval, hr: heartRate)
        case .cooldown: events += tickCooldown(interval)
        }
        return events
    }

    /// Wall-clock countdown used when heart rate is unavailable: no cue, advance at
    /// the prescribed duration regardless of (missing) HR.
    private mutating func tickBlind(_ interval: WorkoutInterval) -> [Event] {
        coachingCue = nil
        secondsRemaining = max(0, interval.durationSec - phaseElapsedSec)
        if phaseElapsedSec >= interval.durationSec {
            return advance()
        }
        return []
    }

    // MARK: - Per-phase logic

    /// Adaptive warmup: end once HR reaches the top of Zone 2, bounded by min/max.
    private mutating func tickWarmup(_ interval: WorkoutInterval, hr: Int) -> [Event] {
        let z2Upper = interval.targetHR?.upper ?? 0
        let warmedUp = hr > 0 && hr >= z2Upper
        secondsRemaining = max(0, interval.durationSec - phaseElapsedSec)
        if (phaseElapsedSec >= warmupMinSec && warmedUp) || phaseElapsedSec >= interval.durationSec {
            return advance()
        }
        return []
    }

    /// Adaptive hard: only spend the budget while HR is in the target band.
    private mutating func tickHard(_ interval: WorkoutInterval, hr: Int) -> [Event] {
        var events: [Event] = []
        let lower = interval.targetHR?.lower ?? Int.max
        let inZone = hr >= lower
        if inZone {
            events += setCue(nil)
            hardBankedSec += 1
            hardInZoneRemaining = max(0, hardInZoneRemaining - 1)
            hardPeakHR = max(hardPeakHR, hr)
            hardSumHR += hr
            hardSampleCount += 1
            if hardInZoneRemaining == 0 {
                return events + advance()
            }
        } else {
            // Below target — clock holds; nudge the athlete to work harder.
            events += setCue(.push)
        }
        secondsRemaining = hardInZoneRemaining
        // Safety: don't let an unreachable zone run forever.
        if phaseElapsedSec >= hardWallCapSec {
            events += advance()
        }
        return events
    }

    /// Adaptive recovery: advance once HR drops back into Zone 2 or falls well below
    /// the effort's peak, bounded by min/max.
    private mutating func tickRecovery(_ interval: WorkoutInterval, hr: Int) -> [Event] {
        var events: [Event] = []
        let z2Upper = interval.targetHR?.upper ?? 0
        let droppedFromPeak = lastHardPeakHR > 0 && hr <= lastHardPeakHR - recoveryDropBpm
        let recovered = hr > 0 && (hr <= z2Upper || droppedFromPeak)
        if recovered { recoveryRecovered = true }
        events += setCue(recovered ? nil : .easeOff)
        if (phaseElapsedSec >= recoveryMinSec && recovered) || phaseElapsedSec >= interval.durationSec {
            events += advance()
        } else {
            secondsRemaining = max(0, interval.durationSec - phaseElapsedSec)
        }
        return events
    }

    /// Plain wall-clock cooldown.
    private mutating func tickCooldown(_ interval: WorkoutInterval) -> [Event] {
        secondsRemaining = max(0, interval.durationSec - phaseElapsedSec)
        if phaseElapsedSec >= interval.durationSec {
            return advance()
        }
        return []
    }

    // MARK: - Transitions

    private mutating func advance() -> [Event] {
        recordLeavingSegment()
        let next = currentIndex + 1
        if next < intervals.count {
            configureForEntering(at: next)
            return [.enteredSegment(intervals[next].kind)]
        } else {
            currentIndex = intervals.count
            secondsRemaining = 0
            coachingCue = nil
            isFinished = true
            return [.finished]
        }
    }

    /// Captures stats for the segment we're about to leave.
    private mutating func recordLeavingSegment() {
        guard currentIndex < intervals.count else { return }
        switch intervals[currentIndex].kind {
        case .hard:
            let avg = hardSampleCount > 0 ? hardSumHR / hardSampleCount : 0
            hardReps.append(HardRepStat(
                bankedInZoneSec: hardBankedSec,
                budgetSec: intervals[currentIndex].durationSec,
                peakHR: hardPeakHR,
                avgHR: avg
            ))
            lastHardPeakHR = hardPeakHR
        case .recovery:
            if recoveryRecovered { recoveriesCompleted += 1 }
        case .warmup, .cooldown:
            break
        }
    }

    /// Resets per-segment adaptive + stats state when entering the segment at `index`.
    private mutating func configureForEntering(at index: Int) {
        currentIndex = index
        phaseElapsedSec = 0
        coachingCue = nil
        guard index < intervals.count else {
            secondsRemaining = 0
            return
        }
        let seg = intervals[index]
        switch seg.kind {
        case .hard:
            hardInZoneRemaining = seg.durationSec
            hardBankedSec = 0
            hardPeakHR = 0
            hardSumHR = 0
            hardSampleCount = 0
            secondsRemaining = seg.durationSec
        case .recovery:
            recoveryRecovered = false
            secondsRemaining = seg.durationSec
        case .warmup, .cooldown:
            secondsRemaining = seg.durationSec
        }
    }

    /// Updates the coaching cue, emitting a `.cue` event the moment one first appears
    /// (i.e. on a change to a non-nil value).
    private mutating func setCue(_ cue: CoachingCue?) -> [Event] {
        guard cue != coachingCue else { return [] }
        coachingCue = cue
        if let cue { return [.cue(cue)] }
        return []
    }
}
