import Foundation
import Observation
import AVFoundation
import SharedCore

/// Drives an on-iPhone guided workout: a per-second timer that, for a Norwegian
/// 4×4, advances through the prebuilt intervals (mirroring `Watch/IntervalEngine`)
/// and, for Zone 2, counts elapsed time. Fires a haptic trigger and speaks a cue
/// on each transition, ducking other audio while it plays.
@Observable
@MainActor
final class GuidedSessionEngine {
    let type: SessionType
    /// Prescribed intervals for a 4×4; empty for an open-ended Zone 2 session.
    let intervals: [WorkoutInterval]

    private(set) var currentIndex = 0
    private(set) var secondsRemaining = 0
    private(set) var elapsedSec = 0
    private(set) var isFinished = false
    /// Increments on every transition; views observe it for `.sensoryFeedback`.
    private(set) var hapticTrigger = 0
    /// Most recent spoken cue (also useful for accessibility / display).
    private(set) var lastCue = ""
    /// True when the audio session couldn't be configured — voice cues won't be
    /// heard, but the timer keeps running. Views surface this as a banner.
    private(set) var audioUnavailable = false

    private var timer: Timer?
    /// Wall-clock anchor: the timer only *triggers* a check; the number of ticks
    /// applied is however many whole seconds actually elapsed, so time spent with
    /// the screen locked or the app briefly suspended is caught up, not lost.
    private var clock = TickClock()
    private let speech = SpeechCoordinator()
    private var zone2ReminderClock = 0
    private static let zone2ReminderPeriodSec = 300

    /// Shared SharedCore state machine that drives the 4×4 structure — the same one
    /// the watch uses. With no live HR it times by the wall clock (`noHRGraceSec: 0`);
    /// feed `updateHeartRate` and it becomes adaptive for free.
    private var runner: IntervalRunner?
    /// Latest heart rate, when a source (e.g. a paired watch) provides one. 0 = none.
    private var latestHR = 0

    init(type: SessionType, calc: HRZoneCalculator, repeats: Int = Norwegian4x4.repeats) {
        self.type = type
        self.intervals = type == .norwegian4x4 ? Norwegian4x4.build(using: calc, repeats: repeats) : []
        if type == .norwegian4x4 {
            self.runner = IntervalRunner(intervals: intervals, noHRGraceSec: 0)
        }
        self.secondsRemaining = intervals.first?.durationSec ?? 0
    }

    /// Feed a live heart rate so the structured session can time adaptively.
    func updateHeartRate(_ bpm: Int) { latestHR = bpm }

    var isStructured: Bool { type == .norwegian4x4 }

    var currentInterval: WorkoutInterval? {
        guard isStructured, currentIndex < intervals.count else { return nil }
        return intervals[currentIndex]
    }

    var nextInterval: WorkoutInterval? {
        guard isStructured, currentIndex + 1 < intervals.count else { return nil }
        return intervals[currentIndex + 1]
    }

    /// "2:13" — remaining time for 4×4, elapsed time for Zone 2.
    var clockText: String {
        let s = isStructured ? secondsRemaining : elapsedSec
        return String(format: "%d:%02d", s / 60, s % 60)
    }

    /// "2 / 10" segment progress for 4×4; empty for Zone 2.
    var progressText: String {
        guard isStructured, !intervals.isEmpty else { return "" }
        return "\(min(currentIndex + 1, intervals.count)) / \(intervals.count)"
    }

    func start() {
        guard timer == nil else { return }
        audioUnavailable = !speech.configure()
        if isStructured {
            runner = IntervalRunner(intervals: intervals, noHRGraceSec: 0)
            currentIndex = 0
            isFinished = false
            secondsRemaining = runner?.secondsRemaining ?? intervals.first?.durationSec ?? 0
            hapticTrigger += 1
            if let kind = intervals.first?.kind { speak(GuidedCue.text(entering: kind)) }
        } else {
            elapsedSec = 0
            zone2ReminderClock = 0
            speak(GuidedCue.zone2Reminder)
        }
        clock.start()
        let t = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        clock.pause()
        speech.stop()
    }

    /// True while paused mid-session (timer stopped, state preserved).
    private(set) var isPaused = false

    func pause() {
        guard timer != nil, !isFinished else { return }
        isPaused = true
        timer?.invalidate()
        timer = nil
        clock.pause()
        speech.stop()
    }

    func resume() {
        guard isPaused, !isFinished else { return }
        isPaused = false
        clock.start()
        let t = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    private func tick() {
        let due = clock.consumeDue()
        guard due > 0 else { return }
        if isStructured {
            guard runner != nil else { return }
            // Replay every due second, but voice/haptics only reflect where we
            // *ended up* — after a catch-up burst, speaking every intermediate
            // transition would queue stale cues.
            var lastEntered: IntervalKind?
            var finished = false
            for _ in 0..<due {
                for event in runner!.tick(heartRate: latestHR) {
                    switch event {
                    case .enteredSegment(let kind):
                        lastEntered = kind
                    case .finished:
                        finished = true
                    case .cue, .heartRateLost, .heartRateRestored:
                        break // no live HR on the phone today; ignore HR-driven nudges
                    }
                }
                if runner!.isFinished { break }
            }
            secondsRemaining = runner!.secondsRemaining
            currentIndex = runner!.currentIndex
            if finished {
                isFinished = true
                hapticTrigger += 1
                speak(GuidedCue.finished)
                timer?.invalidate()
                timer = nil
                clock.pause()
            } else if let kind = lastEntered {
                hapticTrigger += 1
                speak(GuidedCue.text(entering: kind))
            }
        } else {
            elapsedSec += due
            zone2ReminderClock += due
            if zone2ReminderClock >= Self.zone2ReminderPeriodSec {
                zone2ReminderClock = 0
                speak(GuidedCue.zone2Reminder)
            }
        }
    }

    private func speak(_ text: String) {
        lastCue = text
        speech.speak(text)
    }
}

/// Owns the speech synthesizer and scopes the audio session — and therefore the
/// ducking of the user's music — to just the moments a cue is actually spoken.
/// Previously the session stayed active (ducked) for the entire 40-minute workout.
@MainActor
private final class SpeechCoordinator: NSObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    /// Sets the playback category (no activation yet). Returns false when audio
    /// can't be configured — the caller surfaces a "voice cues unavailable" banner.
    func configure() -> Bool {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.duckOthers])
            return true
        } catch {
            return false
        }
    }

    func speak(_ text: String) {
        // Activate just-in-time; deactivated again once the queue drains.
        try? AVAudioSession.sharedInstance().setActive(true)
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        deactivate()
    }

    private func deactivate() {
        try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
    }

    /// Releases the session (undoing the duck) when the last queued cue ends.
    private func deactivateIfIdle() {
        guard !synthesizer.isSpeaking else { return }
        deactivate()
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                                       didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in self.deactivateIfIdle() }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                                       didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in self.deactivateIfIdle() }
    }
}
