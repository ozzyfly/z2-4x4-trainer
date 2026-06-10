# precision-zones Specification

## Purpose

TBD - created by archiving change 'precision-zones'. Update Purpose after archive.

## Requirements

### Requirement: Selectable zone method
The calculator SHALL compute zones by age-max, Karvonen/HRR, or custom bands per the profile's
selected method, defaulting to age-max.

#### Scenario: Karvonen uses heart-rate reserve
- **WHEN** the method is Karvonen with maxHR 190 and resting HR 50
- **THEN** the Zone 2 band uses reserve: lower = 50 + 0.60·(190−50), upper = 50 + 0.70·(190−50)

#### Scenario: Age-max default unchanged
- **WHEN** the method is age-max with maxHR 190
- **THEN** Zone 2 is 114–133 bpm, exactly as before this change

#### Scenario: Custom bands honored
- **WHEN** the method is custom with a user-set Zone 2 band of 120–140
- **THEN** the calculator returns 120–140 for Zone 2


<!-- @trace
source: precision-zones
updated: 2026-06-10
code:
  - App/Persistence/AchievementRecord.swift
  - Widgets/Info.plist
  - App/Health/PreviewHealthService.swift
  - App/Views/RootView.swift
  - App/Views/StreakBanner.swift
  - project.yml
  - App/Views/AchievementsView.swift
  - App/Views/SettingsView.swift
  - App/Views/HistoryView.swift
  - Widgets/Z24x4Widgets.swift
  - SharedCore/Sources/SharedCore/Readiness.swift
  - App/Health/HealthKitService.swift
  - App/Views/ShareCard.swift
  - WatchComplications/Info.plist
  - SharedCore/Sources/SharedCore/StreakCalculator.swift
  - SharedCore/Tests/SharedCoreTests/GuidedCueTests.swift
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - Watch/IntervalEngine.swift
  - SharedCore/Sources/SharedCore/HRZoneCalculator.swift
  - SharedCore/Sources/SharedCore/UserProfile.swift
  - Watch/WorkoutListView.swift
  - App/Z24x4Trainer.entitlements
  - SharedCore/Sources/SharedCore/PlanProgression.swift
  - SharedCore/Tests/SharedCoreTests/PrecisionZonesTests.swift
  - PROGRESS.md
  - App/WidgetSnapshotWriter.swift
  - SharedCore/Sources/SharedCore/GuidedCue.swift
  - App/GuidedSessionEngine.swift
  - SharedCore/Sources/SharedCore/MetricSample.swift
  - SharedCore/Sources/SharedCore/Achievement.swift
  - App/DesignSystem/Components.swift
  - App/Views/ManualEntryView.swift
  - App/Views/WorkoutDetailView.swift
  - SharedCore/Tests/SharedCoreTests/StreaksAchievementsTests.swift
  - App/Health/HealthStore.swift
  - CLAUDE.md
  - App/DesignSystem/Motion.swift
  - Watch/WorkoutSessionManager.swift
  - App/DesignSystem/ZoneStyle.swift
  - App/Views/WeekView.swift
  - Widgets/Z24x4Widgets.entitlements
  - SharedCore/Sources/SharedCore/ZoneMethod.swift
  - App/Localizable.xcstrings
  - App/Sync/PhoneSessionReceiver.swift
  - SharedCore/Sources/SharedCore/WorkoutRecord.swift
  - App/DesignSystem/Buttons.swift
  - App/Z24x4TrainerApp.swift
  - SharedCore/Sources/SharedCore/AchievementEvaluator.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
  - App/DesignSystem/Theme.swift
  - App/Views/GuidedPlayerView.swift
  - SharedCore/Package.swift
  - SharedCore/Sources/SharedCore/Localizable.xcstrings
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - App/Views/OnboardingView.swift
  - Watch/LiveWorkoutView.swift
  - App/DesignSystem/AccessibleControls.swift
  - WatchComplications/Z24x4WatchComplications.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - App/Health/HealthProviding.swift
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - App/Views/Celebration.swift
  - App/Persistence/ProfileRecord.swift
  - App/Views/TodayView.swift
  - App/Notifications/ReminderScheduler.swift
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
-->

---
### Requirement: Karvonen needs resting HR
The app SHALL fall back to age-max when Karvonen is selected without a resting HR.

#### Scenario: Missing resting HR
- **WHEN** Karvonen is selected but resting HR is nil
- **THEN** zones are computed by age-max and the UI prompts for resting HR

<!-- @trace
source: precision-zones
updated: 2026-06-10
code:
  - App/Persistence/AchievementRecord.swift
  - Widgets/Info.plist
  - App/Health/PreviewHealthService.swift
  - App/Views/RootView.swift
  - App/Views/StreakBanner.swift
  - project.yml
  - App/Views/AchievementsView.swift
  - App/Views/SettingsView.swift
  - App/Views/HistoryView.swift
  - Widgets/Z24x4Widgets.swift
  - SharedCore/Sources/SharedCore/Readiness.swift
  - App/Health/HealthKitService.swift
  - App/Views/ShareCard.swift
  - WatchComplications/Info.plist
  - SharedCore/Sources/SharedCore/StreakCalculator.swift
  - SharedCore/Tests/SharedCoreTests/GuidedCueTests.swift
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - Watch/IntervalEngine.swift
  - SharedCore/Sources/SharedCore/HRZoneCalculator.swift
  - SharedCore/Sources/SharedCore/UserProfile.swift
  - Watch/WorkoutListView.swift
  - App/Z24x4Trainer.entitlements
  - SharedCore/Sources/SharedCore/PlanProgression.swift
  - SharedCore/Tests/SharedCoreTests/PrecisionZonesTests.swift
  - PROGRESS.md
  - App/WidgetSnapshotWriter.swift
  - SharedCore/Sources/SharedCore/GuidedCue.swift
  - App/GuidedSessionEngine.swift
  - SharedCore/Sources/SharedCore/MetricSample.swift
  - SharedCore/Sources/SharedCore/Achievement.swift
  - App/DesignSystem/Components.swift
  - App/Views/ManualEntryView.swift
  - App/Views/WorkoutDetailView.swift
  - SharedCore/Tests/SharedCoreTests/StreaksAchievementsTests.swift
  - App/Health/HealthStore.swift
  - CLAUDE.md
  - App/DesignSystem/Motion.swift
  - Watch/WorkoutSessionManager.swift
  - App/DesignSystem/ZoneStyle.swift
  - App/Views/WeekView.swift
  - Widgets/Z24x4Widgets.entitlements
  - SharedCore/Sources/SharedCore/ZoneMethod.swift
  - App/Localizable.xcstrings
  - App/Sync/PhoneSessionReceiver.swift
  - SharedCore/Sources/SharedCore/WorkoutRecord.swift
  - App/DesignSystem/Buttons.swift
  - App/Z24x4TrainerApp.swift
  - SharedCore/Sources/SharedCore/AchievementEvaluator.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
  - App/DesignSystem/Theme.swift
  - App/Views/GuidedPlayerView.swift
  - SharedCore/Package.swift
  - SharedCore/Sources/SharedCore/Localizable.xcstrings
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - App/Views/OnboardingView.swift
  - Watch/LiveWorkoutView.swift
  - App/DesignSystem/AccessibleControls.swift
  - WatchComplications/Z24x4WatchComplications.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - App/Health/HealthProviding.swift
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - App/Views/Celebration.swift
  - App/Persistence/ProfileRecord.swift
  - App/Views/TodayView.swift
  - App/Notifications/ReminderScheduler.swift
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
-->