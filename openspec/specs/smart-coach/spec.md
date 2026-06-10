# smart-coach Specification

## Purpose

TBD - created by archiving change 'smart-coach'. Update Purpose after archive.

## Requirements

### Requirement: Adaptive plan progression
The plan SHALL progress when recent weekly targets are met, hold when they are missed, and deload
periodically, deterministically from training history.

#### Scenario: Progress after consistent weeks
- **WHEN** the athlete met the weekly training-minute target for the last 3 weeks
- **THEN** the adjusted plan adds volume (more Zone 2 minutes or an extra 4×4) versus the base plan

#### Scenario: Hold after a missed week
- **WHEN** the most recent week missed the target
- **THEN** the adjusted plan keeps the base volume (no increase)

#### Scenario: Deload week
- **WHEN** the current week is a scheduled deload (every 4th progression week)
- **THEN** the adjusted plan reduces volume below the base plan


<!-- @trace
source: smart-coach
updated: 2026-06-10
code:
  - App/Persistence/AchievementRecord.swift
  - SharedCore/Sources/SharedCore/ZoneMethod.swift
  - SharedCore/Sources/SharedCore/WorkoutRecord.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - SharedCore/Package.swift
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - App/DesignSystem/AccessibleControls.swift
  - Watch/WorkoutListView.swift
  - App/Views/WorkoutDetailView.swift
  - SharedCore/Sources/SharedCore/PlanProgression.swift
  - SharedCore/Tests/SharedCoreTests/GuidedCueTests.swift
  - SharedCore/Sources/SharedCore/Achievement.swift
  - Watch/LiveWorkoutView.swift
  - App/Views/HistoryView.swift
  - App/Views/StreakBanner.swift
  - WatchComplications/Z24x4WatchComplications.swift
  - App/DesignSystem/ZoneStyle.swift
  - SharedCore/Sources/SharedCore/Readiness.swift
  - App/Sync/PhoneSessionReceiver.swift
  - project.yml
  - App/Views/AchievementsView.swift
  - App/Views/WeekView.swift
  - SharedCore/Sources/SharedCore/Localizable.xcstrings
  - SharedCore/Tests/SharedCoreTests/StreaksAchievementsTests.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - App/Persistence/ProfileRecord.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - App/Views/RootView.swift
  - CLAUDE.md
  - App/WidgetSnapshotWriter.swift
  - PROGRESS.md
  - App/DesignSystem/Theme.swift
  - Widgets/Z24x4Widgets.swift
  - App/Z24x4TrainerApp.swift
  - App/Localizable.xcstrings
  - SharedCore/Sources/SharedCore/HRZoneCalculator.swift
  - SharedCore/Sources/SharedCore/StreakCalculator.swift
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
  - SharedCore/Sources/SharedCore/AchievementEvaluator.swift
  - App/Views/Celebration.swift
  - SharedCore/Sources/SharedCore/MetricSample.swift
  - App/Z24x4Trainer.entitlements
  - App/DesignSystem/Motion.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
  - App/DesignSystem/Components.swift
  - SharedCore/Sources/SharedCore/UserProfile.swift
  - App/Views/TodayView.swift
  - App/Health/HealthKitService.swift
  - Watch/WorkoutSessionManager.swift
  - Watch/IntervalEngine.swift
  - App/Notifications/ReminderScheduler.swift
  - App/Views/OnboardingView.swift
  - Widgets/Info.plist
  - App/Views/ManualEntryView.swift
  - App/Health/HealthStore.swift
  - App/Views/GuidedPlayerView.swift
  - SharedCore/Tests/SharedCoreTests/PrecisionZonesTests.swift
  - Widgets/Z24x4Widgets.entitlements
  - App/GuidedSessionEngine.swift
  - App/Views/SettingsView.swift
  - App/Health/HealthProviding.swift
  - App/DesignSystem/Buttons.swift
  - App/Views/ShareCard.swift
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - App/Health/PreviewHealthService.swift
  - WatchComplications/Info.plist
  - SharedCore/Sources/SharedCore/GuidedCue.swift
-->

---
### Requirement: Fitness trend from VO2max
The app SHALL present the user's VO2max over time when Apple Health has VO2max samples.

#### Scenario: Trend shown
- **WHEN** Health returns VO2max samples
- **THEN** History shows a dated VO2max line; the latest value and its change are summarized

#### Scenario: No VO2max data
- **WHEN** Health has no VO2max samples
- **THEN** History shows a friendly empty state instead of an empty chart


