## Why

The watchOS app (Phase 4) records workouts on the wrist but the data never reaches the
iPhone, and the watch target has not been compiled or run because the watchOS SDK was not
installed locally. Until completed sessions flow back to the phone and the target actually
builds, the Watch app cannot contribute to the user's daily/weekly progress or be shipped.

## What Changes

- Add **WatchConnectivity** sync so a workout finished on the Watch is delivered to the
  iPhone and saved as a `WorkoutLog` (deduped by `healthUUID`), feeding Today/Week/History.
- Replace the existing `// TODO: WatchConnectivity sync to phone` marker in
  `Watch/WorkoutSessionManager.swift` with a real `WCSession` transfer.
- Add a phone-side `WCSession` receiver that inserts incoming sessions into SwiftData.
- Compile and run the `Z24x4TrainerWatch` target once the watchOS SDK is installed; verify
  live HR, zone display, and 4×4 interval haptics on a physical Apple Watch.

## Non-Goals

- Real-time live mirroring of an in-progress workout to the phone (only completed sessions sync).
- iCloud/CloudKit cross-device sync (the app stays local-only).
- Bidirectional plan editing from the Watch.

## Capabilities

### New Capabilities

- `watch-phone-sync`: deliver completed Watch workouts to the iPhone over WatchConnectivity and
  persist them on the phone without duplicates.

### Modified Capabilities

<!-- none: no existing spec changes its requirements -->

## Impact

- Code: `Watch/WorkoutSessionManager.swift` (send), new phone-side `App/Sync/PhoneSessionReceiver.swift`
  (receive), `App/Z24x4TrainerApp.swift` (activate `WCSession`), `App/Persistence/WorkoutLog.swift`
  (reuse `healthUUID` dedupe).
- Build: requires `xcodebuild -downloadPlatform watchOS` before the watch target can compile.
- Hardware: live HR + haptics verifiable only on a physical Apple Watch paired to an iPhone.
