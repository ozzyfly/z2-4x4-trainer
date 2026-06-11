# widgets-complication Specification

## Purpose

TBD - created by archiving change 'widgets-complication'. Update Purpose after archive.

## Requirements

### Requirement: Shared widget snapshot
The app SHALL publish a snapshot of the current training state (today's planned session, this week's done/target training minutes, this week's done/target hard sessions, and — when available — the readiness score with its label and the current streak weeks) to a shared App Group container, encoded as a codec-stable format that widgets can read without launching the app. The readiness and streak fields SHALL be optional so that snapshots persisted by earlier app versions still decode.

#### Scenario: Snapshot round-trips
- **WHEN** a `WidgetSnapshot` including readiness and streak fields is encoded and then decoded
- **THEN** the decoded value equals the original

#### Scenario: Legacy snapshot still decodes
- **WHEN** a snapshot JSON produced before the readiness/streak fields existed is decoded
- **THEN** decoding succeeds and the new fields are nil

#### Scenario: Snapshot updates after logging
- **WHEN** the user logs a workout
- **THEN** the published snapshot reflects the new weekly done minutes and streak, and the widgets are asked to reload

#### Scenario: Missing container is safe
- **WHEN** no snapshot has been written (or the App Group container is unavailable)
- **THEN** reading returns no snapshot and widgets render their placeholder without crashing


<!-- @trace
source: watch-parity-widgets
updated: 2026-06-10
code:
  - SharedCore/Sources/SharedCore/Readiness.swift
  - SharedCore/Sources/SharedCore/UnitConvert.swift
  - App/WidgetSnapshotWriter.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - Watch/WorkoutListView.swift
  - App/GuidedSessionEngine.swift
  - App/Views/SettingsView.swift
  - Watch/WorkoutSync.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - App/Sync/PhoneStatusPublisher.swift
  - App/Views/RootView.swift
  - SharedCore/Sources/SharedCore/WorkoutExport.swift
  - App/Health/PreviewHealthService.swift
  - PROGRESS.md
  - Tests/HealthWritebackTests.swift
  - App/Health/HealthProviding.swift
  - App/Notifications/ReminderScheduler.swift
  - App/Health/HealthKitService.swift
  - App/Views/GuidedPlayerView.swift
  - App/Views/ManualEntryView.swift
  - project.yml
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - WatchComplications/Z24x4WatchComplications.entitlements
  - Watch/Z24x4TrainerWatch.entitlements
  - SharedCore/Tests/SharedCoreTests/UnitsExportTests.swift
  - SharedCore/Sources/SharedCore/UnitPreference.swift
  - Widgets/Z24x4Widgets.swift
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
  - WatchComplications/Z24x4WatchComplications.swift
-->

---
### Requirement: Home and Lock widgets
The iOS app SHALL provide widgets showing today's planned session and this week's training-minutes progress, in Home-screen (small and medium) and Lock-screen (rectangular and circular) families.

#### Scenario: Small widget shows today's session
- **WHEN** the small Home widget is shown with a snapshot whose today session is Zone 2, 40 minutes
- **THEN** it displays the session type and duration (or "Rest" on a rest day)

#### Scenario: Medium widget shows weekly progress
- **WHEN** the medium Home widget is shown
- **THEN** it displays today's session and the week's done/target training minutes

#### Scenario: Lock widgets show glanceable state
- **WHEN** a Lock-screen widget is shown
- **THEN** the circular family shows the weekly progress and the rectangular family shows today's session


<!-- @trace
source: widgets-complication
updated: 2026-06-09
code:
  - App/Views/RootView.swift
  - App/Views/Celebration.swift
  - SharedCore/Tests/SharedCoreTests/StreaksAchievementsTests.swift
  - App/Views/ManualEntryView.swift
  - App/Views/TodayView.swift
  - Watch/LiveWorkoutView.swift
  - SharedCore/Sources/SharedCore/ZoneMethod.swift
  - PROGRESS.md
  - App/Views/WeekView.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - SharedCore/Sources/SharedCore/WorkoutRecord.swift
  - App/Views/OnboardingView.swift
  - App/Views/StreakBanner.swift
  - SharedCore/Tests/SharedCoreTests/PrecisionZonesTests.swift
  - App/Sync/PhoneSessionReceiver.swift
  - SharedCore/Sources/SharedCore/MetricSample.swift
  - SharedCore/Sources/SharedCore/AchievementEvaluator.swift
  - Watch/WorkoutListView.swift
  - App/Views/AchievementsView.swift
  - App/Persistence/ProfileRecord.swift
  - SharedCore/Sources/SharedCore/StreakCalculator.swift
  - App/Views/WorkoutDetailView.swift
  - Widgets/Z24x4Widgets.entitlements
  - App/DesignSystem/Components.swift
  - App/DesignSystem/Buttons.swift
  - SharedCore/Sources/SharedCore/UserProfile.swift
  - SharedCore/Sources/SharedCore/Readiness.swift
  - WatchComplications/Info.plist
  - App/Notifications/ReminderScheduler.swift
  - App/Health/HealthProviding.swift
  - Widgets/Z24x4Widgets.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - App/Views/SettingsView.swift
  - App/DesignSystem/Motion.swift
  - App/Health/HealthStore.swift
  - Widgets/Info.plist
  - App/DesignSystem/AccessibleControls.swift
  - App/Z24x4TrainerApp.swift
  - App/DesignSystem/Theme.swift
  - App/WidgetSnapshotWriter.swift
  - App/Views/HistoryView.swift
  - App/DesignSystem/ZoneStyle.swift
  - App/Views/ShareCard.swift
  - SharedCore/Sources/SharedCore/PlanProgression.swift
  - App/Persistence/AchievementRecord.swift
  - project.yml
  - SharedCore/Sources/SharedCore/HRZoneCalculator.swift
  - WatchComplications/Z24x4WatchComplications.swift
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - SharedCore/Sources/SharedCore/Achievement.swift
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
  - App/Health/PreviewHealthService.swift
  - Watch/WorkoutSessionManager.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - App/Health/HealthKitService.swift
  - App/Z24x4Trainer.entitlements
-->

---
### Requirement: Widget tap opens the app
Tapping any iOS widget SHALL open the app on the Today screen.

#### Scenario: Tap deep-links to Today
- **WHEN** the user taps a Home or Lock widget
- **THEN** the app opens and shows the Today tab


<!-- @trace
source: widgets-complication
updated: 2026-06-09
code:
  - App/Views/RootView.swift
  - App/Views/Celebration.swift
  - SharedCore/Tests/SharedCoreTests/StreaksAchievementsTests.swift
  - App/Views/ManualEntryView.swift
  - App/Views/TodayView.swift
  - Watch/LiveWorkoutView.swift
  - SharedCore/Sources/SharedCore/ZoneMethod.swift
  - PROGRESS.md
  - App/Views/WeekView.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - SharedCore/Sources/SharedCore/WorkoutRecord.swift
  - App/Views/OnboardingView.swift
  - App/Views/StreakBanner.swift
  - SharedCore/Tests/SharedCoreTests/PrecisionZonesTests.swift
  - App/Sync/PhoneSessionReceiver.swift
  - SharedCore/Sources/SharedCore/MetricSample.swift
  - SharedCore/Sources/SharedCore/AchievementEvaluator.swift
  - Watch/WorkoutListView.swift
  - App/Views/AchievementsView.swift
  - App/Persistence/ProfileRecord.swift
  - SharedCore/Sources/SharedCore/StreakCalculator.swift
  - App/Views/WorkoutDetailView.swift
  - Widgets/Z24x4Widgets.entitlements
  - App/DesignSystem/Components.swift
  - App/DesignSystem/Buttons.swift
  - SharedCore/Sources/SharedCore/UserProfile.swift
  - SharedCore/Sources/SharedCore/Readiness.swift
  - WatchComplications/Info.plist
  - App/Notifications/ReminderScheduler.swift
  - App/Health/HealthProviding.swift
  - Widgets/Z24x4Widgets.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - App/Views/SettingsView.swift
  - App/DesignSystem/Motion.swift
  - App/Health/HealthStore.swift
  - Widgets/Info.plist
  - App/DesignSystem/AccessibleControls.swift
  - App/Z24x4TrainerApp.swift
  - App/DesignSystem/Theme.swift
  - App/WidgetSnapshotWriter.swift
  - App/Views/HistoryView.swift
  - App/DesignSystem/ZoneStyle.swift
  - App/Views/ShareCard.swift
  - SharedCore/Sources/SharedCore/PlanProgression.swift
  - App/Persistence/AchievementRecord.swift
  - project.yml
  - SharedCore/Sources/SharedCore/HRZoneCalculator.swift
  - WatchComplications/Z24x4WatchComplications.swift
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - SharedCore/Sources/SharedCore/Achievement.swift
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
  - App/Health/PreviewHealthService.swift
  - Watch/WorkoutSessionManager.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - App/Health/HealthKitService.swift
  - App/Z24x4Trainer.entitlements
-->

---
### Requirement: Watch complication shows next session
The watch SHALL provide complications for the next non-rest planned session, the readiness score, and the current streak. The next-session complication SHALL prefer the cached snapshot and SHALL fall back to the locally computed plan when no snapshot is cached. Readiness and streak complications SHALL render placeholders when their fields are absent.

#### Scenario: Complication shows next session
- **WHEN** the watch complication is rendered
- **THEN** the circular family shows the session glyph and the corner family shows the session type and duration of the next non-rest session

#### Scenario: Next session prefers snapshot
- **WHEN** a cached snapshot exists with a today session
- **THEN** the next-session complication displays the snapshot's session rather than the locally computed default

#### Scenario: Readiness and streak complications render
- **WHEN** the cached snapshot contains readinessValue 80 and streakWeeks 3
- **THEN** the readiness complication shows 80 and the streak complication shows 3 weeks


<!-- @trace
source: watch-parity-widgets
updated: 2026-06-10
code:
  - SharedCore/Sources/SharedCore/Readiness.swift
  - SharedCore/Sources/SharedCore/UnitConvert.swift
  - App/WidgetSnapshotWriter.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - Watch/WorkoutListView.swift
  - App/GuidedSessionEngine.swift
  - App/Views/SettingsView.swift
  - Watch/WorkoutSync.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - App/Sync/PhoneStatusPublisher.swift
  - App/Views/RootView.swift
  - SharedCore/Sources/SharedCore/WorkoutExport.swift
  - App/Health/PreviewHealthService.swift
  - PROGRESS.md
  - Tests/HealthWritebackTests.swift
  - App/Health/HealthProviding.swift
  - App/Notifications/ReminderScheduler.swift
  - App/Health/HealthKitService.swift
  - App/Views/GuidedPlayerView.swift
  - App/Views/ManualEntryView.swift
  - project.yml
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - WatchComplications/Z24x4WatchComplications.entitlements
  - Watch/Z24x4TrainerWatch.entitlements
  - SharedCore/Tests/SharedCoreTests/UnitsExportTests.swift
  - SharedCore/Sources/SharedCore/UnitPreference.swift
  - Widgets/Z24x4Widgets.swift
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
  - WatchComplications/Z24x4WatchComplications.swift
-->

---
### Requirement: Streak and readiness widgets
The iOS app SHALL provide a streak widget and a readiness widget in addition to the today widget. The streak widget SHALL show the current weekly streak in weeks; the readiness widget SHALL show the readiness score and its label. Both SHALL render a placeholder when the snapshot lacks the corresponding optional field.

#### Scenario: Streak widget shows weeks
- **WHEN** the streak widget is shown with a snapshot whose streakWeeks is 2
- **THEN** it displays a 2-week streak

#### Scenario: Readiness widget shows score
- **WHEN** the readiness widget is shown with a snapshot whose readinessValue is 100 and label is goHard
- **THEN** it displays the score 100 and the label text

#### Scenario: Missing fields render placeholder
- **WHEN** a streak or readiness widget reads a snapshot without the corresponding optional field
- **THEN** it renders a neutral placeholder without crashing


<!-- @trace
source: watch-parity-widgets
updated: 2026-06-10
code:
  - SharedCore/Sources/SharedCore/Readiness.swift
  - SharedCore/Sources/SharedCore/UnitConvert.swift
  - App/WidgetSnapshotWriter.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - Watch/WorkoutListView.swift
  - App/GuidedSessionEngine.swift
  - App/Views/SettingsView.swift
  - Watch/WorkoutSync.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - App/Sync/PhoneStatusPublisher.swift
  - App/Views/RootView.swift
  - SharedCore/Sources/SharedCore/WorkoutExport.swift
  - App/Health/PreviewHealthService.swift
  - PROGRESS.md
  - Tests/HealthWritebackTests.swift
  - App/Health/HealthProviding.swift
  - App/Notifications/ReminderScheduler.swift
  - App/Health/HealthKitService.swift
  - App/Views/GuidedPlayerView.swift
  - App/Views/ManualEntryView.swift
  - project.yml
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - WatchComplications/Z24x4WatchComplications.entitlements
  - Watch/Z24x4TrainerWatch.entitlements
  - SharedCore/Tests/SharedCoreTests/UnitsExportTests.swift
  - SharedCore/Sources/SharedCore/UnitPreference.swift
  - Widgets/Z24x4Widgets.swift
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
  - WatchComplications/Z24x4WatchComplications.swift
-->

---
### Requirement: Phone publishes snapshot to watch
The iPhone app SHALL push the current widget snapshot to the paired watch via WatchConnectivity application context after every snapshot write, and the watch app SHALL cache the received snapshot in its own App Group container so the watch app and its complications can read it while the phone is unreachable.

#### Scenario: Snapshot pushed after logging
- **WHEN** the user logs a workout on the phone and the WCSession is activated
- **THEN** the updated snapshot is sent via application context

#### Scenario: Watch caches received snapshot
- **WHEN** the watch receives an application context containing a snapshot
- **THEN** it writes the snapshot to the watch App Group container and reloads its complication timelines

#### Scenario: No snapshot received yet
- **WHEN** the watch has never received a snapshot
- **THEN** the watch app and complications render placeholders without crashing

<!-- @trace
source: watch-parity-widgets
updated: 2026-06-10
code:
  - SharedCore/Sources/SharedCore/Readiness.swift
  - SharedCore/Sources/SharedCore/UnitConvert.swift
  - App/WidgetSnapshotWriter.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - Watch/WorkoutListView.swift
  - App/GuidedSessionEngine.swift
  - App/Views/SettingsView.swift
  - Watch/WorkoutSync.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - App/Sync/PhoneStatusPublisher.swift
  - App/Views/RootView.swift
  - SharedCore/Sources/SharedCore/WorkoutExport.swift
  - App/Health/PreviewHealthService.swift
  - PROGRESS.md
  - Tests/HealthWritebackTests.swift
  - App/Health/HealthProviding.swift
  - App/Notifications/ReminderScheduler.swift
  - App/Health/HealthKitService.swift
  - App/Views/GuidedPlayerView.swift
  - App/Views/ManualEntryView.swift
  - project.yml
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - WatchComplications/Z24x4WatchComplications.entitlements
  - Watch/Z24x4TrainerWatch.entitlements
  - SharedCore/Tests/SharedCoreTests/UnitsExportTests.swift
  - SharedCore/Sources/SharedCore/UnitPreference.swift
  - Widgets/Z24x4Widgets.swift
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
  - WatchComplications/Z24x4WatchComplications.swift
-->