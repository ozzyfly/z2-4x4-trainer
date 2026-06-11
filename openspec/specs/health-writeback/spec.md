# health-writeback Specification

## Purpose

TBD - created by archiving change 'health-writeback-robustness'. Update Purpose after archive.

## Requirements

### Requirement: Manual entries save to Apple Health
The app SHALL save manually entered workouts to Apple Health as workout samples when Health share authorization is granted, recording the returned workout UUID on the local log so subsequent Health imports deduplicate against it. When the save fails or authorization is denied, the local log SHALL be kept and a non-blocking notice SHALL be shown.

#### Scenario: Successful save records UUID
- **WHEN** the user saves a manual workout and the Health save succeeds
- **THEN** the local log's health UUID is set to the saved workout's UUID

#### Scenario: Re-import does not duplicate
- **WHEN** a Health import runs after a manual entry was saved to Health
- **THEN** the imported workout with the same UUID is skipped and no duplicate log is created

#### Scenario: Failed save keeps local log
- **WHEN** the Health save throws or share authorization is denied
- **THEN** the local log is kept without a health UUID and a non-blocking notice is shown


<!-- @trace
source: health-writeback-robustness
updated: 2026-06-11
code:
  - App/WidgetSnapshotWriter.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - PROGRESS.md
  - SharedCore/Sources/SharedCore/Readiness.swift
  - App/Health/HealthKitService.swift
  - App/Views/RootView.swift
  - Watch/WorkoutListView.swift
  - Tests/HealthWritebackTests.swift
  - Widgets/Z24x4Widgets.swift
  - App/Health/HealthProviding.swift
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - project.yml
  - WatchComplications/Z24x4WatchComplications.swift
  - App/Notifications/ReminderScheduler.swift
  - App/GuidedSessionEngine.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - SharedCore/Sources/SharedCore/WorkoutExport.swift
  - App/Sync/PhoneStatusPublisher.swift
  - Watch/WorkoutSync.swift
  - Watch/Z24x4TrainerWatch.entitlements
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - SharedCore/Sources/SharedCore/UnitConvert.swift
  - App/Views/GuidedPlayerView.swift
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
  - SharedCore/Sources/SharedCore/UnitPreference.swift
  - SharedCore/Tests/SharedCoreTests/UnitsExportTests.swift
  - App/Views/ManualEntryView.swift
  - App/Views/SettingsView.swift
  - App/Health/PreviewHealthService.swift
  - WatchComplications/Z24x4WatchComplications.entitlements
-->

---
### Requirement: Watch workouts persist to Health
The watch app SHALL persist completed live workout sessions to Apple Health via the live workout builder, so watch-recorded sessions appear in Health without phone involvement.

#### Scenario: Finished session is in Health
- **WHEN** a live watch workout session ends
- **THEN** the workout is finished through the live workout builder and persisted to Apple Health

<!-- @trace
source: health-writeback-robustness
updated: 2026-06-11
code:
  - App/WidgetSnapshotWriter.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - PROGRESS.md
  - SharedCore/Sources/SharedCore/Readiness.swift
  - App/Health/HealthKitService.swift
  - App/Views/RootView.swift
  - Watch/WorkoutListView.swift
  - Tests/HealthWritebackTests.swift
  - Widgets/Z24x4Widgets.swift
  - App/Health/HealthProviding.swift
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - project.yml
  - WatchComplications/Z24x4WatchComplications.swift
  - App/Notifications/ReminderScheduler.swift
  - App/GuidedSessionEngine.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - SharedCore/Sources/SharedCore/WorkoutExport.swift
  - App/Sync/PhoneStatusPublisher.swift
  - Watch/WorkoutSync.swift
  - Watch/Z24x4TrainerWatch.entitlements
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - SharedCore/Sources/SharedCore/UnitConvert.swift
  - App/Views/GuidedPlayerView.swift
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
  - SharedCore/Sources/SharedCore/UnitPreference.swift
  - SharedCore/Tests/SharedCoreTests/UnitsExportTests.swift
  - App/Views/ManualEntryView.swift
  - App/Views/SettingsView.swift
  - App/Health/PreviewHealthService.swift
  - WatchComplications/Z24x4WatchComplications.entitlements
-->