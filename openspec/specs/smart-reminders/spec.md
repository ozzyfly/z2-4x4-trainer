# smart-reminders Specification

## Purpose

TBD - created by archiving change 'smart-reminders'. Update Purpose after archive.

## Requirements

### Requirement: Opt-in training reminders
The app SHALL schedule local notifications for plan training days only when the user has enabled
reminders, and SHALL remove them when disabled.

#### Scenario: Enabling schedules plan-day reminders
- **WHEN** the user enables reminders and grants notification permission
- **THEN** a local notification is scheduled for each non-rest day in the weekly plan at the chosen time

#### Scenario: Disabling clears them
- **WHEN** the user disables reminders
- **THEN** all the app's pending reminder notifications are cancelled


<!-- @trace
source: smart-reminders
updated: 2026-06-10
code:
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - App/DesignSystem/ZoneStyle.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - PROGRESS.md
  - Watch/WorkoutListView.swift
  - App/Persistence/AchievementRecord.swift
  - App/Views/HistoryView.swift
  - SharedCore/Tests/SharedCoreTests/GuidedCueTests.swift
  - Watch/LiveWorkoutView.swift
  - SharedCore/Tests/SharedCoreTests/PrecisionZonesTests.swift
  - App/DesignSystem/Buttons.swift
  - App/DesignSystem/Theme.swift
  - App/Views/AchievementsView.swift
  - App/Views/RootView.swift
  - SharedCore/Sources/SharedCore/MetricSample.swift
  - App/Health/HealthKitService.swift
  - SharedCore/Sources/SharedCore/PlanProgression.swift
  - SharedCore/Sources/SharedCore/WorkoutRecord.swift
  - Widgets/Z24x4Widgets.entitlements
  - Widgets/Z24x4Widgets.swift
  - SharedCore/Sources/SharedCore/GuidedCue.swift
  - SharedCore/Sources/SharedCore/ZoneMethod.swift
  - project.yml
  - WatchComplications/Z24x4WatchComplications.swift
  - App/Views/ManualEntryView.swift
  - App/Views/ShareCard.swift
  - App/Health/PreviewHealthService.swift
  - App/WidgetSnapshotWriter.swift
  - App/Views/Celebration.swift
  - App/DesignSystem/Components.swift
  - SharedCore/Sources/SharedCore/UserProfile.swift
  - App/Sync/PhoneSessionReceiver.swift
  - App/Views/GuidedPlayerView.swift
  - Watch/IntervalEngine.swift
  - App/Notifications/ReminderScheduler.swift
  - App/Localizable.xcstrings
  - App/Persistence/ProfileRecord.swift
  - SharedCore/Sources/SharedCore/Localizable.xcstrings
  - WatchComplications/Info.plist
  - App/Views/WorkoutDetailView.swift
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
  - SharedCore/Tests/SharedCoreTests/StreaksAchievementsTests.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - CLAUDE.md
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - SharedCore/Sources/SharedCore/AchievementEvaluator.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
  - SharedCore/Package.swift
  - SharedCore/Sources/SharedCore/HRZoneCalculator.swift
  - App/Views/StreakBanner.swift
  - App/Health/HealthStore.swift
  - SharedCore/Sources/SharedCore/StreakCalculator.swift
  - App/Views/SettingsView.swift
  - App/Views/WeekView.swift
  - SharedCore/Sources/SharedCore/Achievement.swift
  - App/Z24x4Trainer.entitlements
  - Widgets/Info.plist
  - App/DesignSystem/AccessibleControls.swift
  - App/Views/OnboardingView.swift
  - App/Views/TodayView.swift
  - App/Z24x4TrainerApp.swift
  - Watch/WorkoutSessionManager.swift
  - App/Health/HealthProviding.swift
  - App/DesignSystem/Motion.swift
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - App/GuidedSessionEngine.swift
  - SharedCore/Sources/SharedCore/Readiness.swift
-->

---
### Requirement: Permission respected
The app SHALL request notification authorization before scheduling and SHALL not schedule if denied.

#### Scenario: Denied permission
- **WHEN** notification permission is denied
- **THEN** no notifications are scheduled and the UI reflects the disabled state

<!-- @trace
source: smart-reminders
updated: 2026-06-10
code:
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - App/DesignSystem/ZoneStyle.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - PROGRESS.md
  - Watch/WorkoutListView.swift
  - App/Persistence/AchievementRecord.swift
  - App/Views/HistoryView.swift
  - SharedCore/Tests/SharedCoreTests/GuidedCueTests.swift
  - Watch/LiveWorkoutView.swift
  - SharedCore/Tests/SharedCoreTests/PrecisionZonesTests.swift
  - App/DesignSystem/Buttons.swift
  - App/DesignSystem/Theme.swift
  - App/Views/AchievementsView.swift
  - App/Views/RootView.swift
  - SharedCore/Sources/SharedCore/MetricSample.swift
  - App/Health/HealthKitService.swift
  - SharedCore/Sources/SharedCore/PlanProgression.swift
  - SharedCore/Sources/SharedCore/WorkoutRecord.swift
  - Widgets/Z24x4Widgets.entitlements
  - Widgets/Z24x4Widgets.swift
  - SharedCore/Sources/SharedCore/GuidedCue.swift
  - SharedCore/Sources/SharedCore/ZoneMethod.swift
  - project.yml
  - WatchComplications/Z24x4WatchComplications.swift
  - App/Views/ManualEntryView.swift
  - App/Views/ShareCard.swift
  - App/Health/PreviewHealthService.swift
  - App/WidgetSnapshotWriter.swift
  - App/Views/Celebration.swift
  - App/DesignSystem/Components.swift
  - SharedCore/Sources/SharedCore/UserProfile.swift
  - App/Sync/PhoneSessionReceiver.swift
  - App/Views/GuidedPlayerView.swift
  - Watch/IntervalEngine.swift
  - App/Notifications/ReminderScheduler.swift
  - App/Localizable.xcstrings
  - App/Persistence/ProfileRecord.swift
  - SharedCore/Sources/SharedCore/Localizable.xcstrings
  - WatchComplications/Info.plist
  - App/Views/WorkoutDetailView.swift
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
  - SharedCore/Tests/SharedCoreTests/StreaksAchievementsTests.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - CLAUDE.md
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - SharedCore/Sources/SharedCore/AchievementEvaluator.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
  - SharedCore/Package.swift
  - SharedCore/Sources/SharedCore/HRZoneCalculator.swift
  - App/Views/StreakBanner.swift
  - App/Health/HealthStore.swift
  - SharedCore/Sources/SharedCore/StreakCalculator.swift
  - App/Views/SettingsView.swift
  - App/Views/WeekView.swift
  - SharedCore/Sources/SharedCore/Achievement.swift
  - App/Z24x4Trainer.entitlements
  - Widgets/Info.plist
  - App/DesignSystem/AccessibleControls.swift
  - App/Views/OnboardingView.swift
  - App/Views/TodayView.swift
  - App/Z24x4TrainerApp.swift
  - Watch/WorkoutSessionManager.swift
  - App/Health/HealthProviding.swift
  - App/DesignSystem/Motion.swift
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - App/GuidedSessionEngine.swift
  - SharedCore/Sources/SharedCore/Readiness.swift
-->