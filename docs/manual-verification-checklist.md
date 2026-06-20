# Manual hardware verification checklist

The 3 remaining Spectra tasks are hardware-gated — they can't be verified in a simulator or by
an agent. Automated de-risking is done (see "Agent de-risk results" below); these are the
physical runs only you can perform on your iPhone + Apple Watch. Fill in RESULT/NOTES, then we
check the boxes and archive.

---

## ⚠️ Read first — guided player does NOT auto-log

Source review found that `GuidedPlayerView` is a coaching timer only: its **End** button calls
`engine.stop()` + `dismiss()` and never writes a `WorkoutLog`. The Today/Week/History screens
read from the `WorkoutLog` SwiftData store, which is written from three places only:
Manual Entry, the watch sync receiver (`PhoneSessionReceiver`), and Apple Health import.

**Implication for task 4.1:** after finishing a guided Zone 2 / 4×4 on the *phone*, the session
will **not** appear in stats by itself — you must log it (Manual Entry) or have it come from the
watch / Apple Health. Confirm whether that's the intended UX before signing off 4.1. If you
expected "finish guided → auto-appears in History," that's a product gap to file as a new change,
not a verification failure of the sync work.

(On the *watch* side, task 5.x is unaffected — the watch's `HKWorkoutSession` does save and sync.)

---

## app-store-submission — Task 4.1 — "Internal TestFlight run"

Source: `openspec/changes/app-store-submission/tasks.md:28`
Spec scenario: **Internal TestFlight run**

Steps:
1. Confirm the build is in TestFlight (App Store Connect → TestFlight → internal testing). App id 6776864990, team `2NXQLV6CJH`.
2. Install via the TestFlight app on a real iPhone.
3. Complete one **Zone 2** session and one **Norwegian 4×4** session end-to-end. (Remember: log each via Manual Entry / Health / watch so it lands in stats — see caveat above.)
4. Confirm each session is **recorded** and that **Today / Week / History** update accordingly.
5. Confirm **no crash** throughout.

Pass criteria: two sessions recorded, all three stats screens updated, zero crashes.

- RESULT: <pending>
- NOTES:

---

## watch-phone-sync — Task 5.1 — physical Apple Watch run

Source: `openspec/changes/watch-phone-sync/tasks.md:29`

Steps:
1. On a physical Apple Watch, start a **Norwegian 4×4** in the watch app.
2. Verify **live heart rate** displays and updates.
3. Verify **zone colors** render correctly for the current HR zone.
4. Verify a **haptic** fires at each interval transition (hard↔recovery boundaries).

Pass criteria: HR live, zone colors correct, haptic on every transition.

- RESULT: <pending>
- NOTES:

---

## watch-phone-sync — Task 5.2 — watch→iPhone sync, no duplication

Source: `openspec/changes/watch-phone-sync/tasks.md:31`

Steps:
1. Finish the watch 4×4 from 5.1 (let `WorkoutSessionManager.finishAndSave()` complete).
2. On the iPhone, open the app and check **Today / Week / History**.
3. Confirm the watch-completed session **appears** in the phone-side stats.
4. Confirm there is exactly **one** record for it — no duplication (dedup is by `healthUUID`;
    the automated `PhoneSessionReceiverTests` already prove the dedup logic, this confirms it on real hardware).

Pass criteria: single record across both devices, present in iPhone stats.

- RESULT: <pending>
- NOTES:

---

## Agent de-risk results (2026-06-20) — automated, all green

- **SharedCore** `swift test`: **79 tests passed** (17 suites).
- **iOS app** build+test on iPhone 17 sim: `** BUILD SUCCEEDED ** / ** TEST SUCCEEDED **`,
  **11 tests** (HealthWritebackTests, PhoneSessionReceiverTests, WorkoutSourceTests).
- **Watch app** build on Apple Watch Series 11 (watchOS 26.5) sim: `** BUILD SUCCEEDED **`
  (also built the embedded complications appex). watchOS 26.5 SDK confirmed installed.
- **Sync/dedup tests** (proxy for 5.2's no-dup requirement) pass: `insertsOnce`, `dedupes`
  (same session twice → count stays 1), `distinctInsert` — in `Tests/PhoneSessionReceiverTests.swift`.
- **iOS smoke** (proxy for 4.1, simulator-only, NOT a substitute): app launched clean with
  `-mockHealth` (PID stable, no crash log), Today screen rendered with mock data. Surfaced the
  guided-player no-auto-log finding above.
- Benign noise during tests: `WCErrorDomain Code=7005 "Device is not paired"` — expected on an
  unpaired simulator; all tests still passed.
