# guided-player-audio Specification

## Purpose

TBD - created by archiving change 'guided-player-audio'. Update Purpose after archive.

## Requirements

### Requirement: Guided 4×4 player
The app SHALL provide an on-iPhone guided player for the Norwegian 4×4 session that advances through the prescribed intervals with a live countdown, shows the current and next interval, fires a haptic on each transition, and speaks a voice cue when entering each interval.

#### Scenario: Countdown advances through intervals
- **WHEN** the guided 4×4 player runs
- **THEN** the current interval's remaining time counts down each second and, on reaching zero, advances to the next interval until the session completes

#### Scenario: Transition feedback
- **WHEN** the player enters a new interval
- **THEN** a haptic fires and a spoken cue announces the interval (e.g. "Hard" / "Recover")

#### Scenario: Completion
- **WHEN** the final interval elapses
- **THEN** the player stops and announces that the session is complete


<!-- @trace
source: guided-player-audio
updated: 2026-06-09
code:
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - App/Views/OnboardingView.swift
  - Watch/LiveWorkoutView.swift
  - SharedCore/Sources/SharedCore/Readiness.swift
  - App/WidgetSnapshotWriter.swift
  - App/GuidedSessionEngine.swift
  - App/Views/StreakBanner.swift
  - App/Views/AchievementsView.swift
  - App/DesignSystem/Components.swift
  - Widgets/Info.plist
  - App/Views/WeekView.swift
  - SharedCore/Sources/SharedCore/Achievement.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - SharedCore/Sources/SharedCore/AchievementEvaluator.swift
  - SharedCore/Sources/SharedCore/ZoneMethod.swift
  - SharedCore/Sources/SharedCore/UserProfile.swift
  - WatchComplications/Z24x4WatchComplications.swift
  - App/Health/HealthKitService.swift
  - App/Views/ManualEntryView.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - PROGRESS.md
  - App/DesignSystem/Buttons.swift
  - SharedCore/Sources/SharedCore/GuidedCue.swift
  - SharedCore/Sources/SharedCore/PlanProgression.swift
  - SharedCore/Sources/SharedCore/StreakCalculator.swift
  - Watch/WorkoutSessionManager.swift
  - Widgets/Z24x4Widgets.swift
  - App/Views/ShareCard.swift
  - Widgets/Z24x4Widgets.entitlements
  - App/Views/Celebration.swift
  - App/DesignSystem/ZoneStyle.swift
  - SharedCore/Sources/SharedCore/WorkoutRecord.swift
  - App/Persistence/ProfileRecord.swift
  - SharedCore/Sources/SharedCore/HRZoneCalculator.swift
  - App/Sync/PhoneSessionReceiver.swift
  - App/Z24x4Trainer.entitlements
  - SharedCore/Tests/SharedCoreTests/PrecisionZonesTests.swift
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
  - SharedCore/Sources/SharedCore/MetricSample.swift
  - Watch/WorkoutListView.swift
  - App/Views/GuidedPlayerView.swift
  - App/Health/PreviewHealthService.swift
  - Watch/IntervalEngine.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - App/Views/SettingsView.swift
  - App/Views/WorkoutDetailView.swift
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - WatchComplications/Info.plist
  - App/Views/RootView.swift
  - SharedCore/Tests/SharedCoreTests/GuidedCueTests.swift
  - App/Health/HealthProviding.swift
  - App/Persistence/AchievementRecord.swift
  - App/Health/HealthStore.swift
  - App/Z24x4TrainerApp.swift
  - App/DesignSystem/AccessibleControls.swift
  - App/DesignSystem/Motion.swift
  - App/DesignSystem/Theme.swift
  - SharedCore/Tests/SharedCoreTests/StreaksAchievementsTests.swift
  - App/Notifications/ReminderScheduler.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
  - project.yml
  - App/Views/TodayView.swift
  - App/Views/HistoryView.swift
-->

---
### Requirement: Guided Zone 2 player
The app SHALL provide a guided Zone 2 mode showing elapsed time, with a spoken reminder at the start and periodically thereafter.

#### Scenario: Zone 2 elapsed and reminder
- **WHEN** the Zone 2 guided session runs
- **THEN** elapsed time is displayed and a spoken reminder to stay in Zone 2 plays at the start and at regular intervals


