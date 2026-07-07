import Foundation
import Testing
@testable import Z24x4Trainer

/// The launch-cohort rule: first launches before the cutoff are Pro forever.
struct ProGrandfatherTests {
    private let cutoff = ISO8601DateFormatter().date(from: "2026-08-01T00:00:00Z")!

    @Test("first launch before the cutoff unlocks Pro")
    func earlyAdopter() {
        let early = cutoff.addingTimeInterval(-1)
        #expect(ProStore.isGrandfathered(firstLaunch: early, cutoff: cutoff))
    }

    @Test("first launch at or after the cutoff does not unlock")
    func lateComer() {
        #expect(!ProStore.isGrandfathered(firstLaunch: cutoff, cutoff: cutoff))
        #expect(!ProStore.isGrandfathered(firstLaunch: cutoff.addingTimeInterval(86_400), cutoff: cutoff))
    }

    @Test("missing first-launch stamp never unlocks")
    func missingStamp() {
        #expect(!ProStore.isGrandfathered(firstLaunch: nil, cutoff: cutoff))
    }
}
