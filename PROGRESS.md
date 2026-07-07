# PROGRESS — Z2/4×4 Trainer

> **2026-07-07: 4 new languages (ko/de/fr/pt-BR) + in-app language switcher — VERIFIED on Mac:**
> iOS test 35/35, watch build OK; sim Today screen spot-checked in all 4 new languages
> (-AppleLanguages) — tab bar, readiness, coach cards all localized, German fits without
> clipping. Settings/paywall screens not GUI-spot-checked (needs interactive nav) — eyeball
> them in the sim before ship. Original notes:
> App now localizes to 8 languages: en, zh-Hant, es, ja + new Korean, German, French,
> Brazilian Portuguese. All 5 catalogs fully covered (424 keys × 4 new langs ≈ 1,700
> localizations: App 305, Watch 25, SharedCore 40, Widgets 34, Complications 20), including the
> "%lld-week streak" plural variations per language. Added via new `scripts/add_locales.py`
> (merge-only — never overwrites, aborts on unknown keys, enforces %-placeholder parity;
> post-run scan CLEAN). `project.yml` knownRegions extended. **Language switcher:** Settings
> gains a Language section → deep-links to the system per-app language page
> (`openSettingsURLString`) — Apple's supported path; no AppleLanguages hack, no relaunch logic.
> +3 App keys ("Language", "Change app language", language list) ×7 langs. **Verify on Mac:**
> `xcodegen generate` → build → sim run with `-AppleLanguages (ko)` (and de/fr/pt) to spot-check
> Today/Settings/paywall rendering, watch build, then native-speaker review is the known gap —
> translations are AI-drafted (state=translated; flip to needs_review per language if you want
> Xcode to track a human pass). ASC metadata for the new locales is a separate, optional step.

