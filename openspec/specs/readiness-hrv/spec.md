# readiness-hrv Specification

## Purpose

TBD - created by archiving change 'readiness-hrv'. Update Purpose after archive.

## Requirements

### Requirement: Daily readiness score
The app SHALL compute a 0–100 readiness score from recent HRV and resting HR relative to the
user's own baseline, when Apple Health has the data.

#### Scenario: Above baseline reads high
- **WHEN** today's HRV is above the rolling baseline and resting HR is at or below baseline
- **THEN** readiness is high (≥ 67) and labelled "Go hard"

#### Scenario: Below baseline reads low
- **WHEN** today's HRV is well below baseline or resting HR is elevated
- **THEN** readiness is low (< 34) and labelled "Take it easy"

#### Scenario: No data
- **WHEN** Health has insufficient HRV/RHR history
- **THEN** no readiness score is shown (the UI hides the chip)


<!-- @trace
source: readiness-hrv
updated: 2026-06-10
code:
  - App/Views/SettingsView.swift
  - App/Views/OnboardingView.swift
  - App/DesignSystem/Buttons.swift
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
  - SharedCore/Sources/SharedCore/ZoneMethod.swift
  - CLAUDE.md
  - WatchComplications/Info.plist
  - SharedCore/Sources/SharedCore/StreakCalculator.swift
  - App/Views/WorkoutDetailView.swift
  - App/Persistence/ProfileRecord.swift
  - SharedCore/Sources/SharedCore/Localizable.xcstrings
  - SharedCore/Sources/SharedCore/GuidedCue.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - SharedCore/Sources/SharedCore/UserProfile.swift
  - App/Views/GuidedPlayerView.swift
  - App/Views/Celebration.swift
  - App/Views/ManualEntryView.swift
  - Watch/WorkoutListView.swift
  - SharedCore/Sources/SharedCore/Achievement.swift
  - App/DesignSystem/Motion.swift
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - SharedCore/Sources/SharedCore/WorkoutRecord.swift
  - App/DesignSystem/Theme.swift
  - App/Localizable.xcstrings
  - App/GuidedSessionEngine.swift
  - SharedCore/Tests/SharedCoreTests/StreaksAchievementsTests.swift
  - App/WidgetSnapshotWriter.swift
  - SharedCore/Sources/SharedCore/MetricSample.swift
  - Widgets/Z24x4Widgets.entitlements
  - WatchComplications/Z24x4WatchComplications.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - SharedCore/Tests/SharedCoreTests/GuidedCueTests.swift
  - App/Health/HealthKitService.swift
  - App/Views/TodayView.swift
  - SharedCore/Sources/SharedCore/AchievementEvaluator.swift
  - SharedCore/Sources/SharedCore/PlanProgression.swift
  - Watch/LiveWorkoutView.swift
  - SharedCore/Tests/SharedCoreTests/PrecisionZonesTests.swift
  - App/Z24x4TrainerApp.swift
  - App/Z24x4Trainer.entitlements
  - SharedCore/Package.swift
  - Widgets/Info.plist
  - Watch/IntervalEngine.swift
  - App/Views/ShareCard.swift
  - SharedCore/Sources/SharedCore/Readiness.swift
  - project.yml
  - App/DesignSystem/AccessibleControls.swift
  - App/DesignSystem/Components.swift
  - App/Views/StreakBanner.swift
  - App/DesignSystem/ZoneStyle.swift
  - App/Health/HealthStore.swift
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - App/Views/RootView.swift
  - SharedCore/Sources/SharedCore/HRZoneCalculator.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
  - App/Persistence/AchievementRecord.swift
  - App/Views/HistoryView.swift
  - App/Health/PreviewHealthService.swift
  - Watch/WorkoutSessionManager.swift
  - App/Sync/PhoneSessionReceiver.swift
  - App/Health/HealthProviding.swift
  - Widgets/Z24x4Widgets.swift
  - App/Views/AchievementsView.swift
  - App/Views/WeekView.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - App/Notifications/ReminderScheduler.swift
  - PROGRESS.md
-->

---
### Requirement: Readiness informs Today
Today SHALL surface the readiness score and a one-line recommendation when available.

#### Scenario: Chip on Today
- **WHEN** a readiness score exists
- **THEN** Today shows a readiness chip with the score, label, and a short recommendation

<!-- @trace
source: readiness-hrv
updated: 2026-06-10
code:
  - App/Views/SettingsView.swift
  - App/Views/OnboardingView.swift
  - App/DesignSystem/Buttons.swift
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
  - SharedCore/Sources/SharedCore/ZoneMethod.swift
  - CLAUDE.md
  - WatchComplications/Info.plist
  - SharedCore/Sources/SharedCore/StreakCalculator.swift
  - App/Views/WorkoutDetailView.swift
  - App/Persistence/ProfileRecord.swift
  - SharedCore/Sources/SharedCore/Localizable.xcstrings
  - SharedCore/Sources/SharedCore/GuidedCue.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - SharedCore/Sources/SharedCore/UserProfile.swift
  - App/Views/GuidedPlayerView.swift
  - App/Views/Celebration.swift
  - App/Views/ManualEntryView.swift
  - Watch/WorkoutListView.swift
  - SharedCore/Sources/SharedCore/Achievement.swift
  - App/DesignSystem/Motion.swift
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - SharedCore/Sources/SharedCore/WorkoutRecord.swift
  - App/DesignSystem/Theme.swift
  - App/Localizable.xcstrings
  - App/GuidedSessionEngine.swift
  - SharedCore/Tests/SharedCoreTests/StreaksAchievementsTests.swift
  - App/WidgetSnapshotWriter.swift
  - SharedCore/Sources/SharedCore/MetricSample.swift
  - Widgets/Z24x4Widgets.entitlements
  - WatchComplications/Z24x4WatchComplications.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - SharedCore/Tests/SharedCoreTests/GuidedCueTests.swift
  - App/Health/HealthKitService.swift
  - App/Views/TodayView.swift
  - SharedCore/Sources/SharedCore/AchievementEvaluator.swift
  - SharedCore/Sources/SharedCore/PlanProgression.swift
  - Watch/LiveWorkoutView.swift
  - SharedCore/Tests/SharedCoreTests/PrecisionZonesTests.swift
  - App/Z24x4TrainerApp.swift
  - App/Z24x4Trainer.entitlements
  - SharedCore/Package.swift
  - Widgets/Info.plist
  - Watch/IntervalEngine.swift
  - App/Views/ShareCard.swift
  - SharedCore/Sources/SharedCore/Readiness.swift
  - project.yml
  - App/DesignSystem/AccessibleControls.swift
  - App/DesignSystem/Components.swift
  - App/Views/StreakBanner.swift
  - App/DesignSystem/ZoneStyle.swift
  - App/Health/HealthStore.swift
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - App/Views/RootView.swift
  - SharedCore/Sources/SharedCore/HRZoneCalculator.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
  - App/Persistence/AchievementRecord.swift
  - App/Views/HistoryView.swift
  - App/Health/PreviewHealthService.swift
  - Watch/WorkoutSessionManager.swift
  - App/Sync/PhoneSessionReceiver.swift
  - App/Health/HealthProviding.swift
  - Widgets/Z24x4Widgets.swift
  - App/Views/AchievementsView.swift
  - App/Views/WeekView.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - App/Notifications/ReminderScheduler.swift
  - PROGRESS.md
-->