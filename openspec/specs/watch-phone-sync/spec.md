# watch-phone-sync Specification

## Purpose

TBD - created by archiving change 'watch-phone-sync'. Update Purpose after archive.

## Requirements

### Requirement: Completed Watch workout syncs to the iPhone
The Watch app SHALL transfer a completed workout to the paired iPhone over WatchConnectivity,
and the iPhone SHALL persist it as a `WorkoutLog`.

#### Scenario: Workout finished on the Watch reaches the phone
- **WHEN** a user ends a Zone 2 or Norwegian 4×4 session on the Apple Watch
- **THEN** the Watch sends the session (date, type, duration, active energy, Health UUID) to the iPhone
- **AND** the iPhone inserts a matching `WorkoutLog` that appears in Today, Week, and History

#### Scenario: Phone unreachable at end of workout
- **WHEN** the iPhone is not reachable as the workout ends
- **THEN** the Watch SHALL queue the session for background transfer
- **AND** the iPhone SHALL persist it once delivery completes

##### Example: queued then delivered
- **GIVEN** a finished 4×4 session with healthUUID `ABC-123` and `WCSession.isReachable == false`
- **WHEN** the Watch calls `transferUserInfo` and the phone reconnects 2 minutes later
- **THEN** the iPhone stores one `WorkoutLog` with healthUUID `ABC-123`


