# PROGRESS — Z2/4×4 Trainer

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
- [ ] tested on physical Apple Watch (live HR + haptics + end-to-end phone sync need real hardware)

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
