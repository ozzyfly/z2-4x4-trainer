import Foundation

/// Accrues "time in Zone 2" for an open-ended Zone 2 session. Each second is
/// credited only while heart rate is *within* the Zone 2 band, so easing down into
/// Zone 1 or pushing up into Zone 3+ pauses the credited time rather than padding
/// the session with junk minutes.
///
/// If the heart-rate reading disappears for `noHRGraceSec` (sensor failure, loose
/// band), the tracker goes *blind* and falls back to crediting wall-clock seconds —
/// a 40-minute session must not be voided by a dead sensor. Blind seconds count
/// toward `inZoneSeconds` but never contribute HR samples to the average.
public struct Zone2TimeTracker: Sendable, Equatable {
    /// Seconds banked while in the Zone 2 band (or blind — see above).
    public private(set) var inZoneSeconds: Int
    /// Total seconds ticked (whole session length), in or out of zone.
    public private(set) var totalSeconds: Int
    /// Whether the most recent tick counted (HR inside the band, or blind fallback).
    public private(set) var isCounting: Bool
    /// Zone 2 lower bound, in bpm.
    public let lowerBound: Int
    /// Zone 2 upper bound, in bpm.
    public let upperBound: Int

    /// After this many consecutive seconds without a usable heart rate, fall back
    /// to wall-clock crediting (matches `IntervalRunner.noHRGraceSec`).
    public let noHRGraceSec: Int
    /// Consecutive seconds without a usable heart-rate reading (bpm ≤ 0).
    public private(set) var noHRSeconds: Int
    /// True when HR has been unavailable long enough that time is credited by the
    /// wall clock. Hosts should surface this ("No HR — timed") in the UI.
    public var isBlind: Bool { noHRSeconds >= noHRGraceSec }

    private var sumInZoneHR: Int
    private var inZoneHRSamples: Int

    public init(lowerBound: Int, upperBound: Int, noHRGraceSec: Int = 15) {
        self.lowerBound = lowerBound
        self.upperBound = upperBound
        self.noHRGraceSec = noHRGraceSec
        self.noHRSeconds = 0
        self.inZoneSeconds = 0
        self.totalSeconds = 0
        self.isCounting = false
        self.sumInZoneHR = 0
        self.inZoneHRSamples = 0
    }

    /// Average heart rate over the in-zone seconds (0 if none).
    public var avgInZoneHR: Int { inZoneHRSamples > 0 ? sumInZoneHR / inZoneHRSamples : 0 }

    /// Percentage of the session actually spent in Zone 2 (0…100).
    public var inZonePercent: Int {
        totalSeconds > 0 ? Int((Double(inZoneSeconds) / Double(totalSeconds) * 100).rounded()) : 0
    }

    /// Advance one second with the latest heart rate; credits the second when HR is
    /// within the Zone 2 band (`lowerBound ... upperBound`), or unconditionally once
    /// blind (no usable HR for `noHRGraceSec`).
    public mutating func tick(heartRate: Int) {
        totalSeconds += 1
        noHRSeconds = heartRate > 0 ? 0 : noHRSeconds + 1
        let inBand = heartRate >= lowerBound && heartRate <= upperBound
        isCounting = inBand || isBlind
        if isCounting {
            inZoneSeconds += 1
            if inBand && heartRate > 0 {
                sumInZoneHR += heartRate
                inZoneHRSamples += 1
            }
        }
    }
}
