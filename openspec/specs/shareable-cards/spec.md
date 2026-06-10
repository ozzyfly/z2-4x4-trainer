# shareable-cards Specification

## Purpose

TBD - created by archiving change 'shareable-cards'. Update Purpose after archive.

## Requirements

### Requirement: Share a summary card
The app SHALL render a branded summary image (this week's training) and present it via the system
share sheet.

#### Scenario: Share from History
- **WHEN** the user taps Share on History
- **THEN** the app renders a branded card image (app name, week dates, minutes, sessions, streak) and opens the share sheet with it

#### Scenario: Card reflects real data
- **WHEN** the week has 3 sessions totalling 120 minutes
- **THEN** the card shows 3 sessions and 120 minutes

<!-- @trace
source: shareable-cards
updated: 2026-06-10
code:
  - App/DesignSystem/Buttons.swift
  - SharedCore/Sources/SharedCore/HRZoneCalculator.swift
  - SharedCore/Tests/SharedCoreTests/StreaksAchievementsTests.swift
  - SharedCore/Sources/SharedCore/MetricSample.swift
  - App/Views/GuidedPlayerView.swift
  - App/Views/Celebration.swift
  - SharedCore/Sources/SharedCore/Achievement.swift
  - App/DesignSystem/ZoneStyle.swift
  - Widgets/Info.plist
  - App/Z24x4Trainer.entitlements
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - App/Localizable.xcstrings
  - App/DesignSystem/Motion.swift
  - SharedCore/Sources/SharedCore/ZoneMethod.swift
  - App/Views/WorkoutDetailView.swift
  - SharedCore/Sources/SharedCore/AchievementEvaluator.swift
  - App/Health/HealthStore.swift
  - App/Health/HealthKitService.swift
  - App/WidgetSnapshotWriter.swift
  - SharedCore/Tests/SharedCoreTests/GuidedCueTests.swift
  - Widgets/Z24x4Widgets.swift
  - App/Views/OnboardingView.swift
  - Watch/LiveWorkoutView.swift
  - App/Health/HealthProviding.swift
  - WatchComplications/Info.plist
  - App/Views/ManualEntryView.swift
  - SharedCore/Sources/SharedCore/WorkoutRecord.swift
  - App/Views/WeekView.swift
  - App/Z24x4TrainerApp.swift
  - Widgets/Z24x4Widgets.entitlements
  - SharedCore/Sources/SharedCore/Readiness.swift
  - PROGRESS.md
  - SharedCore/Sources/SharedCore/Localizable.xcstrings
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - App/Views/RootView.swift
  - Watch/WorkoutListView.swift
  - SharedCore/Sources/SharedCore/GuidedCue.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - App/Views/AchievementsView.swift
  - App/Notifications/ReminderScheduler.swift
  - App/Views/StreakBanner.swift
  - SharedCore/Sources/SharedCore/StreakCalculator.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - SharedCore/Sources/SharedCore/PlanProgression.swift
  - SharedCore/Tests/SharedCoreTests/PrecisionZonesTests.swift
  - App/Views/HistoryView.swift
  - App/DesignSystem/Theme.swift
  - App/DesignSystem/Components.swift
  - CLAUDE.md
  - App/GuidedSessionEngine.swift
  - App/Views/SettingsView.swift
  - SharedCore/Package.swift
  - WatchComplications/Z24x4WatchComplications.swift
  - App/Persistence/AchievementRecord.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
  - App/Sync/PhoneSessionReceiver.swift
  - App/Views/TodayView.swift
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
  - App/Persistence/ProfileRecord.swift
  - project.yml
  - Watch/WorkoutSessionManager.swift
  - App/DesignSystem/AccessibleControls.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - App/Views/ShareCard.swift
  - Watch/IntervalEngine.swift
  - SharedCore/Sources/SharedCore/UserProfile.swift
  - App/Health/PreviewHealthService.swift
-->