# streaks-achievements Specification

## Purpose

TBD - created by archiving change 'streaks-achievements'. Update Purpose after archive.

## Requirements

### Requirement: Training streaks
The app SHALL compute the current and longest streak of training weeks from history, where a week
counts when at least one workout is logged.

#### Scenario: Current streak counts consecutive trained weeks
- **WHEN** the athlete logged a workout each of the last 3 weeks and none the week before
- **THEN** the current streak is 3 weeks and the longest streak is at least 3

#### Scenario: A gap breaks the streak
- **WHEN** the most recent week has no workout
- **THEN** the current streak is 0


<!-- @trace
source: streaks-achievements
updated: 2026-06-10
code:
  - SharedCore/Sources/SharedCore/ZoneMethod.swift
  - App/Health/HealthKitService.swift
  - SharedCore/Sources/SharedCore/Achievement.swift
  - SharedCore/Sources/SharedCore/HRZoneCalculator.swift
  - Watch/WorkoutListView.swift
  - SharedCore/Sources/SharedCore/MetricSample.swift
  - App/Health/HealthStore.swift
  - App/Localizable.xcstrings
  - SharedCore/Sources/SharedCore/GuidedCue.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - App/Z24x4Trainer.entitlements
  - SharedCore/Sources/SharedCore/Localizable.xcstrings
  - App/Views/SettingsView.swift
  - App/Views/OnboardingView.swift
  - App/DesignSystem/AccessibleControls.swift
  - Widgets/Z24x4Widgets.entitlements
  - App/Persistence/AchievementRecord.swift
  - Watch/LiveWorkoutView.swift
  - SharedCore/Tests/SharedCoreTests/GuidedCueTests.swift
  - SharedCore/Sources/SharedCore/UserProfile.swift
  - Widgets/Info.plist
  - SharedCore/Sources/SharedCore/AchievementEvaluator.swift
  - App/DesignSystem/Theme.swift
  - App/Views/WorkoutDetailView.swift
  - Watch/WorkoutSessionManager.swift
  - App/Health/HealthProviding.swift
  - App/Views/HistoryView.swift
  - SharedCore/Sources/SharedCore/PlanProgression.swift
  - App/Views/StreakBanner.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - App/Health/PreviewHealthService.swift
  - App/GuidedSessionEngine.swift
  - App/DesignSystem/ZoneStyle.swift
  - App/Views/AchievementsView.swift
  - SharedCore/Tests/SharedCoreTests/PrecisionZonesTests.swift
  - App/Persistence/ProfileRecord.swift
  - SharedCore/Sources/SharedCore/Readiness.swift
  - Watch/IntervalEngine.swift
  - App/DesignSystem/Components.swift
  - App/Views/Celebration.swift
  - App/Sync/PhoneSessionReceiver.swift
  - SharedCore/Package.swift
  - SharedCore/Sources/SharedCore/StreakCalculator.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
  - App/Views/RootView.swift
  - App/DesignSystem/Motion.swift
  - PROGRESS.md
  - App/Notifications/ReminderScheduler.swift
  - Widgets/Z24x4Widgets.swift
  - App/Views/TodayView.swift
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - App/Views/GuidedPlayerView.swift
  - App/Views/ShareCard.swift
  - WatchComplications/Info.plist
  - App/WidgetSnapshotWriter.swift
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - App/Views/ManualEntryView.swift
  - App/DesignSystem/Buttons.swift
  - App/Views/WeekView.swift
  - WatchComplications/Z24x4WatchComplications.swift
  - CLAUDE.md
  - SharedCore/Sources/SharedCore/WorkoutRecord.swift
  - SharedCore/Tests/SharedCoreTests/StreaksAchievementsTests.swift
  - App/Z24x4TrainerApp.swift
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - project.yml
-->

---
### Requirement: Achievement catalog
The app SHALL evaluate a fixed catalog of achievements against history and report which are unlocked.

#### Scenario: First 4×4 unlocks
- **WHEN** the history contains at least one Norwegian 4×4 workout
- **THEN** the "First 4×4" achievement is unlocked

#### Scenario: Locked when unmet
- **WHEN** the history has fewer than 10 workouts
- **THEN** the "10 sessions" achievement is locked