<!-- @trace
source: guided-player-audio
updated: 2026-06-09
code:
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - App/Views/OnboardingView.swift
  - Watch/LiveWorkoutView.swift
  - SharedCore/Sources/SharedCore/Readiness.swift
  - App/WidgetSnapshotWriter.swift
  - App/GuidedSessionEngine.swift
  - App/Views/StreakBanner.swift
  - App/Views/AchievementsView.swift
  - App/DesignSystem/Components.swift
  - Widgets/Info.plist
  - App/Views/WeekView.swift
  - SharedCore/Sources/SharedCore/Achievement.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - SharedCore/Sources/SharedCore/AchievementEvaluator.swift
  - SharedCore/Sources/SharedCore/ZoneMethod.swift
  - SharedCore/Sources/SharedCore/UserProfile.swift
  - WatchComplications/Z24x4WatchComplications.swift
  - App/Health/HealthKitService.swift
  - App/Views/ManualEntryView.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - PROGRESS.md
  - App/DesignSystem/Buttons.swift
  - SharedCore/Sources/SharedCore/GuidedCue.swift
  - SharedCore/Sources/SharedCore/PlanProgression.swift
  - SharedCore/Sources/SharedCore/StreakCalculator.swift
  - Watch/WorkoutSessionManager.swift
  - Widgets/Z24x4Widgets.swift
  - App/Views/ShareCard.swift
  - Widgets/Z24x4Widgets.entitlements
  - App/Views/Celebration.swift
  - App/DesignSystem/ZoneStyle.swift
  - SharedCore/Sources/SharedCore/WorkoutRecord.swift
  - App/Persistence/ProfileRecord.swift
  - SharedCore/Sources/SharedCore/HRZoneCalculator.swift
  - App/Sync/PhoneSessionReceiver.swift
  - App/Z24x4Trainer.entitlements
  - SharedCore/Tests/SharedCoreTests/PrecisionZonesTests.swift
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
  - SharedCore/Sources/SharedCore/MetricSample.swift
  - Watch/WorkoutListView.swift
  - App/Views/GuidedPlayerView.swift
  - App/Health/PreviewHealthService.swift
  - Watch/IntervalEngine.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - App/Views/SettingsView.swift
  - App/Views/WorkoutDetailView.swift
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - WatchComplications/Info.plist
  - App/Views/RootView.swift
  - SharedCore/Tests/SharedCoreTests/GuidedCueTests.swift
  - App/Health/HealthProviding.swift
  - App/Persistence/AchievementRecord.swift
  - App/Health/HealthStore.swift
  - App/Z24x4TrainerApp.swift
  - App/DesignSystem/AccessibleControls.swift
  - App/DesignSystem/Motion.swift
  - App/DesignSystem/Theme.swift
  - SharedCore/Tests/SharedCoreTests/StreaksAchievementsTests.swift
  - App/Notifications/ReminderScheduler.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
  - project.yml
  - App/Views/TodayView.swift
  - App/Views/HistoryView.swift
-->

---
### Requirement: Interval cue text is well-defined
Each interval kind, and the session-complete state, SHALL map to a defined non-empty spoken cue string, independent of any view.

#### Scenario: Every kind has a cue
- **WHEN** a cue is requested for entering any `IntervalKind`, or for session completion
- **THEN** a non-empty string is returned


<!-- @trace
source: guided-player-audio
updated: 2026-06-09
code:
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - App/Views/OnboardingView.swift
  - Watch/LiveWorkoutView.swift
  - SharedCore/Sources/SharedCore/Readiness.swift
  - App/WidgetSnapshotWriter.swift
  - App/GuidedSessionEngine.swift
  - App/Views/StreakBanner.swift
  - App/Views/AchievementsView.swift
  - App/DesignSystem/Components.swift
  - Widgets/Info.plist
  - App/Views/WeekView.swift
  - SharedCore/Sources/SharedCore/Achievement.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - SharedCore/Sources/SharedCore/AchievementEvaluator.swift
  - SharedCore/Sources/SharedCore/ZoneMethod.swift
  - SharedCore/Sources/SharedCore/UserProfile.swift
  - WatchComplications/Z24x4WatchComplications.swift
  - App/Health/HealthKitService.swift
  - App/Views/ManualEntryView.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - PROGRESS.md
  - App/DesignSystem/Buttons.swift
  - SharedCore/Sources/SharedCore/GuidedCue.swift
  - SharedCore/Sources/SharedCore/PlanProgression.swift
  - SharedCore/Sources/SharedCore/StreakCalculator.swift
  - Watch/WorkoutSessionManager.swift
  - Widgets/Z24x4Widgets.swift
  - App/Views/ShareCard.swift
  - Widgets/Z24x4Widgets.entitlements
  - App/Views/Celebration.swift
  - App/DesignSystem/ZoneStyle.swift
  - SharedCore/Sources/SharedCore/WorkoutRecord.swift
  - App/Persistence/ProfileRecord.swift
  - SharedCore/Sources/SharedCore/HRZoneCalculator.swift
  - App/Sync/PhoneSessionReceiver.swift
  - App/Z24x4Trainer.entitlements
  - SharedCore/Tests/SharedCoreTests/PrecisionZonesTests.swift
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
  - SharedCore/Sources/SharedCore/MetricSample.swift
  - Watch/WorkoutListView.swift
  - App/Views/GuidedPlayerView.swift
  - App/Health/PreviewHealthService.swift
  - Watch/IntervalEngine.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - App/Views/SettingsView.swift
  - App/Views/WorkoutDetailView.swift
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - WatchComplications/Info.plist
  - App/Views/RootView.swift
  - SharedCore/Tests/SharedCoreTests/GuidedCueTests.swift
  - App/Health/HealthProviding.swift
  - App/Persistence/AchievementRecord.swift
  - App/Health/HealthStore.swift
  - App/Z24x4TrainerApp.swift
  - App/DesignSystem/AccessibleControls.swift
  - App/DesignSystem/Motion.swift
  - App/DesignSystem/Theme.swift
  - SharedCore/Tests/SharedCoreTests/StreaksAchievementsTests.swift
  - App/Notifications/ReminderScheduler.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
  - project.yml
  - App/Views/TodayView.swift
  - App/Views/HistoryView.swift