<!-- @trace
source: watch-phone-sync
updated: 2026-07-06
code:
  - SharedCore/Sources/SharedCore/TickClock.swift
  - Tests/WorkoutSourceTests.swift
  - SharedCore/Sources/SharedCore/GuidedCue.swift
  - SharedCore/Sources/SharedCore/HRZoneCalculator.swift
  - Watch/Assets.xcassets/AppIcon.appiconset/icon_1024.png
  - App/GuidedSessionEngine.swift
  - App/Views/GuidedPlayerView.swift
  - App/Views/ShareCard.swift
  - docs/app-store/screenshots/04-history.png
  - docs/app-store/screenshots/01-today.png
  - SharedCore/Tests/SharedCoreTests/UnitsExportTests.swift
  - docs/app-store/ExportOptions.plist
  - Widgets/Localizable.xcstrings
  - App/Health/HealthKitService.swift
  - App/Health/PreviewHealthService.swift
  - App/Views/HistoryView.swift
  - Watch/LiveWorkoutView.swift
  - App/Sync/LiveHRStore.swift
  - App/Views/SettingsView.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - PROGRESS.md
  - Tests/AppleZonesSeedTests.swift
  - App/WidgetSnapshotWriter.swift
  - WatchComplications/Z24x4WatchComplications.swift
  - App/Sync/PhoneStatusPublisher.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - Watch/WatchTheme.swift
  - Tests/GuidedPlayerLoggingTests.swift
  - SharedCore/Sources/SharedCore/IntervalRunner.swift
  - SharedCore/Tests/SharedCoreTests/Norwegian4x4Tests.swift
  - App/Persistence/DeletedWorkout.swift
  - App/GuidedSessionLogger.swift
  - Watch/WorkoutListView.swift
  - Watch/Assets.xcassets/Contents.json
  - SharedCore/Package.swift
  - Widgets/Info.plist
  - scripts/asc_jwt.py
  - App/Persistence/ProfileRecord.swift
  - Watch/WorkoutSessionManager.swift
  - SharedCore/Tests/SharedCoreTests/TrainingLoadTests.swift
  - App/Views/Celebration.swift
  - SharedCore/Sources/SharedCore/WorkoutRecord.swift
  - SharedCore/Sources/SharedCore/CoachingCue+UI.swift
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - SharedCore/Tests/SharedCoreTests/TickClockTests.swift
  - docs/privacy-policy.html
  - App/Views/AppleZonesView.swift
  - .github/workflows/release.yml
  - Widgets/Z24x4Widgets.swift
  - SharedCore/Sources/SharedCore/UnitConvert.swift
  - SharedCore/Tests/SharedCoreTests/PrecisionZonesTests.swift
  - SharedCore/Sources/SharedCore/MetricSample.swift
  - SharedCore/Tests/SharedCoreTests/IntervalRunnerTests.swift
  - App/Views/ProfileWatchSync.swift
  - docs/app-store/screenshots/05-settings.png
  - App/Views/OnboardingIntroView.swift
  - SharedCore/Tests/SharedCoreTests/GuidedCueTests.swift
  - CLAUDE.md
  - App/Views/TodayView.swift
  - Watch/Z24x4WatchApp.swift
  - WatchComplications/Info.plist
  - SharedCore/Sources/SharedCore/Localizable.xcstrings
  - App/Z24x4Trainer.entitlements
  - SharedCore/Sources/SharedCore/PlanProgression.swift
  - scripts/asc_push_metadata.py
  - .github/workflows/ci.yml
  - App/Views/WeekView.swift
  - App/DesignSystem/Theme.swift
  - docs/manual-verification-checklist.md
  - WatchComplications/Z24x4WatchComplications.entitlements
  - Widgets/Z24x4Widgets.entitlements
  - App/Views/WorkoutDetailView.swift
  - SharedCore/Tests/SharedCoreTests/Zone2TimeTrackerTests.swift
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
  - SharedCore/Sources/SharedCore/Readiness.swift
  - SharedCore/Tests/SharedCoreTests/WorkoutTransferTests.swift
  - docs/app-store/METADATA.md
  - Watch/Localizable.xcstrings
  - App/Notifications/ReminderScheduler.swift
  - App/Views/StreakBanner.swift
  - Watch/Assets.xcassets/AppIcon.appiconset/Contents.json
  - SharedCore/Sources/SharedCore/ZoneMethod.swift
  - docs/feature-proposals-2026-07-03.md
  - SharedCore/Tests/SharedCoreTests/ZoneLadderTests.swift
  - App/DesignSystem/Buttons.swift
  - Tests/HealthWritebackTests.swift
  - SharedCore/Sources/SharedCore/UnitPreference.swift
  - project.yml
  - App/Localizable.xcstrings
  - SharedCore/Sources/SharedCore/Zone2TimeTracker.swift
  - Tests/HealthImportSnapshotTests.swift
  - scripts/asc_upload_screenshots.py
  - SharedCore/Tests/SharedCoreTests/ReadinessExtendedSignalsTests.swift
  - SharedCore/Sources/SharedCore/ZoneLadder.swift
  - App/DesignSystem/Motion.swift
  - App/DesignSystem/Components.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
  - App/Persistence/WorkoutLog.swift
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - SharedCore/Sources/SharedCore/WorkoutExport.swift
  - App/Health/HealthStore.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - App/Views/WorkoutLogDetailView.swift
  - App/Health/HealthProviding.swift
  - SharedCore/Sources/SharedCore/UserProfile.swift
  - Watch/IntervalEngine.swift
  - SharedCore/Sources/SharedCore/StreakCalculator.swift
  - WatchComplications/Localizable.xcstrings
  - App/Views/RecentWorkoutsSection.swift
  - App/DesignSystem/AccessibleControls.swift
  - Watch/WatchReadinessProvider.swift
  - Watch/WorkoutSync.swift
  - scripts/archive-and-export.sh
  - App/Assets.xcassets/AppIcon.appiconset/icon_1024.png
  - SharedCore/Sources/SharedCore/WorkoutTransfer.swift
  - SharedCore/Tests/SharedCoreTests/StreaksAchievementsTests.swift
  - SharedCore/Sources/SharedCore/Norwegian4x4.swift
  - App/Assets.xcassets/AccentColor.colorset/Contents.json
  - App/Sync/PhoneSessionReceiver.swift
  - App/Views/OnboardingView.swift
  - App/Z24x4TrainerApp.swift
  - App/Persistence/AchievementRecord.swift
  - Watch/Z24x4TrainerWatch.entitlements
  - App/Views/ManualEntryView.swift
  - docs/app-store/screenshots/03-week.png
  - SharedCore/Sources/SharedCore/TrainingLoad.swift
  - Tests/PhoneSessionReceiverTests.swift
  - App/Views/RootView.swift
-->

---
### Requirement: Synced workouts are not duplicated
The iPhone SHALL NOT create a second `WorkoutLog` for a Watch session it has already stored.

#### Scenario: Same session delivered twice
- **WHEN** the iPhone receives a session whose Health UUID matches an existing `WorkoutLog`
- **THEN** the iPhone SHALL skip insertion and leave the existing record unchanged


