# localization Specification

## Purpose

TBD - created by archiving change 'localization'. Update Purpose after archive.

## Requirements

### Requirement: String Catalog drives UI localization
The app SHALL use a String Catalog (`Localizable.xcstrings`) with English as the source language, from which user-facing UI strings are localized — including strings produced by helper functions or string interpolation, which SHALL be wrapped with `String(localized:)` so they resolve through the catalog rather than displaying the English source verbatim.

#### Scenario: Catalog provides translations
- **WHEN** the app is built
- **THEN** the String Catalog compiles and its localized strings are available to the UI

#### Scenario: Function-produced strings localize
- **WHEN** the device language is Traditional Chinese and a readiness title, coaching tip, week summary, session display name, or rest-day caption is shown
- **THEN** the translated text is displayed rather than the English source


<!-- @trace
source: localization-coverage
updated: 2026-06-09
code:
  - App/Localizable.xcstrings
  - App/Views/TodayView.swift
-->

---
### Requirement: Section headers are localizable
Section headers SHALL accept a localizable key so their text is translated like other UI strings.

#### Scenario: Header localizes
- **WHEN** the device language is a supported non-English language with a translated header
- **THEN** the section header shows the translated text rather than the English source


<!-- @trace
source: localization
updated: 2026-06-09
code:
  - App/Views/SettingsView.swift
  - App/DesignSystem/Components.swift
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
  - App/Views/GuidedPlayerView.swift
  - App/Persistence/ProfileRecord.swift
  - App/DesignSystem/ZoneStyle.swift
  - Watch/IntervalEngine.swift
  - App/Views/TodayView.swift
  - Widgets/Info.plist
  - App/Views/HistoryView.swift
  - App/Health/PreviewHealthService.swift
  - App/Views/AchievementsView.swift
  - App/DesignSystem/Theme.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - App/DesignSystem/Motion.swift
  - Watch/WorkoutListView.swift
  - App/DesignSystem/Buttons.swift
  - App/Views/ManualEntryView.swift
  - SharedCore/Sources/SharedCore/ZoneMethod.swift
  - SharedCore/Sources/SharedCore/PlanProgression.swift
  - SharedCore/Sources/SharedCore/StreakCalculator.swift
  - project.yml
  - App/Health/HealthKitService.swift
  - App/Health/HealthProviding.swift
  - App/Views/ShareCard.swift
  - App/Z24x4TrainerApp.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - App/Views/Celebration.swift
  - SharedCore/Sources/SharedCore/Readiness.swift
  - Widgets/Z24x4Widgets.swift
  - Watch/WorkoutSessionManager.swift
  - SharedCore/Sources/SharedCore/MetricSample.swift
  - App/DesignSystem/AccessibleControls.swift
  - SharedCore/Sources/SharedCore/Achievement.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - SharedCore/Tests/SharedCoreTests/GuidedCueTests.swift
  - PROGRESS.md
  - WatchComplications/Z24x4WatchComplications.swift
  - Watch/LiveWorkoutView.swift
  - WatchComplications/Info.plist
  - App/Z24x4Trainer.entitlements
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - SharedCore/Sources/SharedCore/HRZoneCalculator.swift
  - SharedCore/Tests/SharedCoreTests/PrecisionZonesTests.swift
  - App/Persistence/AchievementRecord.swift
  - SharedCore/Sources/SharedCore/AchievementEvaluator.swift
  - SharedCore/Sources/SharedCore/UserProfile.swift
  - App/Views/OnboardingView.swift
  - Widgets/Z24x4Widgets.entitlements
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - App/Health/HealthStore.swift
  - SharedCore/Sources/SharedCore/WorkoutRecord.swift
  - SharedCore/Tests/SharedCoreTests/StreaksAchievementsTests.swift
  - App/Views/RootView.swift
  - App/Sync/PhoneSessionReceiver.swift
  - SharedCore/Sources/SharedCore/GuidedCue.swift
  - App/Views/WeekView.swift
  - App/Notifications/ReminderScheduler.swift
  - App/WidgetSnapshotWriter.swift
  - App/GuidedSessionEngine.swift
  - App/Localizable.xcstrings
  - App/Views/WorkoutDetailView.swift
  - App/Views/StreakBanner.swift
-->

---
### Requirement: Traditional Chinese is provided
The core UI chrome SHALL be fully translated into Traditional Chinese (zh-Hant).

#### Scenario: zh-Hant shows translated chrome
- **WHEN** the app runs with the language set to Traditional Chinese
- **THEN** the tab labels, screen titles, and primary actions appear in Traditional Chinese