-->

---
### Requirement: Audio plays over other audio
While a guided session plays, its voice cues SHALL be audible over other playing audio by ducking it, and normal audio SHALL resume when the session ends.

#### Scenario: Voice ducks music
- **WHEN** a guided session is playing while other audio plays
- **THEN** the other audio is ducked for the spoken cues, and resumes after the session ends


<!-- @trace
source: guided-player-audio
updated: 2026-06-09
code:
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - App/Views/OnboardingView.swift
  - Watch/LiveWorkoutView.swift
  - SharedCore/Sources/SharedCore/Readiness.swift
  - App/WidgetSnapshotWriter.swift
  - App/GuidedSessionEngine.swift
  - App/Views/StreakBanner.swift
  - App/Views/AchievementsView.swift
  - App/DesignSystem/Components.swift
  - Widgets/Info.plist
  - App/Views/WeekView.swift
  - SharedCore/Sources/SharedCore/Achievement.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - SharedCore/Sources/SharedCore/AchievementEvaluator.swift
  - SharedCore/Sources/SharedCore/ZoneMethod.swift
  - SharedCore/Sources/SharedCore/UserProfile.swift
  - WatchComplications/Z24x4WatchComplications.swift
  - App/Health/HealthKitService.swift
  - App/Views/ManualEntryView.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - PROGRESS.md
  - App/DesignSystem/Buttons.swift
  - SharedCore/Sources/SharedCore/GuidedCue.swift
  - SharedCore/Sources/SharedCore/PlanProgression.swift
  - SharedCore/Sources/SharedCore/StreakCalculator.swift
  - Watch/WorkoutSessionManager.swift
  - Widgets/Z24x4Widgets.swift
  - App/Views/ShareCard.swift
  - Widgets/Z24x4Widgets.entitlements
  - App/Views/Celebration.swift
  - App/DesignSystem/ZoneStyle.swift
  - SharedCore/Sources/SharedCore/WorkoutRecord.swift
  - App/Persistence/ProfileRecord.swift
  - SharedCore/Sources/SharedCore/HRZoneCalculator.swift
  - App/Sync/PhoneSessionReceiver.swift
  - App/Z24x4Trainer.entitlements
  - SharedCore/Tests/SharedCoreTests/PrecisionZonesTests.swift
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
  - SharedCore/Sources/SharedCore/MetricSample.swift
  - Watch/WorkoutListView.swift
  - App/Views/GuidedPlayerView.swift
  - App/Health/PreviewHealthService.swift
  - Watch/IntervalEngine.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - App/Views/SettingsView.swift
  - App/Views/WorkoutDetailView.swift
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - WatchComplications/Info.plist
  - App/Views/RootView.swift
  - SharedCore/Tests/SharedCoreTests/GuidedCueTests.swift
  - App/Health/HealthProviding.swift
  - App/Persistence/AchievementRecord.swift
  - App/Health/HealthStore.swift
  - App/Z24x4TrainerApp.swift
  - App/DesignSystem/AccessibleControls.swift
  - App/DesignSystem/Motion.swift
  - App/DesignSystem/Theme.swift
  - SharedCore/Tests/SharedCoreTests/StreaksAchievementsTests.swift
  - App/Notifications/ReminderScheduler.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
  - project.yml
  - App/Views/TodayView.swift
  - App/Views/HistoryView.swift
-->

---
### Requirement: Guided player entry point
The workout detail screen SHALL offer a way to start the guided session for the shown workout.

#### Scenario: Start from workout detail
- **WHEN** the user views a Zone 2 or Norwegian 4×4 workout detail
- **THEN** a control is available to start its guided session

