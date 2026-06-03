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
- [ ] Spectra project registered (`config.yaml`: 專案說明 + 產出規則) + one 規格 per phase — **user action in Spectra app**
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
- [ ] **build + run in simulator** — blocked on iOS SDK download (in progress)

## Phase 3 — HealthKit integration
- [ ] `HealthService` (read HR, active energy, resting HR, body mass, workouts)
- [ ] progress vs daily/weekly targets from real data
- [ ] history + Swift Charts

## Phase 4 — Apple Watch app
- [ ] workout list mirrored from phone
- [ ] live `HKWorkoutSession` (real-time HR, zone, Zone 2 alerts)
- [ ] 4×4 interval engine + haptics
- [ ] save `HKWorkout` + sync to phone
- [ ] tested on physical Apple Watch

## Phase 5 — App Store readiness
- [ ] app icon + launch screen + accessibility
- [ ] App Privacy label + privacy policy
- [ ] screenshots + metadata
- [ ] enroll Apple Developer Program ($99/yr)
- [ ] TestFlight internal test
- [ ] submit for review
