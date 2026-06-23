# PROGRESS — Z2/4×4 Trainer

> **2026-06-22: `localize-per-week-unit-labels` done [4/4] — per-week unit labels now localized.**
> Audit-found l10n gap: weight-loss rate "kg/week"/"lb/week" (Settings + Onboarding) and Week
> screen "%lld/week" (hard sessions) + "%lld kcal/week" (energy) were hardcoded English via
> `String(format:)`/interpolation, so es/ja/zh-Hant users saw untranslated units. Routed all four
> through `String(localized:)` with locale-aware number formatting
> (`.formatted(.number.precision(.fractionLength(2)))`); added 4 catalog keys ("%@ kg/week",
> "%@ lb/week", "%lld/week", "%lld kcal/week") with es/ja/zh-Hant (period → /semana, /週; unit
> abbreviations kept latin). App catalog now 188 keys. Verified: iOS build+test **24 tests**
> `BUILD/TEST SUCCEEDED`; all 4 keys state=translated in 3 langs; es-locale sim launch renders
> Spanish. (#Preview Demo's "kg/week" left as-is — not user-facing.) On-tab render of the exact
> Week/Settings strings follows the same proven catalog path.

> **2026-06-22: `widget-refresh-on-health-import` done [3/3] — Health import now refreshes widgets.**
> Audit-found bug: `HealthStore.importWorkouts` inserted `WorkoutLog`s but skipped the widget
> snapshot refresh every other mutation path does (manual/watch/guided), so imported Apple Health
> workouts showed stale weekly totals on Home/Lock widgets + watch complication until another
> action fired. Fix: `importWorkouts` now returns the inserted count and calls
> `WidgetSnapshotWriter.update` only when >0 (no needless rewrite on all-duplicate imports). New
> `Tests/HealthImportSnapshotTests.swift` ×3 (new→1, duplicate→0, empty→0) using a local spy
> provider. Verified: SharedCore 79; iOS build+test **24 tests** `BUILD/TEST SUCCEEDED` on iPhone 17
> sim; existing `HealthWritebackTests` dedup case still green. Delta requirement applied to
> `widgets-complication`. Scoped out: imported workouts typed `.zone2` (HKWorkout can't distinguish
> a 4×4 — defensible default, not a bug).

> **2026-06-21: `guided-player-autolog` done [5/5] — guided sessions now record a WorkoutLog.**
> Closed the gap found during de-risk: `GuidedPlayerView` End only stopped + dismissed, so
> phone-guided sessions never hit Today/Week/History. New `App/GuidedSessionLogger.swift` (mirrors
> `PhoneSessionReceiver`) decides + inserts: 4×4 logs its full 43 min when `engine.isFinished`;
> Zone 2 (open-ended) logs actual elapsed only once it reaches the prescribed minutes, else nothing
> (cancel). Logs tagged new `WorkoutSource.guided` (History icon `play.circle.fill`, label "From a
> guided session" + es/ja/zh-Hant); export/History pass the rawValue through. View logs on
> completion (4×4) and on disappear (catches End + swipe-back), `didLog`-guarded against
> double-insert. `prescribedMinutes` threaded through GuidedPlayerView + WorkoutDetailView and all
> call sites (TodayView, WeekView). Verified: SharedCore **79 tests**; iOS build+test **21 tests**
> (new `GuidedPlayerLoggingTests` ×10 + guided round-trip) `BUILD/TEST SUCCEEDED` on iPhone 17 sim;
> `-mockHealth` launch renders Today, no crash. **Sim-only note:** the 40-min wall-clock completion
> path isn't driven in-sim (impractical) — covered by the unit tests + real-device task 4.1.

> **2026-06-20: agent de-risk pass for the 2 open changes — automated green, 3 hardware tasks pending user.**
> `watch-phone-sync` and `app-store-submission` have only physical-device verification left
> (`watch-phone-sync` 5.1/5.2 need an Apple Watch; `app-store-submission` 4.1 needs a TestFlight
> build on a real iPhone). Agents ran everything automatable: SharedCore **79 tests** green; iOS
> build+test on iPhone 17 sim `BUILD/TEST SUCCEEDED` (**11 tests** incl. PhoneSessionReceiver
> dedup); watch app `BUILD SUCCEEDED` on Apple Watch Series 11 / watchOS 26.5 sim; `-mockHealth`
> sim smoke launched clean (Today renders, no crash). **Finding:** `GuidedPlayerView` End does not
> write a `WorkoutLog` (coaching timer only) — phone-guided sessions must be logged via Manual
> Entry / Health / watch to hit stats; confirm this is intended UX when running 4.1. Manual steps
> for 4.1/5.1/5.2 captured in `docs/manual-verification-checklist.md` (fill RESULT, then archive).
> RESULT 4.1: <pending> · 5.1: <pending> · 5.2: <pending>.

> **2026-06-15: `widget-complication-l10n` done [7/7] — extension strings localized.**
> Widgets + WatchComplications shipped English-only (separate bundles, untouched by the App
> catalog). Added `Widgets/Localizable.xcstrings` (26 keys) + `WatchComplications/Localizable.xcstrings`
> (19 keys), zh-Hant/es/ja, terms reused verbatim from the App catalog. Fixed the `Text(String)` /
> `widgetLabel(String)` verbatim-render trap: `widgetTitle`/`title` helpers now return
> `String(localized:)`, and `.map { "Readiness \($0)" }` / streak-label closures wrapped in
> `String(localized:)`. es plural for "%lld-week streak" in both. Folder-level `sources:` globs the
> new catalogs in automatically — no project.yml change. Verified: iOS + watch builds green; both
> appex bundles compile 4 lproj; es/ja strings + es plural stringsdict resolve in the built bundles
> (all 4 catalogs 0 needs_review). On-springboard widget/complication gallery screenshots are the
> one remaining manual check (can't add widgets to the sim home screen headlessly).

> **2026-06-13: build 3 prepped for App Store — version bump + extension-version fix.**
> `CURRENT_PROJECT_VERSION` 2→3 on all targets (app, watch, Widgets, Complications).
> **Caught a ship blocker:** Widgets/Complications Info.plist hardcoded CFBundleVersion=1 /
> CFBundleShortVersionString=1.0 — would fail App Store validation (bundled extensions must match
> the app's 3/1.0.0). Build 2 predated these extensions so it was never hit. Fixed by routing both
> keys through `$(MARKETING_VERSION)`/`$(CURRENT_PROJECT_VERSION)` in the xcodegen `info.properties`
> block (direct Info.plist edits get overwritten by xcodegen — must live in project.yml). Verified:
> Release archive for generic/iOS SUCCEEDED (CODE_SIGNING_ALLOWED=NO); resolved app + Z24x4Widgets.appex
> both report **3 / 1.0.0**. Archive embeds iOS app + widget only (app is iPhone-only; watch app
> independent, not in this store build). **Upload still pending user** — needs ASC API key env
> (DEVELOPMENT_TEAM/ASC_KEY_ID/ASC_ISSUER_ID/ASC_KEY_PATH) then `scripts/archive-and-export.sh --upload`.

> **2026-06-12 (later): `l10n-gap-fill` done [6/6] — last hardcoded UI strings localized.**
> `AccessibleStepper.title` + `ZoneChip.title` → `LocalizedStringKey` (String params rendered
> verbatim); `ActivityLevel.displayName`; History weekday labels from `Calendar.shortWeekdaySymbols`
> (Monday-first) + chart captions/Latest summary localized; es plural for "%lld-week streak"
> ("Racha de 1 semana"). App catalog 181 keys, 0 needs_review. Verified in sim (es+ja): Edad/年齢,
> Moderado/中程度, lun–dom weekday axis, Minutos por día, Último %@, 4×4 intenso, Racha de 1 semana.
> Note: earlier "Zone 2 untranslated" sightings were screenshot misreads — runtime probe confirmed
> `String(localized: "Zone 2")` → "Zona 2" all along.

> **2026-06-12: `ux-polish` done [6/6] — ROUND 4 COMPLETE (all 4 changes archived).**
> Onboarding intro page (3 core points) before the form; Today welcome card when no logs
> (guided/manual CTAs, hides after first log); `RecentWorkoutsSection` on History (last 10,
> source icon, note); new `WorkoutLog.sourceRaw` (manual/health/watch — `healthUUID` no longer
> distinguishes since manual writeback; set in ManualEntryView default/HealthStore import/
> PhoneSessionReceiver; export `source` now uses it). Localization: 36 new keys merged into
> App catalog (now 166) with zh-Hant/es/ja; full es/ja review pass — terminology unified
> (es "Apple Salud"/"Zona 2"; ja latin "Zone 2", "ノルウェー式 4×4", "Appleヘルスケア") and
> **0 needs_review in both catalogs**. Verified: iOS+watch builds, iOS tests green; sim smoke:
> intro page, welcome card (and hides with logs), es/ja Today/Settings/History screenshots.
> Known pre-existing l10n gaps (English fallback, not this round): "Age", ActivityLevel raw
> values ("moderate"), chart internals ("Minutes per day", weekday abbrevs), es plural
> "Racha de 1 semanas", zone chip "4×4 hard".

> **2026-06-11: `units-export` done [9/9] — imperial units + history export.**
> `ProfileRecord.unitsRaw` (metric default, locale-derived on onboarding); Settings units picker,
> weight + loss-rate fields display kg↔lb (storage stays metric); onboarding imperial entry
> (lb, ft+in) converts before save; History weight chart converts axis/series; History toolbar
> export Menu — CSV (RFC-4180) + JSON ShareLinks via Transferable (`workouts.csv`/`.json`),
> `source` = `health`/`manual` by `healthUUID`. Verified: SharedCore 79 tests, iOS builds green,
> sim smoke en_CA→metric and US-units→imperial onboarding (lb/ft+in rendered). Not GUI-tapped:
> Settings unit flip + export share sheet (no headless tap tool) — quick manual check recommended.
> New strings pending catalog translation (zh-Hant/es/ja): Units/Metric/Imperial/Weight (lb)/
> Height (ft + in)/Export/Export CSV/Export JSON/lb-week format.

> **2026-06-10: `watch-parity-widgets` done [11/11] — watch status parity + new widgets/complications.**
> WidgetSnapshot v2 (readiness/streak fields, backward-compatible decode), phone publishes snapshot +
> profile to watch via `updateApplicationContext` (`PhoneStatusPublisher`), watch writes its own App
> Group copy and shows a status block (readiness/streak/week progress) above the workout list; new
> `StreakWidget`/`ReadinessWidget` (iOS) and `ReadinessComplication`/`StreakComplication` (watch),
> `NextSessionComplication` reads the snapshot first. Verified: SharedCore **79 tests**, iOS tests
> (HealthWriteback + PhoneSessionReceiver) green, iOS + watch builds green, iPhone 17 sim launch
> (`-mockHealth -seedProfile`) renders Today, watch sim shows "Waiting for iPhone sync" placeholder.
> **Hardware-pending:** real-Watch `applicationContext` delivery timing + watch-face complication
> refresh cadence need a physical Apple Watch.
>
> **2026-06-10: `localization-sweep` archived [7/7] — full-app l10n coverage done.** ~80 remaining
> user-visible strings localized across Week/Settings/History/Achievements/StreakBanner/ShareCard/
> Onboarding/ManualEntry/WorkoutDetail/GuidedPlayer + SharedCore (Achievement titles, readiness
> recommendations via `String(localized:bundle:.module)`). App catalog 130 keys, SharedCore 13.
> zh-Hant translated; es/ja drafted (needs_review). Verified: SharedCore **62 tests**, iOS + watch
> builds green, zh-Hant simulator smoke (readiness/coach/streak cards localized). **Round 4 planned**
> (4 Spectra changes): `watch-parity-widgets`, `health-writeback-robustness`, `units-export`, `ux-polish`.
>
> **2026-06-05: v1.0 SUBMITTED to the App Store — state WAITING_FOR_REVIEW.** App id 6776864990,
> team 2NXQLV6CJH, build 2 (real icon). All metadata/screenshots/age-rating/pricing(Free)/privacy
> set headlessly via the App Store Connect API. Awaiting Apple review.
>
> **2026-06-07: Round 2 done — 3 more epics, agent-built.** `readiness-hrv` [3/3]
> (HRV+RHR `ReadinessCalculator`, Today readiness card — verified "100 · Go hard"), `smart-reminders`
> [2/2] (`ReminderScheduler` local notifications + Settings opt-in), `shareable-cards` [2/2] (`ShareCard`
> + `ImageRenderer`/`ShareLink` on History). SharedCore **58 tests**. Added `-mockHealth` launch arg
> (canned Health data for UI smoke tests). Remaining roadmap: guided-player-audio, widgets-complication,
> localization.
>
> **2026-06-06: "Powerful & Attractive" Round 1 done — 3 epics, agent-built.**
> `precision-zones` [3/3] (Karvonen/HRR + custom zones + Settings picker), `smart-coach` [5/5]
> (adaptive `PlanProgression`, VO2max `FitnessTrend`, Today Coach card, History trend), `streaks-achievements`
> [4/4] (StreakCalculator, Achievement catalog, Awards tab, celebration). SharedCore **52 tests**;
> built by 1 domain agent + 3 UI agents, integrated + verified (Today Coach+streak, Awards badges,
> Settings Zones all render light/dark; receiver tests + watch build green). Roadmap epics queued on
> the Spectra board: readiness-hrv, guided-player-audio, widgets-complication, smart-reminders,
> shareable-cards, localization. Ship as build 3 (after v1.0 review).
>
> **2026-06-05: UI/UX refresh done (Spectra `ui-ux-refresh` [6/6]).** Shared design system
> (`App/DesignSystem/`: Theme + AccentColor, Card/SectionHeader/TargetBar/PrimaryButton/ZoneChip,
> ZoneStyle) + all screens restyled clean/minimal card-led, light+dark, motion + haptics + a11y.
> Built by 3 agents (1 foundation + 2 parallel), integrated + verified (iOS build, 32+3 tests,
> watch build, every screen screenshotted both modes). Presentation-only — targets the NEXT version.

Single source of truth for build progress. Read on Mac (Spectra + terminal) and iPhone
(GitHub app + claude.ai/code web). Update + commit at the end of every work session.

Legend: `[ ]` todo · `[~]` in progress (進行中) · `[x]` done + verified (已封存)

## Phase 0 — Project + tooling setup
- [x] git repo initialised
- [x] `.gitignore`, `PROGRESS.md`, `README.md`
- [x] tooling verified: Swift 6.3.2, Xcode, xcodegen 2.45.4, gh (authed: ozzyfly), brew
- [x] `SharedCore` Swift package scaffolded
- [x] push to private GitHub repo → https://github.com/ozzyfly/z2-4x4-trainer
- [x] `project.yml` (xcodegen) for iOS app target — generates valid project, package graph resolves
- [x] HealthKit entitlement + Info.plist usage strings (in `project.yml`)
- [x] Spectra connected: `openspec/config.yaml` context+rules filled, `spectra validate` clean, instruction files updated
- [ ] **BLOCKER for Phase 2+:** iOS platform SDK not installed. Run `xcodebuild -downloadPlatform iOS`
      (multi-GB) before any app build/run. SharedCore (Mac) is unaffected.
- [ ] watchOS app target → added in Phase 4 (needs hardware to verify)

## Phase 1 — Domain core (TDD, no UI) — runs on Mac via `swift test` ✅
- [x] `UserProfile`
- [x] `HRZoneCalculator` (maxHR = 220−age, override; Z1–Z5; Zone 2 + 4×4 bands)
- [x] `Norwegian4x4` (warmup → 4×(4min hard / 3min recovery) → cooldown, 43 min)
- [x] `TrainingPlan` (weekly: 3–4 Zone 2 + 1–2 4×4, scaled by goal)
- [x] `WeeklyTargets` / `DailyTargets` (WHO 150 min floor; weight-loss deficit)
- [x] `EnergyCalculator` (Mifflin–St Jeor BMR → TDEE → kcal deficit)
- [x] all unit tests green — **20/20 passing**

## Phase 2 — iOS app (manual input path) — code written, build pending iOS SDK
- [x] SwiftData persistence (`ProfileRecord`, `WorkoutLog`)
- [x] onboarding (profile + goal) — HealthKit permission deferred to Phase 3
- [x] Today screen (today's session + zones + daily target progress)
- [x] Week screen (plan + weekly target progress)
- [x] Workout detail (Zone 2 + 4×4 personalised HR bands + interval breakdown)
- [x] Settings (override maxHR, activity, change goal)
- [x] manual workout entry
- [x] **build + run in simulator** — BUILD SUCCEEDED, app launches, onboarding + Today verified
      (iOS 26.5 sim; zones/targets match SharedCore tests). `-seedProfile` launch arg seeds a test profile.

## Phase 3 — HealthKit integration — code done, builds; live Health unverified in sim
- [x] `HealthProviding` protocol + `HealthKitService` (HR, active energy, resting HR, body mass, workouts) + `PreviewHealthService` mock
- [x] `HealthStore` (@Observable): auth, today energy, weight series, imports workouts → `WorkoutLog` deduped by `healthUUID`
- [x] progress vs targets uses real active energy; "Connect Apple Health" in Settings
- [x] History tab + Swift Charts (weekly minutes bars + weight trend) — verified rendering with `-seedWorkouts`
- [ ] verify real Health read/import on a physical device (sim Health DB is empty)

## Phase 4 — Apple Watch app — builds + runs on watchOS 26.5 sim
- [x] `Z24x4TrainerWatch` target added to `project.yml` (companion, HealthKit)
- [x] **watch target BUILD SUCCEEDED** (watchOS SDK installed); app launches on sim, workout list renders
- [x] workout list (`WorkoutListView`)
- [x] live `HKWorkoutSession` + `HKLiveWorkoutBuilder` (`WorkoutSessionManager`): real-time HR + zone
- [x] 4×4 interval engine + haptics (`IntervalEngine`)
- [x] save `HKWorkout` + send to phone (`Watch/WorkoutSync.swift`, WCSession message + transferUserInfo fallback)
- [x] phone⇄watch sync code: `App/Sync/PhoneSessionReceiver.swift` (WCSessionDelegate → dedupe by `healthUUID` → `WorkoutLog`), activated in app. iOS builds; dedupe + transfer round-trip unit-tested (32 SharedCore) **+ receiver end-to-end tested vs in-memory SwiftData (3 tests, `Z24x4TrainerTests`)**
- [x] watchOS 26.5 SDK installed; `Z24x4TrainerWatch` compiles for device + simulator
- [ ] tested on physical Apple Watch (live HR + haptics + end-to-end phone sync need real hardware;
      also verify watch workouts persist to Apple Health via `HKLiveWorkoutBuilder.finishWorkout` —
      code path confirmed in `Watch/WorkoutSessionManager.swift` `finishAndSave()`, spec'd in
      `health-writeback` capability)

Tracked as Spectra change `watch-phone-sync` (`spectra status`).

## Phase 5 — App Store readiness — release config done; submission pending dev account
- [x] app icon (1024² placeholder) — replace art before release
- [x] App Privacy label + privacy policy (`docs/app-store/`) + hostable `docs/privacy-policy.html`
- [x] metadata draft (`docs/app-store/METADATA.md`)
- [x] real App Store screenshots captured @ 1320×2868 (6.9") → `docs/app-store/screenshots/`
- [x] release config: version → 1.0.0, `CODE_SIGN_STYLE: Automatic`, `scripts/archive-and-export.sh`, `docs/app-store/ExportOptions.plist`; Release config compiles for device
- [x] enrolled Apple Developer Program — **real Team ID `2NXQLV6CJH`** (not HF6XYU9Y2N)
- [x] **signed + archived + uploaded to App Store Connect** (build delivered, UUID f8e45007-…) — headless via ASC API: created distribution cert + bundle id (HealthKit) + App Store profile, manual-signed archive, `altool` upload. App is **iPhone-only** (`TARGETED_DEVICE_FAMILY: "1"`).
- [ ] host privacy policy (enable GitHub Pages on `/docs`) — needs push
- [ ] enter metadata + privacy label + screenshots in App Store Connect — user action (drafts/screenshots ready in `docs/app-store/`)
- [ ] replace placeholder app icon with final art
- [ ] TestFlight internal test → submit for review — user action

Tracked as Spectra change `app-store-submission` (`spectra status`).