<!-- @trace
source: guided-player-audio
updated: 2026-06-09
code:
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - App/Views/OnboardingView.swift
  - Watch/LiveWorkoutView.swift
  - SharedCore/Sources/SharedCore/Readiness.swift
  - App/WidgetSnapshotWriter.swift
  - App/GuidedSessionEngine.swift
  - App/Views/StreakBanner.swift
  - App/Views/AchievementsView.swift
  - App/DesignSystem/Components.swift
  - Widgets/Info.plist
  - App/Views/WeekView.swift
  - SharedCore/Sources/SharedCore/Achievement.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - SharedCore/Sources/SharedCore/AchievementEvaluator.swift
  - SharedCore/Sources/SharedCore/ZoneMethod.swift
  - SharedCore/Sources/SharedCore/UserProfile.swift
  - WatchComplications/Z24x4WatchComplications.swift
  - App/Health/HealthKitService.swift
  - App/Views/ManualEntryView.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - PROGRESS.md
  - App/DesignSystem/Buttons.swift
  - SharedCore/Sources/SharedCore/GuidedCue.swift
  - SharedCore/Sources/SharedCore/PlanProgression.swift
  - SharedCore/Sources/SharedCore/StreakCalculator.swift
  - Watch/WorkoutSessionManager.swift
  - Widgets/Z24x4Widgets.swift
  - App/Views/ShareCard.swift
  - Widgets/Z24x4Widgets.entitlements
  - App/Views/Celebration.swift
  - App/DesignSystem/ZoneStyle.swift
  - SharedCore/Sources/SharedCore/WorkoutRecord.swift
  - App/Persistence/ProfileRecord.swift
  - SharedCore/Sources/SharedCore/HRZoneCalculator.swift
  - App/Sync/PhoneSessionReceiver.swift
  - App/Z24x4Trainer.entitlements
  - SharedCore/Tests/SharedCoreTests/PrecisionZonesTests.swift
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
  - SharedCore/Sources/SharedCore/MetricSample.swift
  - Watch/WorkoutListView.swift
  - App/Views/GuidedPlayerView.swift
  - App/Health/PreviewHealthService.swift
  - Watch/IntervalEngine.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - App/Views/SettingsView.swift
  - App/Views/WorkoutDetailView.swift
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - WatchComplications/Info.plist
  - App/Views/RootView.swift
  - SharedCore/Tests/SharedCoreTests/GuidedCueTests.swift
  - App/Health/HealthProviding.swift
  - App/Persistence/AchievementRecord.swift
  - App/Health/HealthStore.swift
  - App/Z24x4TrainerApp.swift
  - App/DesignSystem/AccessibleControls.swift
  - App/DesignSystem/Motion.swift
  - App/DesignSystem/Theme.swift
  - SharedCore/Tests/SharedCoreTests/StreaksAchievementsTests.swift
  - App/Notifications/ReminderScheduler.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
  - project.yml
  - App/Views/TodayView.swift
  - App/Views/HistoryView.swift
-->

---
### Requirement: Guided session completion records a workout

When a guided player session (Zone 2 or Norwegian 4×4) runs to its full prescribed duration and finishes normally, the app SHALL insert exactly one `WorkoutLog` record so the session appears in the Today, Week, and History statistics. The record SHALL carry the session type, the completed duration in minutes, the completion date, the active energy in kilocalories when available, and a source marker identifying it as a guided session. The app SHALL update the widget snapshot after inserting the record so widgets and complications reflect the new session. When a guided session is cancelled before its prescribed duration completes, the app SHALL NOT insert a `WorkoutLog`.

#### Scenario: Completing a guided 4×4 records one workout

- **WHEN** the user starts the guided Norwegian 4×4 player and lets it run through warmup, all four intervals, and cooldown to completion
- **THEN** the app inserts exactly one `WorkoutLog` with type Norwegian 4×4, the completed duration, and source marked guided
- **AND** the session appears in Today, Week, and History without a separate manual entry

#### Scenario: Completing a guided Zone 2 records one workout

- **WHEN** the user starts the guided Zone 2 player and lets it run to its prescribed duration
- **THEN** the app inserts exactly one `WorkoutLog` with type Zone 2, the completed duration, and source marked guided

#### Scenario: Cancelling a guided session records nothing

- **WHEN** the user starts a guided session and ends it before the prescribed duration completes
- **THEN** the app inserts no `WorkoutLog`
- **AND** the Today, Week, and History statistics are unchanged

<!-- @trace
source: guided-player-autolog
updated: 2026-06-21
code:
  - App/Localizable.xcstrings
  - App/GuidedSessionLogger.swift
  - App/Views/TodayView.swift
  - App/Persistence/WorkoutLog.swift
  - Tests/GuidedPlayerLoggingTests.swift
  - Tests/WorkoutSourceTests.swift
  - PROGRESS.md
  - App/Views/GuidedPlayerView.swift
  - App/Views/RecentWorkoutsSection.swift
  - App/Views/WeekView.swift
  - docs/manual-verification-checklist.md
  - App/Views/WorkoutDetailView.swift
-->