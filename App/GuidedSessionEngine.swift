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

    private var timer: Timer?
    private let speech = AVSpeechSynthesizer()
    private var zone2ReminderClock = 0
    private static let zone2ReminderPeriodSec = 300

    init(type: SessionType, calc: HRZoneCalculator) {
        self.type = type
        self.intervals = type == .norwegian4x4 ? Norwegian4x4.build(using: calc) : []
        self.secondsRemaining = intervals.first?.durationSec ?? 0
    }

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
        configureAudioSession()
        if isStructured {
            currentIndex = 0
            isFinished = false
            secondsRemaining = intervals.first?.durationSec ?? 0
            hapticTrigger += 1
            if let kind = intervals.first?.kind { speak(GuidedCue.text(entering: kind)) }
        } else {
            elapsedSec = 0
            zone2ReminderClock = 0
            speak(GuidedCue.zone2Reminder)
        }
        let t = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        speech.stopSpeaking(at: .immediate)
        deactivateAudioSession()
    }

    private func tick() {
        if isStructured {
            guard currentIndex < intervals.count else { return }
            if secondsRemaining > 1 {
                secondsRemaining -= 1
            } else {
                advance()
            }
        } else {
            elapsedSec += 1
            zone2ReminderClock += 1
            if zone2ReminderClock >= Self.zone2ReminderPeriodSec {
                zone2ReminderClock = 0
                speak(GuidedCue.zone2Reminder)
            }
        }
    }

    private func advance() {
        let next = currentIndex + 1
        if next < intervals.count {
            currentIndex = next
            secondsRemaining = intervals[next].durationSec
            hapticTrigger += 1
            speak(GuidedCue.text(entering: intervals[next].kind))
        } else {
            currentIndex = intervals.count
            secondsRemaining = 0
            isFinished = true
            hapticTrigger += 1
            speak(GuidedCue.finished)
            timer?.invalidate()
            timer = nil
        }
    }

    private func speak(_ text: String) {
        lastCue = text
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        speech.speak(utterance)
    }

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, options: [.duckOthers])
        try? session.setActive(true)
    }

    private func deactivateAudioSession() {
        try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
    }
}