<!-- @trace
source: smart-coach
updated: 2026-06-10
code:
  - App/Persistence/AchievementRecord.swift
  - SharedCore/Sources/SharedCore/ZoneMethod.swift
  - SharedCore/Sources/SharedCore/WorkoutRecord.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - SharedCore/Package.swift
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - App/DesignSystem/AccessibleControls.swift
  - Watch/WorkoutListView.swift
  - App/Views/WorkoutDetailView.swift
  - SharedCore/Sources/SharedCore/PlanProgression.swift
  - SharedCore/Tests/SharedCoreTests/GuidedCueTests.swift
  - SharedCore/Sources/SharedCore/Achievement.swift
  - Watch/LiveWorkoutView.swift
  - App/Views/HistoryView.swift
  - App/Views/StreakBanner.swift
  - WatchComplications/Z24x4WatchComplications.swift
  - App/DesignSystem/ZoneStyle.swift
  - SharedCore/Sources/SharedCore/Readiness.swift
  - App/Sync/PhoneSessionReceiver.swift
  - project.yml
  - App/Views/AchievementsView.swift
  - App/Views/WeekView.swift
  - SharedCore/Sources/SharedCore/Localizable.xcstrings
  - SharedCore/Tests/SharedCoreTests/StreaksAchievementsTests.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - App/Persistence/ProfileRecord.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - App/Views/RootView.swift
  - CLAUDE.md
  - App/WidgetSnapshotWriter.swift
  - PROGRESS.md
  - App/DesignSystem/Theme.swift
  - Widgets/Z24x4Widgets.swift
  - App/Z24x4TrainerApp.swift
  - App/Localizable.xcstrings
  - SharedCore/Sources/SharedCore/HRZoneCalculator.swift
  - SharedCore/Sources/SharedCore/StreakCalculator.swift
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
  - SharedCore/Sources/SharedCore/AchievementEvaluator.swift
  - App/Views/Celebration.swift
  - SharedCore/Sources/SharedCore/MetricSample.swift
  - App/Z24x4Trainer.entitlements
  - App/DesignSystem/Motion.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
  - App/DesignSystem/Components.swift
  - SharedCore/Sources/SharedCore/UserProfile.swift
  - App/Views/TodayView.swift
  - App/Health/HealthKitService.swift
  - Watch/WorkoutSessionManager.swift
  - Watch/IntervalEngine.swift
  - App/Notifications/ReminderScheduler.swift
  - App/Views/OnboardingView.swift
  - Widgets/Info.plist
  - App/Views/ManualEntryView.swift
  - App/Health/HealthStore.swift
  - App/Views/GuidedPlayerView.swift
  - SharedCore/Tests/SharedCoreTests/PrecisionZonesTests.swift
  - Widgets/Z24x4Widgets.entitlements
  - App/GuidedSessionEngine.swift
  - App/Views/SettingsView.swift
  - App/Health/HealthProviding.swift
  - App/DesignSystem/Buttons.swift
  - App/Views/ShareCard.swift
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - App/Health/PreviewHealthService.swift
  - WatchComplications/Info.plist
  - SharedCore/Sources/SharedCore/GuidedCue.swift
-->

---
### Requirement: Coach card
Today SHALL show a coach summary of the adapted week plus one short, relevant tip.

#### Scenario: Coach summary
- **WHEN** Today is shown
- **THEN** a Coach card states the adapted week (e.g. "3 Zone 2 + 1× 4×4") and one tip

<!-- @trace
source: smart-coach
updated: 2026-06-10
code:
  - App/Persistence/AchievementRecord.swift
  - SharedCore/Sources/SharedCore/ZoneMethod.swift
  - SharedCore/Sources/SharedCore/WorkoutRecord.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - SharedCore/Package.swift
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - App/DesignSystem/AccessibleControls.swift
  - Watch/WorkoutListView.swift
  - App/Views/WorkoutDetailView.swift
  - SharedCore/Sources/SharedCore/PlanProgression.swift
  - SharedCore/Tests/SharedCoreTests/GuidedCueTests.swift
  - SharedCore/Sources/SharedCore/Achievement.swift
  - Watch/LiveWorkoutView.swift
  - App/Views/HistoryView.swift
  - App/Views/StreakBanner.swift
  - WatchComplications/Z24x4WatchComplications.swift
  - App/DesignSystem/ZoneStyle.swift
  - SharedCore/Sources/SharedCore/Readiness.swift
  - App/Sync/PhoneSessionReceiver.swift
  - project.yml
  - App/Views/AchievementsView.swift
  - App/Views/WeekView.swift
  - SharedCore/Sources/SharedCore/Localizable.xcstrings
  - SharedCore/Tests/SharedCoreTests/StreaksAchievementsTests.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - App/Persistence/ProfileRecord.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - App/Views/RootView.swift
  - CLAUDE.md
  - App/WidgetSnapshotWriter.swift
  - PROGRESS.md
  - App/DesignSystem/Theme.swift
  - Widgets/Z24x4Widgets.swift
  - App/Z24x4TrainerApp.swift
  - App/Localizable.xcstrings
  - SharedCore/Sources/SharedCore/HRZoneCalculator.swift
  - SharedCore/Sources/SharedCore/StreakCalculator.swift
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
  - SharedCore/Sources/SharedCore/AchievementEvaluator.swift
  - App/Views/Celebration.swift
  - SharedCore/Sources/SharedCore/MetricSample.swift
  - App/Z24x4Trainer.entitlements
  - App/DesignSystem/Motion.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
  - App/DesignSystem/Components.swift
  - SharedCore/Sources/SharedCore/UserProfile.swift
  - App/Views/TodayView.swift
  - App/Health/HealthKitService.swift
  - Watch/WorkoutSessionManager.swift
  - Watch/IntervalEngine.swift
  - App/Notifications/ReminderScheduler.swift
  - App/Views/OnboardingView.swift
  - Widgets/Info.plist
  - App/Views/ManualEntryView.swift
  - App/Health/HealthStore.swift
  - App/Views/GuidedPlayerView.swift
  - SharedCore/Tests/SharedCoreTests/PrecisionZonesTests.swift
  - Widgets/Z24x4Widgets.entitlements
  - App/GuidedSessionEngine.swift
  - App/Views/SettingsView.swift
  - App/Health/HealthProviding.swift
  - App/DesignSystem/Buttons.swift
  - App/Views/ShareCard.swift
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - App/Health/PreviewHealthService.swift
  - WatchComplications/Info.plist
  - SharedCore/Sources/SharedCore/GuidedCue.swift
-->