<!-- @trace
source: streaks-achievements
updated: 2026-06-10
code:
  - SharedCore/Sources/SharedCore/ZoneMethod.swift
  - App/Health/HealthKitService.swift
  - SharedCore/Sources/SharedCore/Achievement.swift
  - SharedCore/Sources/SharedCore/HRZoneCalculator.swift
  - Watch/WorkoutListView.swift
  - SharedCore/Sources/SharedCore/MetricSample.swift
  - App/Health/HealthStore.swift
  - App/Localizable.xcstrings
  - SharedCore/Sources/SharedCore/GuidedCue.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - App/Z24x4Trainer.entitlements
  - SharedCore/Sources/SharedCore/Localizable.xcstrings
  - App/Views/SettingsView.swift
  - App/Views/OnboardingView.swift
  - App/DesignSystem/AccessibleControls.swift
  - Widgets/Z24x4Widgets.entitlements
  - App/Persistence/AchievementRecord.swift
  - Watch/LiveWorkoutView.swift
  - SharedCore/Tests/SharedCoreTests/GuidedCueTests.swift
  - SharedCore/Sources/SharedCore/UserProfile.swift
  - Widgets/Info.plist
  - SharedCore/Sources/SharedCore/AchievementEvaluator.swift
  - App/DesignSystem/Theme.swift
  - App/Views/WorkoutDetailView.swift
  - Watch/WorkoutSessionManager.swift
  - App/Health/HealthProviding.swift
  - App/Views/HistoryView.swift
  - SharedCore/Sources/SharedCore/PlanProgression.swift
  - App/Views/StreakBanner.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - App/Health/PreviewHealthService.swift
  - App/GuidedSessionEngine.swift
  - App/DesignSystem/ZoneStyle.swift
  - App/Views/AchievementsView.swift
  - SharedCore/Tests/SharedCoreTests/PrecisionZonesTests.swift
  - App/Persistence/ProfileRecord.swift
  - SharedCore/Sources/SharedCore/Readiness.swift
  - Watch/IntervalEngine.swift
  - App/DesignSystem/Components.swift
  - App/Views/Celebration.swift
  - App/Sync/PhoneSessionReceiver.swift
  - SharedCore/Package.swift
  - SharedCore/Sources/SharedCore/StreakCalculator.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
  - App/Views/RootView.swift
  - App/DesignSystem/Motion.swift
  - PROGRESS.md
  - App/Notifications/ReminderScheduler.swift
  - Widgets/Z24x4Widgets.swift
  - App/Views/TodayView.swift
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - App/Views/GuidedPlayerView.swift
  - App/Views/ShareCard.swift
  - WatchComplications/Info.plist
  - App/WidgetSnapshotWriter.swift
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - App/Views/ManualEntryView.swift
  - App/DesignSystem/Buttons.swift
  - App/Views/WeekView.swift
  - WatchComplications/Z24x4WatchComplications.swift
  - CLAUDE.md
  - SharedCore/Sources/SharedCore/WorkoutRecord.swift
  - SharedCore/Tests/SharedCoreTests/StreaksAchievementsTests.swift
  - App/Z24x4TrainerApp.swift
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - project.yml
-->

---
### Requirement: Celebration on unlock
The app SHALL show a celebration (visual + haptic) when an achievement unlocks or the day's target is met.

#### Scenario: Celebrate a new unlock
- **WHEN** an achievement transitions from locked to unlocked
- **THEN** a celebration overlay appears and a success haptic fires once

<!-- @trace
source: streaks-achievements
updated: 2026-06-10
code:
  - SharedCore/Sources/SharedCore/ZoneMethod.swift
  - App/Health/HealthKitService.swift
  - SharedCore/Sources/SharedCore/Achievement.swift
  - SharedCore/Sources/SharedCore/HRZoneCalculator.swift
  - Watch/WorkoutListView.swift
  - SharedCore/Sources/SharedCore/MetricSample.swift
  - App/Health/HealthStore.swift
  - App/Localizable.xcstrings
  - SharedCore/Sources/SharedCore/GuidedCue.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - App/Z24x4Trainer.entitlements
  - SharedCore/Sources/SharedCore/Localizable.xcstrings
  - App/Views/SettingsView.swift
  - App/Views/OnboardingView.swift
  - App/DesignSystem/AccessibleControls.swift
  - Widgets/Z24x4Widgets.entitlements
  - App/Persistence/AchievementRecord.swift
  - Watch/LiveWorkoutView.swift
  - SharedCore/Tests/SharedCoreTests/GuidedCueTests.swift
  - SharedCore/Sources/SharedCore/UserProfile.swift
  - Widgets/Info.plist
  - SharedCore/Sources/SharedCore/AchievementEvaluator.swift
  - App/DesignSystem/Theme.swift
  - App/Views/WorkoutDetailView.swift
  - Watch/WorkoutSessionManager.swift
  - App/Health/HealthProviding.swift
  - App/Views/HistoryView.swift
  - SharedCore/Sources/SharedCore/PlanProgression.swift
  - App/Views/StreakBanner.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - App/Health/PreviewHealthService.swift
  - App/GuidedSessionEngine.swift
  - App/DesignSystem/ZoneStyle.swift
  - App/Views/AchievementsView.swift
  - SharedCore/Tests/SharedCoreTests/PrecisionZonesTests.swift
  - App/Persistence/ProfileRecord.swift
  - SharedCore/Sources/SharedCore/Readiness.swift
  - Watch/IntervalEngine.swift
  - App/DesignSystem/Components.swift
  - App/Views/Celebration.swift
  - App/Sync/PhoneSessionReceiver.swift
  - SharedCore/Package.swift
  - SharedCore/Sources/SharedCore/StreakCalculator.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
  - App/Views/RootView.swift
  - App/DesignSystem/Motion.swift
  - PROGRESS.md
  - App/Notifications/ReminderScheduler.swift
  - Widgets/Z24x4Widgets.swift
  - App/Views/TodayView.swift
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - App/Views/GuidedPlayerView.swift
  - App/Views/ShareCard.swift
  - WatchComplications/Info.plist
  - App/WidgetSnapshotWriter.swift
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - App/Views/ManualEntryView.swift
  - App/DesignSystem/Buttons.swift
  - App/Views/WeekView.swift
  - WatchComplications/Z24x4WatchComplications.swift
  - CLAUDE.md
  - SharedCore/Sources/SharedCore/WorkoutRecord.swift
  - SharedCore/Tests/SharedCoreTests/StreaksAchievementsTests.swift
  - App/Z24x4TrainerApp.swift
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - project.yml
-->