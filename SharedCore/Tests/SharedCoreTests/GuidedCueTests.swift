import Foundation
import Testing
@testable import SharedCore

@Suite("Guided cue")
struct GuidedCueTests {
    @Test("every interval kind has a non-empty cue", arguments: [
        IntervalKind.warmup, .hard, .recovery, .cooldown
    ])
    func enteringCue(_ kind: IntervalKind) {
        #expect(!GuidedCue.text(entering: kind).isEmpty)
    }

    @Test("finished and zone-2 reminder are non-empty")
    func staticCues() {
        #expect(!GuidedCue.finished.isEmpty)
        #expect(!GuidedCue.zone2Reminder.isEmpty)
    }
}
