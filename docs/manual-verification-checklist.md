# Manual hardware verification checklist

The 3 remaining Spectra tasks are hardware-gated — they can't be verified in a simulator or by
an agent. Automated de-risking is done (see "Agent de-risk results" below); these are the
physical runs only you can perform on your iPhone + Apple Watch. Fill in RESULT/NOTES, then we
check the boxes and archive.

---

## ~~⚠️ Read first — guided player does NOT auto-log~~ RESOLVED 2026-06-21

`guided-player-autolog` closed this gap: a completed phone-guided session now writes a
`WorkoutLog` via `GuidedSessionLogger` (4×4 on `isFinished`; Zone 2 once elapsed reaches the
prescribed minutes). For 4.1, a finished guided session **should** appear in Today/Week/History
by itself — if it doesn't, that's now a verification FAILURE, not expected behavior.

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

- RESULT: **PARTIAL (photo evidence 2026-07-05) — guided-autolog + no-crash word pending**
- NOTES: One Zone 2 + one 4×4 completed end-to-end on Jul 5 and recorded (History rows with
  correct durations/kcal); History + detail screens render correctly. Still needed from the
  user: confirm build number was 58, the sessions counted on Today/Week too, a *phone-guided*
  session auto-logs (autolog path — the Jul 5 runs were watch-driven), screen stays awake +
  music ducks only during cues in the guided player, and no crashes seen.

---

## watch-phone-sync — Task 5.1 — physical Apple Watch run

Source: `openspec/changes/watch-phone-sync/tasks.md:29`

Steps:
1. On a physical Apple Watch, start a **Norwegian 4×4** in the watch app.
2. Verify **live heart rate** displays and updates.
3. Verify **zone colors** render correctly for the current HR zone.
4. Verify a **haptic** fires at each interval transition (hard↔recovery boundaries).

Pass criteria: HR live, zone colors correct, haptic on every transition.

- RESULT: **PASS (photo-verified 2026-07-05, haptics pending user word)**
- NOTES: Real 4×4 on Watch Ultra, Jul 5 20:24 — live HR streamed (photo: 120 BPM mid-Zone 2
  session; earlier "no BPM" was a permissions issue, resolved on-device). Zone colors correct
  (green Zone 2 pill + "In zone · Hold 108–126 bpm"). Completion overlay: Quality 100, 4/4 full
  reps, avg hard 159 · peak 164 (91% max). Haptic-per-transition not confirmable from photos —
  user to confirm verbally. Wrist-down 30s catch-up (2026-07-03 extra) also pending user word.

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

- RESULT: **PASS (photo-verified 2026-07-05)**
- NOTES: History (21:54 screenshot): the real 4×4 (Jul 5 20:24, 34 min) and Zone 2 (20:58,
  35 min) each appear **exactly once**, Source = Apple Watch, kcal non-nil (108 / 243 —
  share-auth fix confirmed). Zone 2 math consistent across devices (watch 34:53/40:06 = 87%
  ↔ phone 35/40 min · 87% · avg 121). **Finding from the same screenshot:** two 1-minute
  "Imported from Apple Health" rows (11:37, 13:34) — watch mis-tap tests the watch refused to
  sync, resurrected by the Health auto-import. Not a dedup failure (distinct workouts), but
  junk. Fixed same day: own-stamped imports now require ≥5 min (`minimumOwnImportMinutes`,
  new unit test). The existing 1-min rows can be swipe-deleted; tombstones stop re-import.

---

## ⚠️ 2026-07-03 changes — extra checks to fold into 4.1 / 5.1 / 5.2

The July robustness pass rewrote the timing core and the watch auth. While you're on hardware
anyway, verify these in the same runs (they're exactly the behaviors a simulator can't prove):

**During 5.1 (watch 4×4):**
- [ ] **Wrist-down timing (TickClock)** — during a hard segment, drop your wrist for ~30s, then
      look again. The countdown must have advanced by the elapsed wall time (catch-up ticks),
      not frozen where you left it. This was the #1 real-device risk of the old tick-per-timer code.
- [ ] **Energy samples (share-auth fix)** — the permission sheet should now also request
      *write* access for Active Energy + Heart Rate. After the session, the synced log on the
      phone should show a non-nil kcal value, and the workout in Apple Health should contain
      energy. (First run after updating: expect a new permission prompt.)
- [ ] **HR-loss fallback** — optional: loosen the strap for ~20s mid-Zone 2. The live view
      should flip to "No HR — timed" and keep crediting time (blind fallback) instead of
      freezing at the banked seconds; also verify stale-HR handling means it doesn't keep
      counting your last reading as in-zone forever.

**During 5.2 (sync):**
- [ ] Live HR on a phone-side guided screen updates at most every ~5s now (throttle) — slower
      cadence is intended, dead stream is not.
- [ ] After the watch workout syncs in, check a Readiness widget/complication: the score must
      **survive** the sync (readiness carry-forward fix) rather than going blank.

**During 4.1 (TestFlight):**
- [ ] Guided session: screen must **not** auto-lock mid-session (idle timer fix), and if music
      is playing, it should duck only while a cue is spoken and recover right after — not stay
      quiet for the whole session (SpeechCoordinator).
- [ ] Finished guided session auto-appears in Today/Week/History (autolog — see resolved note).
- [ ] UI pass: SF (non-rounded) numerals, slimmer target bar, brand-orange widgets/watch rows
      render acceptably in light + dark (Hermès refinement round — pure visual judgment call).

- RESULT: **PARTIAL (photo-verified 2026-07-05 where possible)**
- NOTES: Confirmed by photos — energy samples save (4×4 108 kcal / Zone 2 243 kcal on the
  synced logs; new share-auth prompt path works); live view UI renders correctly on device
  (WatchTheme orange Done buttons, serif overlay titles, zone pill). Exposed by photos and
  fixed same evening — overlay/stat truncations, "Keep going" wrap, Zone 2 time buried at the
  bottom (now a top banner). Still pending user word: wrist-down 30s catch-up, "No HR — timed"
  fallback, ~5s live-HR cadence on the phone, readiness widget surviving a sync, guided-player
  screen-awake + duck-only-during-cue.

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