<!-- @trace
source: watch-phone-sync
updated: 2026-07-06
code:
  - SharedCore/Sources/SharedCore/TickClock.swift
  - Tests/WorkoutSourceTests.swift
  - SharedCore/Sources/SharedCore/GuidedCue.swift
  - SharedCore/Sources/SharedCore/HRZoneCalculator.swift
  - Watch/Assets.xcassets/AppIcon.appiconset/icon_1024.png
  - App/GuidedSessionEngine.swift
  - App/Views/GuidedPlayerView.swift
  - App/Views/ShareCard.swift
  - docs/app-store/screenshots/04-history.png
  - docs/app-store/screenshots/01-today.png
  - SharedCore/Tests/SharedCoreTests/UnitsExportTests.swift
  - docs/app-store/ExportOptions.plist
  - Widgets/Localizable.xcstrings
  - App/Health/HealthKitService.swift
  - App/Health/PreviewHealthService.swift
  - App/Views/HistoryView.swift
  - Watch/LiveWorkoutView.swift
  - App/Sync/LiveHRStore.swift
  - App/Views/SettingsView.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - PROGRESS.md
  - Tests/AppleZonesSeedTests.swift
  - App/WidgetSnapshotWriter.swift
  - WatchComplications/Z24x4WatchComplications.swift
  - App/Sync/PhoneStatusPublisher.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - Watch/WatchTheme.swift
  - Tests/GuidedPlayerLoggingTests.swift
  - SharedCore/Sources/SharedCore/IntervalRunner.swift
  - SharedCore/Tests/SharedCoreTests/Norwegian4x4Tests.swift
  - App/Persistence/DeletedWorkout.swift
  - App/GuidedSessionLogger.swift
  - Watch/WorkoutListView.swift
  - Watch/Assets.xcassets/Contents.json
  - SharedCore/Package.swift
  - Widgets/Info.plist
  - scripts/asc_jwt.py
  - App/Persistence/ProfileRecord.swift
  - Watch/WorkoutSessionManager.swift
  - SharedCore/Tests/SharedCoreTests/TrainingLoadTests.swift
  - App/Views/Celebration.swift
  - SharedCore/Sources/SharedCore/WorkoutRecord.swift
  - SharedCore/Sources/SharedCore/CoachingCue+UI.swift
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - SharedCore/Tests/SharedCoreTests/TickClockTests.swift
  - docs/privacy-policy.html
  - App/Views/AppleZonesView.swift
  - .github/workflows/release.yml
  - Widgets/Z24x4Widgets.swift
  - SharedCore/Sources/SharedCore/UnitConvert.swift
  - SharedCore/Tests/SharedCoreTests/PrecisionZonesTests.swift
  - SharedCore/Sources/SharedCore/MetricSample.swift
  - SharedCore/Tests/SharedCoreTests/IntervalRunnerTests.swift
  - App/Views/ProfileWatchSync.swift
  - docs/app-store/screenshots/05-settings.png
  - App/Views/OnboardingIntroView.swift
  - SharedCore/Tests/SharedCoreTests/GuidedCueTests.swift
  - CLAUDE.md
  - App/Views/TodayView.swift
  - Watch/Z24x4WatchApp.swift
  - WatchComplications/Info.plist
  - SharedCore/Sources/SharedCore/Localizable.xcstrings
  - App/Z24x4Trainer.entitlements
  - SharedCore/Sources/SharedCore/PlanProgression.swift
  - scripts/asc_push_metadata.py
  - .github/workflows/ci.yml
  - App/Views/WeekView.swift
  - App/DesignSystem/Theme.swift
  - docs/manual-verification-checklist.md
  - WatchComplications/Z24x4WatchComplications.entitlements
  - Widgets/Z24x4Widgets.entitlements
  - App/Views/WorkoutDetailView.swift
  - SharedCore/Tests/SharedCoreTests/Zone2TimeTrackerTests.swift
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
  - SharedCore/Sources/SharedCore/Readiness.swift
  - SharedCore/Tests/SharedCoreTests/WorkoutTransferTests.swift
  - docs/app-store/METADATA.md
  - Watch/Localizable.xcstrings
  - App/Notifications/ReminderScheduler.swift
  - App/Views/StreakBanner.swift
  - Watch/Assets.xcassets/AppIcon.appiconset/Contents.json
  - SharedCore/Sources/SharedCore/ZoneMethod.swift
  - docs/feature-proposals-2026-07-03.md
  - SharedCore/Tests/SharedCoreTests/ZoneLadderTests.swift
  - App/DesignSystem/Buttons.swift
  - Tests/HealthWritebackTests.swift
  - SharedCore/Sources/SharedCore/UnitPreference.swift
  - project.yml
  - App/Localizable.xcstrings
  - SharedCore/Sources/SharedCore/Zone2TimeTracker.swift
  - Tests/HealthImportSnapshotTests.swift
  - scripts/asc_upload_screenshots.py
  - SharedCore/Tests/SharedCoreTests/ReadinessExtendedSignalsTests.swift
  - SharedCore/Sources/SharedCore/ZoneLadder.swift
  - App/DesignSystem/Motion.swift
  - App/DesignSystem/Components.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
  - App/Persistence/WorkoutLog.swift
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - SharedCore/Sources/SharedCore/WorkoutExport.swift
  - App/Health/HealthStore.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - App/Views/WorkoutLogDetailView.swift
  - App/Health/HealthProviding.swift
  - SharedCore/Sources/SharedCore/UserProfile.swift
  - Watch/IntervalEngine.swift
  - SharedCore/Sources/SharedCore/StreakCalculator.swift
  - WatchComplications/Localizable.xcstrings
  - App/Views/RecentWorkoutsSection.swift
  - App/DesignSystem/AccessibleControls.swift
  - Watch/WatchReadinessProvider.swift
  - Watch/WorkoutSync.swift
  - scripts/archive-and-export.sh
  - App/Assets.xcassets/AppIcon.appiconset/icon_1024.png
  - SharedCore/Sources/SharedCore/WorkoutTransfer.swift
  - SharedCore/Tests/SharedCoreTests/StreaksAchievementsTests.swift
  - SharedCore/Sources/SharedCore/Norwegian4x4.swift
  - App/Assets.xcassets/AccentColor.colorset/Contents.json
  - App/Sync/PhoneSessionReceiver.swift
  - App/Views/OnboardingView.swift
  - App/Z24x4TrainerApp.swift
  - App/Persistence/AchievementRecord.swift
  - Watch/Z24x4TrainerWatch.entitlements
  - App/Views/ManualEntryView.swift
  - docs/app-store/screenshots/03-week.png
  - SharedCore/Sources/SharedCore/TrainingLoad.swift
  - Tests/PhoneSessionReceiverTests.swift
  - App/Views/RootView.swift