<!-- @trace
source: localization
updated: 2026-06-09
code:
  - App/Views/SettingsView.swift
  - App/DesignSystem/Components.swift
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
  - App/Views/GuidedPlayerView.swift
  - App/Persistence/ProfileRecord.swift
  - App/DesignSystem/ZoneStyle.swift
  - Watch/IntervalEngine.swift
  - App/Views/TodayView.swift
  - Widgets/Info.plist
  - App/Views/HistoryView.swift
  - App/Health/PreviewHealthService.swift
  - App/Views/AchievementsView.swift
  - App/DesignSystem/Theme.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - App/DesignSystem/Motion.swift
  - Watch/WorkoutListView.swift
  - App/DesignSystem/Buttons.swift
  - App/Views/ManualEntryView.swift
  - SharedCore/Sources/SharedCore/ZoneMethod.swift
  - SharedCore/Sources/SharedCore/PlanProgression.swift
  - SharedCore/Sources/SharedCore/StreakCalculator.swift
  - project.yml
  - App/Health/HealthKitService.swift
  - App/Health/HealthProviding.swift
  - App/Views/ShareCard.swift
  - App/Z24x4TrainerApp.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - App/Views/Celebration.swift
  - SharedCore/Sources/SharedCore/Readiness.swift
  - Widgets/Z24x4Widgets.swift
  - Watch/WorkoutSessionManager.swift
  - SharedCore/Sources/SharedCore/MetricSample.swift
  - App/DesignSystem/AccessibleControls.swift
  - SharedCore/Sources/SharedCore/Achievement.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - SharedCore/Tests/SharedCoreTests/GuidedCueTests.swift
  - PROGRESS.md
  - WatchComplications/Z24x4WatchComplications.swift
  - Watch/LiveWorkoutView.swift
  - WatchComplications/Info.plist
  - App/Z24x4Trainer.entitlements
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - SharedCore/Sources/SharedCore/HRZoneCalculator.swift
  - SharedCore/Tests/SharedCoreTests/PrecisionZonesTests.swift
  - App/Persistence/AchievementRecord.swift
  - SharedCore/Sources/SharedCore/AchievementEvaluator.swift
  - SharedCore/Sources/SharedCore/UserProfile.swift
  - App/Views/OnboardingView.swift
  - Widgets/Z24x4Widgets.entitlements
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - App/Health/HealthStore.swift
  - SharedCore/Sources/SharedCore/WorkoutRecord.swift
  - SharedCore/Tests/SharedCoreTests/StreaksAchievementsTests.swift
  - App/Views/RootView.swift
  - App/Sync/PhoneSessionReceiver.swift
  - SharedCore/Sources/SharedCore/GuidedCue.swift
  - App/Views/WeekView.swift
  - App/Notifications/ReminderScheduler.swift
  - App/WidgetSnapshotWriter.swift
  - App/GuidedSessionEngine.swift
  - App/Localizable.xcstrings
  - App/Views/WorkoutDetailView.swift
  - App/Views/StreakBanner.swift
-->

---
### Requirement: Additional languages registered with safe fallback
Spanish (es) and Japanese (ja) SHALL be registered, and any untranslated string SHALL fall back to the English source without error.

#### Scenario: Missing translation falls back
- **WHEN** the app runs in a registered language for which a given string has no translation
- **THEN** the English source string is shown and the app does not crash

<!-- @trace
source: localization
updated: 2026-06-09
code:
  - App/Views/SettingsView.swift
  - App/DesignSystem/Components.swift
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
  - App/Views/GuidedPlayerView.swift
  - App/Persistence/ProfileRecord.swift
  - App/DesignSystem/ZoneStyle.swift
  - Watch/IntervalEngine.swift
  - App/Views/TodayView.swift
  - Widgets/Info.plist
  - App/Views/HistoryView.swift
  - App/Health/PreviewHealthService.swift
  - App/Views/AchievementsView.swift
  - App/DesignSystem/Theme.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - App/DesignSystem/Motion.swift
  - Watch/WorkoutListView.swift
  - App/DesignSystem/Buttons.swift
  - App/Views/ManualEntryView.swift
  - SharedCore/Sources/SharedCore/ZoneMethod.swift
  - SharedCore/Sources/SharedCore/PlanProgression.swift
  - SharedCore/Sources/SharedCore/StreakCalculator.swift
  - project.yml
  - App/Health/HealthKitService.swift
  - App/Health/HealthProviding.swift
  - App/Views/ShareCard.swift
  - App/Z24x4TrainerApp.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - App/Views/Celebration.swift
  - SharedCore/Sources/SharedCore/Readiness.swift
  - Widgets/Z24x4Widgets.swift
  - Watch/WorkoutSessionManager.swift
  - SharedCore/Sources/SharedCore/MetricSample.swift
  - App/DesignSystem/AccessibleControls.swift
  - SharedCore/Sources/SharedCore/Achievement.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - SharedCore/Tests/SharedCoreTests/GuidedCueTests.swift
  - PROGRESS.md
  - WatchComplications/Z24x4WatchComplications.swift
  - Watch/LiveWorkoutView.swift
  - WatchComplications/Info.plist
  - App/Z24x4Trainer.entitlements
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - SharedCore/Sources/SharedCore/HRZoneCalculator.swift
  - SharedCore/Tests/SharedCoreTests/PrecisionZonesTests.swift
  - App/Persistence/AchievementRecord.swift
  - SharedCore/Sources/SharedCore/AchievementEvaluator.swift
  - SharedCore/Sources/SharedCore/UserProfile.swift
  - App/Views/OnboardingView.swift
  - Widgets/Z24x4Widgets.entitlements
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - App/Health/HealthStore.swift
  - SharedCore/Sources/SharedCore/WorkoutRecord.swift
  - SharedCore/Tests/SharedCoreTests/StreaksAchievementsTests.swift
  - App/Views/RootView.swift
  - App/Sync/PhoneSessionReceiver.swift
  - SharedCore/Sources/SharedCore/GuidedCue.swift
  - App/Views/WeekView.swift
  - App/Notifications/ReminderScheduler.swift
  - App/WidgetSnapshotWriter.swift
  - App/GuidedSessionEngine.swift
  - App/Localizable.xcstrings
  - App/Views/WorkoutDetailView.swift
  - App/Views/StreakBanner.swift
