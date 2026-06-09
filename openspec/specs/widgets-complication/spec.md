# widgets-complication Specification

## Purpose

TBD - created by archiving change 'widgets-complication'. Update Purpose after archive.

## Requirements

### Requirement: Shared widget snapshot
The app SHALL publish a snapshot of the current training state (today's planned session, this week's done/target training minutes, this week's done/target hard sessions) to a shared App Group container, encoded as a codec-stable format that widgets can read without launching the app.

#### Scenario: Snapshot round-trips
- **WHEN** a `WidgetSnapshot` is encoded and then decoded
- **THEN** the decoded value equals the original

#### Scenario: Snapshot updates after logging
- **WHEN** the user logs a workout
- **THEN** the published snapshot reflects the new weekly done minutes and the widgets are asked to reload

#### Scenario: Missing container is safe
- **WHEN** no snapshot has been written (or the App Group container is unavailable)
- **THEN** reading returns no snapshot and widgets render their placeholder without crashing


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
The watch SHALL provide a complication showing the next non-rest planned session.

#### Scenario: Complication shows next session
- **WHEN** the watch complication is rendered
- **THEN** the circular family shows the session glyph and the corner family shows the session type and duration of the next non-rest session

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