-->

---
### Requirement: Watch target compiles and runs
The `Z24x4TrainerWatch` target SHALL build for the watchOS simulator and run on a physical
Apple Watch, displaying live heart rate, current zone, and 4×4 interval cues.

#### Scenario: Watch build succeeds after SDK install
- **WHEN** the watchOS SDK is installed and the watch target is built
- **THEN** the build SHALL succeed with no errors

##### Example: clean watch build
- **GIVEN** `xcodebuild -downloadPlatform watchOS` has completed
- **WHEN** running `xcodebuild build -scheme Z24x4TrainerWatch -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)'`
- **THEN** the output contains `** BUILD SUCCEEDED **`

#### Scenario: Live session on hardware
- **WHEN** a Norwegian 4×4 session runs on a physical Apple Watch
- **THEN** the screen SHALL show the current heart rate and zone
- **AND** a haptic SHALL fire at each interval transition

<!-- @trace
source: watch-phone-sync
updated: 2026-07-06
code:
  - SharedCore/Sources/SharedCore/TickClock.swift
  - Tests/WorkoutSourceTests.swift
  - SharedCore/Sources/SharedCore/GuidedCue.swift
  - SharedCore/Sources/SharedCore/HRZoneCalculator.swift
  - Watch/Assets.xcassets/AppIcon.appiconset/icon_1024.png
  - App/GuidedSessionEngine.swift
  - App/Views/GuidedPlayerView.swift
  - App/Views/ShareCard.swift
  - docs/app-store/screenshots/04-history.png
  - docs/app-store/screenshots/01-today.png
  - SharedCore/Tests/SharedCoreTests/UnitsExportTests.swift
  - docs/app-store/ExportOptions.plist
  - Widgets/Localizable.xcstrings
  - App/Health/HealthKitService.swift
  - App/Health/PreviewHealthService.swift
  - App/Views/HistoryView.swift
  - Watch/LiveWorkoutView.swift
  - App/Sync/LiveHRStore.swift
  - App/Views/SettingsView.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - PROGRESS.md
  - Tests/AppleZonesSeedTests.swift
  - App/WidgetSnapshotWriter.swift
  - WatchComplications/Z24x4WatchComplications.swift
  - App/Sync/PhoneStatusPublisher.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - Watch/WatchTheme.swift
  - Tests/GuidedPlayerLoggingTests.swift
  - SharedCore/Sources/SharedCore/IntervalRunner.swift
  - SharedCore/Tests/SharedCoreTests/Norwegian4x4Tests.swift
  - App/Persistence/DeletedWorkout.swift
  - App/GuidedSessionLogger.swift
  - Watch/WorkoutListView.swift
  - Watch/Assets.xcassets/Contents.json
  - SharedCore/Package.swift
  - Widgets/Info.plist
  - scripts/asc_jwt.py
  - App/Persistence/ProfileRecord.swift
  - Watch/WorkoutSessionManager.swift
  - SharedCore/Tests/SharedCoreTests/TrainingLoadTests.swift
  - App/Views/Celebration.swift
  - SharedCore/Sources/SharedCore/WorkoutRecord.swift
  - SharedCore/Sources/SharedCore/CoachingCue+UI.swift
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - SharedCore/Tests/SharedCoreTests/TickClockTests.swift
  - docs/privacy-policy.html
  - App/Views/AppleZonesView.swift
  - .github/workflows/release.yml
  - Widgets/Z24x4Widgets.swift
  - SharedCore/Sources/SharedCore/UnitConvert.swift
  - SharedCore/Tests/SharedCoreTests/PrecisionZonesTests.swift
  - SharedCore/Sources/SharedCore/MetricSample.swift
  - SharedCore/Tests/SharedCoreTests/IntervalRunnerTests.swift
  - App/Views/ProfileWatchSync.swift
  - docs/app-store/screenshots/05-settings.png
  - App/Views/OnboardingIntroView.swift
  - SharedCore/Tests/SharedCoreTests/GuidedCueTests.swift
  - CLAUDE.md
  - App/Views/TodayView.swift
  - Watch/Z24x4WatchApp.swift
  - WatchComplications/Info.plist
  - SharedCore/Sources/SharedCore/Localizable.xcstrings
  - App/Z24x4Trainer.entitlements
  - SharedCore/Sources/SharedCore/PlanProgression.swift
  - scripts/asc_push_metadata.py
  - .github/workflows/ci.yml
  - App/Views/WeekView.swift
  - App/DesignSystem/Theme.swift
  - docs/manual-verification-checklist.md
  - WatchComplications/Z24x4WatchComplications.entitlements
  - Widgets/Z24x4Widgets.entitlements
  - App/Views/WorkoutDetailView.swift
  - SharedCore/Tests/SharedCoreTests/Zone2TimeTrackerTests.swift
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
  - SharedCore/Sources/SharedCore/Readiness.swift
  - SharedCore/Tests/SharedCoreTests/WorkoutTransferTests.swift
  - docs/app-store/METADATA.md
  - Watch/Localizable.xcstrings
  - App/Notifications/ReminderScheduler.swift
  - App/Views/StreakBanner.swift
  - Watch/Assets.xcassets/AppIcon.appiconset/Contents.json
  - SharedCore/Sources/SharedCore/ZoneMethod.swift
  - docs/feature-proposals-2026-07-03.md
  - SharedCore/Tests/SharedCoreTests/ZoneLadderTests.swift
  - App/DesignSystem/Buttons.swift
  - Tests/HealthWritebackTests.swift
  - SharedCore/Sources/SharedCore/UnitPreference.swift
  - project.yml
  - App/Localizable.xcstrings
  - SharedCore/Sources/SharedCore/Zone2TimeTracker.swift
  - Tests/HealthImportSnapshotTests.swift
  - scripts/asc_upload_screenshots.py
  - SharedCore/Tests/SharedCoreTests/ReadinessExtendedSignalsTests.swift
  - SharedCore/Sources/SharedCore/ZoneLadder.swift
  - App/DesignSystem/Motion.swift
  - App/DesignSystem/Components.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
  - App/Persistence/WorkoutLog.swift
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - SharedCore/Sources/SharedCore/WorkoutExport.swift
  - App/Health/HealthStore.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - App/Views/WorkoutLogDetailView.swift
  - App/Health/HealthProviding.swift
  - SharedCore/Sources/SharedCore/UserProfile.swift
  - Watch/IntervalEngine.swift
  - SharedCore/Sources/SharedCore/StreakCalculator.swift
  - WatchComplications/Localizable.xcstrings
  - App/Views/RecentWorkoutsSection.swift
  - App/DesignSystem/AccessibleControls.swift
  - Watch/WatchReadinessProvider.swift
  - Watch/WorkoutSync.swift
  - scripts/archive-and-export.sh
  - App/Assets.xcassets/AppIcon.appiconset/icon_1024.png
  - SharedCore/Sources/SharedCore/WorkoutTransfer.swift
  - SharedCore/Tests/SharedCoreTests/StreaksAchievementsTests.swift
  - SharedCore/Sources/SharedCore/Norwegian4x4.swift
  - App/Assets.xcassets/AccentColor.colorset/Contents.json
  - App/Sync/PhoneSessionReceiver.swift
  - App/Views/OnboardingView.swift
  - App/Z24x4TrainerApp.swift
  - App/Persistence/AchievementRecord.swift
  - Watch/Z24x4TrainerWatch.entitlements
  - App/Views/ManualEntryView.swift
  - docs/app-store/screenshots/03-week.png
  - SharedCore/Sources/SharedCore/TrainingLoad.swift
  - Tests/PhoneSessionReceiverTests.swift
  - App/Views/RootView.swift
-->