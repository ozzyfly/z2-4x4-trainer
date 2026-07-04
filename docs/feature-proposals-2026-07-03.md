# Feature Proposals — 2026-07-03 review

Product-feature candidates from the July 2026 code/product review, in priority
order. Each follows the `openspec/changes/*/proposal.md` shape so it can be
promoted to a real Spectra change via `/spectra-propose` when picked up.

---

## 1. `live-activity` — Lock-screen Live Activity for guided sessions

### Why

A phone-guided session today is only visible with the app open. Locking the
phone (pocket, treadmill shelf) hides the countdown, current interval, and cues —
exactly when the athlete needs a glanceable readout. Live Activities put the
session on the Lock Screen and Dynamic Island with system-managed updates.

### What Changes

- New `Z24x4LiveActivity` widget-extension target (ActivityKit), or fold into
  `Z24x4Widgets` (`NSSupportsLiveActivities` in the app Info.plist).
- `ActivityAttributes` carrying: session type, current interval kind, seconds
  remaining, hard-rep index/total, zone band; updated from `GuidedSessionEngine`
  on each segment transition (not every second — ActivityKit budgets updates;
  use `Text(timerInterval:)` for the countdown so the system animates it).
- Start the activity in `GuidedPlayerView` on start; end on finish/cancel.

### Non-Goals

- Push-updated activities (no server — everything local).
- Watch-driven Live Activities (the watch has its own live UI).

### Impact

- `project.yml` (Info.plist key, possibly new target), `App/GuidedSessionEngine.swift`,
  `App/Views/GuidedPlayerView.swift`, Widgets extension. l10n: new catalog keys ×4 languages.

---

## 2. `workout-hr-series` — store and chart the per-workout HR curve

### Why

WorkoutLog keeps only aggregates (avg/peak). The most motivating artifact of a
4×4 — the four-summit HR curve — is discarded. Detail views feel thin vs.
Apple Fitness.

### What Changes

- SharedCore: `HRSeriesSample` (offsetSec, bpm) + downsampling (e.g. 10-second
  buckets; a 43-min session ≈ 260 points).
- Watch: sample `currentHR` into the series during the session; include the
  (compressed) series in `WorkoutTransfer` (WatchConnectivity messages are fine
  at this size; guard with a max-count cap).
- iOS: persist on `WorkoutLog` (external-storage blob or relation), render a
  Swift Charts line with zone bands in `WorkoutLogDetailView`; ShareCard can
  reuse it later.

### Non-Goals

- Backfilling series for Health-imported/manual workouts (query-able from
  HealthKit later; out of scope).

### Impact

- SharedCore (+tests), `Watch/WorkoutSessionManager`, `WorkoutTransfer`,
  `App/Persistence/WorkoutLog` (SwiftData migration!), `WorkoutLogDetailView`.

---

## 3. `outdoor-gps-route` — optional GPS route for outdoor sessions

### Why

Sessions record `locationType: .unknown` and no route. For outdoor runners the
workout looks incomplete in Apple Fitness/Health next to any other running app,
and distance/pace are missing from our own logs.

### What Changes

- Watch: session start sheet gains Indoor/Outdoor; outdoor configures
  `.outdoor` location, adds `HKWorkoutRouteBuilder` + `CLLocationManager`
  (`whenInUse`, watch-side prompt), streams locations into the route, and saves
  distance stats.
- iOS detail view: distance + small route map (MapKit) when present.
- New usage strings (`NSLocationWhenInUseUsageDescription`) both targets; App
  Privacy label gains Location (not linked, not tracking) — update
  `docs/app-store/APP_PRIVACY_LABEL.md`.

### Non-Goals

- Pace/split coaching; GPS on the phone-guided path.

### Impact

- `project.yml` entitlements/plist, `Watch/WorkoutSessionManager`, watch UI,
  `App/Views/WorkoutLogDetailView`, privacy docs. Battery: routes only when outdoor.

---

## 4. `morning-readiness-notification` — daily readiness push

### Why

Readiness (HRV/RHR) is computed but only visible when the user opens the app.
Its value is *before* the session decision: "readiness 85 — today's 4×4 is on"
each morning drives the habit loop and surfaces the smart-coach work.

### What Changes

- Extend `ReminderScheduler`: a BGAppRefresh task (or notification-time
  recompute via the widget snapshot) that schedules a local notification at a
  user-chosen morning hour with readiness + today's prescription.
- Settings: opt-in toggle + time picker alongside existing reminders.
- Deep-link the notification to Today.

### Non-Goals

- Server pushes; re-computing HealthKit queries from a notification service
  extension (use the last snapshot).

### Impact

- `App/Notifications/ReminderScheduler`, Settings view, snapshot plumbing.
  BGTaskScheduler identifier in `project.yml`. l10n ×4.

---

## 5. `maxhr-field-test` — guided max-HR estimation session

### Why

Zones default to 220−age, which misses real max HR by ±10–15 bpm for many
users — enough to put "Zone 2" in Zone 3. The manual override exists but users
don't know their max. A guided ramp test (structured warmup → 3×2-min ramps →
all-out minute) measured on the watch closes the loop with real data.

### What Changes

- SharedCore: `MaxHRFieldTest` session structure + result extraction
  (peak HR from the test, gated by a plausibility filter — reuse
  `filteredObservedMax` logic) + tests.
- Watch: run it like a 4×4 via `IntervalEngine` with a dedicated interval list.
- iOS: entry point in Settings → Zones ("Test your max HR"), result screen
  offering to apply the measured max as the override.
- Safety copy: not for beginners; medical disclaimer mirrors METADATA legal note.

### Non-Goals

- VO2max estimation from the test; lab-grade accuracy claims.

### Impact

- SharedCore (+tests), watch session kinds, Settings/Zones UI, l10n ×4.

---

### Sequencing note

1–2 are the highest leverage per effort (pure client, no new permissions).
3 adds a permission + privacy-label change → bundle with a store-metadata
update. 4 is small but depends on snapshot freshness. 5 is the most
domain-sensitive — spec the safety language first.