> **2026-07-06: monetization implemented — freemium + one-time Pro unlock — VERIFIED on Mac:**
> iOS test 35/35 (iPhone 17 sim; incl. 3 grandfather tests), watch build succeeded. One Mac
> fix: `ProStore.grandfatherCutoff` needed `nonisolated` (MainActor-isolated static used as a
> default value in the nonisolated `isGrandfathered`). GUI buy-flow check pending (StoreKit
> config only loads via the Xcode scheme). Original notes:
> StoreKit 2, one non-consumable (`ca.logolo.z24x4.pro.lifetime`, US$14.99 anchor, Family
> Sharing). New `App/Store/ProStore.swift` (@Observable; on-device
> `Transaction.currentEntitlements` verification — no server/account, keeps the local-only
> promise; `Transaction.updates` listener; explicit restore; `-pro` launch override).
> **Launch-cohort grandfathering:** first launch before 2026-08-01 (`grandfatherCutoff`) is Pro
> free forever — v1.0 ships effectively free, the paywall bites for post-cutoff installs; rule
> is pure + tested (`Tests/ProGrandfatherTests` ×3). **Gates (5):** readiness details (label +
> recommendation stay FREE as the safety layer; score/signals/explanation Pro), ACWR analysis
> (warning headline free, numbers Pro), adaptive `PlanProgression` (free = base plan), History
> export (CSV/JSON), VO₂max trend card. Teasers via new `ProTeaserRow` (quiet lock row, never a
> nag). **UI:** `ProPaywallView` (Hermès: serif headline, 5 feature rows, price from
> `Product.displayPrice`, restore, "everything you use stays free" footnote) + Settings top
> section (unlocked thank-you / unlock CTA). **Infra:** `Z24x4.storekit` local test config wired
> into the run scheme via project.yml (`storeKitConfiguration`); previews injected with
> `.environment(ProStore())`. l10n: +24 app keys (zh-Hant/es/ja). Docs:
> `docs/app-store/IAP_SETUP.md` (ASC product setup, review-guideline checklist — note the two
> open items: app-description disclosure line + privacy-policy sentence). **Verify on Mac:**
> `xcodegen generate` (new files + scheme change) → iOS build+test (expect 35 = 32 + 3
> grandfather) → sim run: buy flow via the StoreKit config, gates flip, restore works,
> `-pro` override, and confirm a pre-cutoff first launch stays unlocked.
>
> **Follow-up same day:** the two open review-checklist items closed — METADATA description
> gained a "FREE + AN OPTIONAL ONE-TIME UPGRADE" section (3.1.1 disclosure), and an
> "In-app purchases" section was added to PRIVACY_POLICY.md + the hosted privacy-policy.html
> (processed by Apple, verified on-device, never linked to Health data). Push to publish the
> HTML via Pages. **Decisions settled (user, 2026-07-06):** widget readiness score stays
> visible for free users — deliberate teaser, no snapshot stripping. Price confirmed US$14.99.
> **Post-workout teaser implemented:** WorkoutLogDetailView now shows one quiet ProTeaserRow
> ("What this session means for tomorrow") under the stats for non-Pro users, only on sessions
> that actually have quality/Zone 2 stats — the highest-intent conversion moment. +1 l10n key.
> **2026-07-06: hardware verification COMPLETE — 5.1 / 5.2 / 4.1 all PASS.** User confirmed the
> remaining items: wrist-down 30s catch-up ✓ (TickClock works on-device), transition haptics ✓,
> guided autolog ✓, screen-awake ✓, zero crashes ✓; TestFlight screenshot confirms build
> **1.0.1 (58)**. Checklist RESULT lines all filled. Unexercised non-blockers noted in the
> checklist (blind fallback, 5s live-HR cadence, readiness-widget survival, audio-duck).
> Note: the Jul 6 watch photos still showed the *pre-banner* Zone 2 layout — the photo-driven
> UI fixes are on main but the watch app needs a fresh Xcode install to pick them up.
> **Next:** `/spectra-archive` for `watch-phone-sync` + `app-store-submission` on the Mac,
> reinstall the watch app (see the new Zone 2 top banner), then cut build 59 and submit.
>
> **Same evening — completion overlays redesigned (photo feedback: "can't scroll, still messy").**
> Both watch summary overlays (`Zone2CompletionOverlay`, `CompletionOverlay`) rebuilt: opaque
> black instead of `.ultraThinMaterial` (the live screen was bleeding through), wrapped in a
> ScrollView (fixed VStack couldn't scroll / risked clipping on smaller watches), nav bar hidden
> while a summary is up (the overlay checkmark was colliding with the nav title), and hierarchy
> reduced to serif overline → one hero number (44pt effective time / quality score) → one quiet
> caption block → buttons. Dropped: big checkmark/seal icons, pop animation, "Zone 2 summary"
> title (nav already says Zone 2). l10n: +2 watch keys ("Quality", "Nice work!" — the latter
> was previously hardcoded-English on device). Verify: watch build + reinstall, end a session
> on both paths, confirm scroll + no bleed-through.
>
> **2026-07-06 (later): streak card removed from Today** (user: "沒什麼意義"). Deleted
> `App/Views/StreakBanner.swift` + its TodayView call site. Streak data itself stays — the
> History header stat, StreakWidget, and watch complication still read
> `StreakCalculator`/snapshot `streakWeeks`; only the Today card is gone. `xcodegen generate`
> required (file removal).

> **2026-07-05 (evening): first real-hardware session + photo-driven UI fixes — VERIFIED on Mac
> same evening:** SharedCore 117/117, iOS test (iPhone 17 sim) 32/32 (incl. the new min-import
> case), watch build succeeded. Original notes:
> Real Apple Watch Ultra runs landed: 4×4 (Quality 100, 4/4 reps, peak 164/91%, avg hard 159,
> **kcal non-nil — share-auth fix confirmed**, Source=Apple Watch) and Zone 2 (avg 121/67%,
> credited 35/40 min, 87% in zone — tracker math consistent watch↔phone). Earlier "no BPM" was
> resolved on-device (permissions); live view showed 120 BPM in zone. Photo review drove 4 fixes:
> **(1) Zone 2 banked time promoted to a top banner** (mirrors the 4×4 countdown banner: green
> while crediting, dimmed pause icon out-of-zone, heart-slash when blind); the old bottom
> elapsed block deleted — its status captions duplicated the target-feedback card. Blind label
> now sits under the HR panel for Zone 2 like the 4×4's. **(2) truncation pass** from the
> photos: "Zone 2 summa…" (overlay title minScale 0.6), "Avg hard 159 · peak…" (stats wrap via
> fixedSize), "Keep going" mid-word wrap (lineLimit 1 + minScale), "Waiting for hear…" (feedback
> title minScale 0.8→0.6). **(3) iPhone Zone 2 detail**: Details now adds a "Total time" row
> (wall clock) when it exceeds credited minutes, so "Duration 35 min" on a 40-minute run reads
> as effective-time-by-design (+1 l10n key ×3 langs). **Verify:** watch build + sim screenshot
> of Zone 2 live (banner on top), iOS build. Checklist RESULT lines still await the user's
> explicit pass/fail (wrist-down catch-up, no-dup, screen-lock, audio-duck unconfirmed by photos).
>
> **Later same evening — History screenshot read into the checklist + one algo fix.** 5.1 marked
> PASS (photos; haptics/wrist-down still verbal-pending), 5.2 marked PASS (both real sessions
> appear exactly once, Source=Apple Watch, kcal 108/243), 4.1 PARTIAL (watch-driven sessions
> recorded; guided-autolog/screen-awake/duck/no-crash need user word). **Algo finding from the
> same screenshot:** two 1-minute "Imported from Apple Health" junk rows (11:37, 13:34) — watch
> mis-tap tests the watch refused to sync, resurrected by the Health auto-import. Fix:
> own-stamped imports now need ≥5 min (`HealthStore.minimumOwnImportMinutes`; foreign workouts
> keep ≥1); new `HealthImportSnapshotTests` case (mis-tap filtered / real kept / foreign kept)
> → iOS suite expects 32. Old junk rows: swipe-delete (tombstones prevent re-import).
> Two more from the same photos: History row title "Norwegian 4×4" wrapped mid-name → lineLimit 1
> + minScale (also de-rounded the leftover `.rounded` title font). And a **kcal inversion**
> (34-min 4×4 = 108 kcal vs 35-min Zone 2 = 243) — symptom of `.running`/`.unknown` on
> non-running modalities; recorded as evidence in feature proposal #3 (modality picker), not a
> quick fix.

> **2026-07-05: overtraining signals without live HR — VERIFIED on Mac same day:** SharedCore
> `swift test` 117/117, iOS test (iPhone 17 sim) 31/31, watch build succeeded. One fix needed on
> Mac: the new `HealthProviding` requirements (`wristTemperatureSeries`, `lastNightSleepHours`)
> broke the 3 iOS test doubles (SeedHealth/Spy/SpyHealthService) — added `[] / nil` stubs.
> Original notes: Answering "watch can't
> see HR — can HRV/other data warn about overtraining": live HRV mid-workout isn't measurable
> (Apple only samples SDNN at rest), so blind-mode stays the in-session fallback; overtraining
> detection is a *between-sessions* signal, now strengthened on four fronts. **(1) ACWR** — new
> SharedCore `TrainingLoad` (acute 7d ÷ chronic 28d minutes, caution ≥1.3 / high-risk ≥1.5,
> ratio suppressed under 60 chronic weekly minutes; 5 tests); Today shows a warning card only
> when elevated ("Ramping fast/too fast"). Zero sensor dependence — works with no HR/HRV at all.
> **(2) readiness model extended** — `ReadinessCalculator.score` gains optional penalty-only
> signals: sleeping wrist temperature vs 28d baseline (−15/−25 at +0.3/+0.5 °C, needs ≥7 baseline
> samples) and last-night sleep (−10/−20 under 6h/5h); 6 tests; existing call sites unaffected.
> Phone reads `appleSleepingWristTemperature` + `sleepAnalysis` (new read auths) and feeds them.
> **(3) watch pre-start guard** — tapping 4×4 on a low-readiness day now confirms first
> ("Do Zone 2 instead / Reduced 4×4 anyway"); works with zero live HR. New
> `Watch/WatchReadinessProvider` computes readiness on-watch from its own HealthKit HRV/RHR
> (new read auths) whenever the phone snapshot is >24h old or lacks a label;
> `WorkoutSessionManager.readinessOverride` feeds the rep reduction. **(4) no-HR diagnostics**
> (the observed "watch 看不到 HR"): live builder now `enableCollection`s heart rate + energy
> explicitly, and after 30s with no reading the live view escalates to "check Health access in
> the watch Settings app, and snug the band" instead of "still locking on". l10n: +6 watch,
> +4 app, +2 SharedCore keys (zh-Hant/es/ja). **Verify on Mac:** `xcodegen generate` (2 new watch
> files) → SharedCore `swift test` (expect ~117: 106 + 11 new) → iOS + watch builds → on watch,
> re-grant the new Health prompts (HRV/RHR read).

> **2026-07-03 (late): build 58 uploaded to App Store Connect** ("Upload succeeded", processing).
> First build containing the July robustness/UI rounds — supersedes TestFlight build 12; the
> hardware checks in `docs/manual-verification-checklist.md` (5.1/5.2/4.1 + 2026-07-03 extras)
> must run against 58+. ASC key now at `~/private_keys/AuthKey_4AJBG7WZAL.p8`;
> `.claude/settings.local.json` ignored (held the issuer ID). Next: hardware runs → fill
> RESULT lines → archive `watch-phone-sync` + `app-store-submission`.

> **2026-07-03: robustness + release-pipeline pass (agent review) — VERIFIED on Mac same day:**
> SharedCore `swift test` 106/106, iOS `xcodebuild test` (iPhone 17 sim) 31/31, watch build
> succeeded. Committed alongside the previously uncommitted Awards-feature removal (separate
> commit). Original notes: **(1) wall-clock timing** — new SharedCore `TickClock` (Date-anchored catch-up ticks,
> 7 new tests); `Watch/IntervalEngine`, watch Zone 2 timer, and `App/GuidedSessionEngine` now
> replay seconds a throttled timer missed (wrist-down drift fix — the pending real-Watch risk);
> incoming HR samples also drive ticks. **(2) Zone 2 blind fallback** — `Zone2TimeTracker` gains
> `noHRGraceSec`/`isBlind` (credits wall-clock after 15s of no HR so a dead sensor can't void a
> session; 2 new tests); Live view shows "No HR — timed" (reused key); both engines treat >10s-old
> HR samples as no reading (a dead sensor's last value otherwise looks fresh forever).
> **(3) watch auth** — share types now include heartRate + activeEnergyBurned (live builder saves
> those samples; energy was at risk of being dropped). **(4)** `sendLiveHR` throttled to 1 msg/5s.
> **(5)** `PhoneSessionReceiver.ingest` dedupes via `#Predicate` UUID fetch (no full-table scan).
> **(6)** all 7 `print`s → `os.Logger` (subsystem `ca.logolo.z24x4`). **Release pipeline:** new
> `.github/workflows/ci.yml` (SharedCore tests + iOS test + watch build) and `release.yml`
> (tag `v*` → archive+upload; needs ASC_* secrets); `archive-and-export.sh` now derives
> CURRENT_PROJECT_VERSION from `git rev-list --count HEAD` (override: `BUILD_NUMBER=`) and uploads
> via ExportOptions `destination=upload` (drops deprecated altool). **Docs:** METADATA keywords
> rewritten (drop name/subtitle duplicates), `docs/feature-proposals-2026-07-03.md` (5 proposals:
> live-activity, workout-hr-series, outdoor-gps-route, morning-readiness-notification,
> maxhr-field-test). **Verify on Mac:** `cd SharedCore && swift test` (expect 79+9); iOS
> build+test iPhone 16 sim; watch build; then commit. Note: worktree already held unrelated
> uncommitted changes (Achievements refactor, icon) — left untouched, not committed.
>
> **Round 2 (same day): snapshot/refresh fixes.** (7) **readiness-wipe bug** — of
> `WidgetSnapshotWriter.update`'s 10 call sites only RootView passes readiness; the other 9
> (watch sync, manual entry, guided log, Health import, scene-active) wrote nil, wiping the score
> off widgets/complications AND off the watch's readiness-based 4×4 rep reduction
> (`Norwegian4x4.recommendedRepeats` reads the snapshot). Writer now carries the previous
> same-day readiness forward when the caller passes nil. (8) **foreground refresh** — RootView
> only loaded Health data in its one-shot `.task`; now also `health.refresh` on scenePhase →
> `.active` (guarded on `authorized`), so today-energy/readiness/imports update when returning
> from a watch session. (9) snapshot writer now fetches newest-first with `fetchLimit` 1000
> instead of the unbounded full table (runs after every mutation); Health-import dedup fetches
> only the `healthUUID` column (`propertiesToFetch`).
>
> **Round 3 (same day): guided-player UX.** (10) **screen auto-lock killed guided sessions** —
> no `isIdleTimerDisabled` anywhere, so mid-workout the display locked, the app suspended, and
> voice cues stopped (TickClock only recovers state, not the coaching). GuidedPlayerView now
> disables the idle timer onAppear / restores it onDisappear. (11) **43-minute music duck** —
> the engine activated the `.duckOthers` audio session at start and held it for the whole
> session, leaving the user's music ducked throughout. New `SpeechCoordinator`
> (AVSpeechSynthesizerDelegate) activates the session just-in-time per cue and deactivates
> (`.notifyOthersOnDeactivation`) when the utterance queue drains. Known-and-left: workouts save
> as `.running` regardless of actual modality; watch back-swipe during a live session shows the
> picker again (harmless — `start` is `isRunning`-guarded — but consider hiding back);
> `try!` ModelContainer at startup.
>
> **Round 4 (same day): Hermès-style UI refinement pass — VISUAL, needs sim screenshots.**
> iPhone: `numericStyle` de-rounded (SF default numerals — editorial next to the serif
> headings; app-wide change); SectionHeader tracking 1.6→2.2; TargetBar slimmed to a 6pt bar on
> a neutral separator track (orange = earned fill only); off-palette colors folded into tokens
> (Today flame `.orange`→accent, guided-player heart `.red`→danger, 76pt clock de-rounded).
> Widgets: mirrored brand palette added (extension can't link the app target — hex pairs
> duplicated from Theme with a keep-in-sync note); streak `.orange`→brandAccent, readiness
> green/blue/yellow→status tokens. Watch: new `Watch/WatchTheme.swift` (accent/ivory/taupe,
> dark-appearance values); list rows unified to the single brand accent (glyphs already
> differentiate sessions); duplicated "This week" label removed; week progress + overlay Done
> buttons green→accent; live HR panel ring 3pt→1.5pt hairline; completion titles serif.
> Deliberately KEPT: all mid-workout semantic colors (in-zone green / too-high orange cues,
> paused warnings) — glanceability during exercise beats palette purity. Verify: light+dark
> screenshots of Today/Week/History/Settings, widget gallery, watch list + live + overlays;
> `xcodegen generate` required (new WatchTheme.swift).

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