-->

---
### Requirement: Function-produced and SharedCore strings localize
User-facing strings produced by helper functions, string interpolation, or defined in the `SharedCore` package SHALL localize through a String Catalog rather than displaying the English source. App-target interpolated/function strings SHALL use `String(localized:)`; SharedCore strings SHALL use `String(localized:bundle: .module)` with the package's String Catalog and `defaultLocalization`.

#### Scenario: Remaining App screens localize
- **WHEN** the device language is Traditional Chinese and the Week, Settings, History, Onboarding, or Achievements screen is shown
- **THEN** its user-facing labels appear in Traditional Chinese rather than English

#### Scenario: SharedCore strings localize
- **WHEN** the device language is Traditional Chinese and an achievement title/detail or a readiness recommendation is shown
- **THEN** the translated text is displayed rather than the English source

#### Scenario: Untranslated falls back
- **WHEN** a string lacks a translation for the current language
- **THEN** the English source is shown without error

<!-- @trace
source: localization-sweep
updated: 2026-06-10
code:
  - App/Views/GuidedPlayerView.swift
  - App/Views/ShareCard.swift
  - SharedCore/Sources/SharedCore/Achievement.swift
  - App/Views/HistoryView.swift
  - App/Views/WorkoutDetailView.swift
  - SharedCore/Sources/SharedCore/Localizable.xcstrings
  - App/Views/WeekView.swift
  - SharedCore/Package.swift
  - CLAUDE.md
  - App/Views/StreakBanner.swift
  - App/Views/ManualEntryView.swift
  - SharedCore/Sources/SharedCore/Readiness.swift
  - App/Localizable.xcstrings
-->

---
### Requirement: Spanish and Japanese are finalized
The Spanish and Japanese translations in the app and SharedCore String Catalogs SHALL be reviewed and marked as translated (not needs-review) before release, after all strings introduced in the same round are merged.

#### Scenario: No needs-review entries remain
- **WHEN** the round's catalog merge is complete and the es/ja review pass has run
- **THEN** the app and SharedCore String Catalogs contain zero needs-review entries for Spanish and Japanese

#### Scenario: Reviewed UI renders
- **WHEN** the app runs with the device language set to Spanish or Japanese
- **THEN** core screens render the reviewed translations with English fallback only for untranslated keys

<!-- @trace
source: ux-polish
updated: 2026-06-12
code:
  - App/Sync/PhoneSessionReceiver.swift
  - Watch/WorkoutListView.swift
  - App/Health/HealthStore.swift
  - App/Views/OnboardingIntroView.swift
  - App/Health/HealthKitService.swift
  - SharedCore/Tests/SharedCoreTests/UnitsExportTests.swift
  - App/Health/HealthProviding.swift
  - App/Views/TodayView.swift
  - App/Views/RootView.swift
  - App/Health/PreviewHealthService.swift
  - App/Persistence/WorkoutLog.swift
  - WatchComplications/Z24x4WatchComplications.swift
  - Watch/WorkoutSync.swift
  - App/WidgetSnapshotWriter.swift
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
  - App/Views/ManualEntryView.swift
  - Tests/HealthWritebackTests.swift
  - App/Views/OnboardingView.swift
  - SharedCore/Sources/SharedCore/UnitPreference.swift
  - App/Localizable.xcstrings
  - Watch/Z24x4TrainerWatch.entitlements
  - WatchComplications/Z24x4WatchComplications.entitlements
  - Widgets/Z24x4Widgets.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - PROGRESS.md
  - App/Views/GuidedPlayerView.swift
  - SharedCore/Sources/SharedCore/UnitConvert.swift
  - App/Views/RecentWorkoutsSection.swift
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - SharedCore/Sources/SharedCore/Readiness.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - project.yml
  - App/Persistence/ProfileRecord.swift
  - App/Sync/PhoneStatusPublisher.swift
  - App/Views/HistoryView.swift
  - App/GuidedSessionEngine.swift
  - SharedCore/Sources/SharedCore/Localizable.xcstrings
  - SharedCore/Sources/SharedCore/WorkoutExport.swift
  - App/Views/SettingsView.swift
  - App/Notifications/ReminderScheduler.swift
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
-->