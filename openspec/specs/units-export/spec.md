# units-export Specification

## Purpose

TBD - created by archiving change 'units-export'. Update Purpose after archive.

## Requirements

### Requirement: Unit preference with metric storage
The app SHALL offer a metric/imperial unit preference that defaults from the device locale's measurement system and converts body metrics at the display layer only; stored values and all training calculations SHALL remain metric.

#### Scenario: Locale defaults the preference
- **WHEN** a new profile is created on a device whose locale uses the US measurement system
- **THEN** the unit preference defaults to imperial; on a metric locale it defaults to metric

#### Scenario: Display converts, storage does not
- **WHEN** the preference is imperial and the stored weight is 75 kg
- **THEN** weight displays as 165 lb while the stored value remains 75 kg and zone/energy calculations are unchanged

##### Example: Round-trip conversion tolerance

| Input | Expected Output | Notes |
| ----- | --------------- | ----- |
| 75 kg → lb → kg | 75 ± 0.01 kg | kgToLb then lbToKg |
| 180 cm → ft+in | 5 ft 11 in | rounded to whole inches |
| 5 ft 11 in → cm | 180 ± 1 cm | feetInchesToCm |

#### Scenario: Switching preference re-renders
- **WHEN** the user changes the unit preference in Settings
- **THEN** onboarding-style weight fields, the Settings weight field, the weekly loss rate, and the History weight chart re-render in the chosen units


<!-- @trace
source: units-export
updated: 2026-06-11
code:
  - App/Notifications/ReminderScheduler.swift
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - Tests/HealthWritebackTests.swift
  - App/Persistence/ProfileRecord.swift
  - App/Health/PreviewHealthService.swift
  - Watch/WorkoutSync.swift
  - PROGRESS.md
  - App/Sync/PhoneStatusPublisher.swift
  - App/Views/SettingsView.swift
  - SharedCore/Sources/SharedCore/WorkoutExport.swift
  - App/WidgetSnapshotWriter.swift
  - Widgets/Z24x4Widgets.swift
  - SharedCore/Sources/SharedCore/UnitPreference.swift
  - App/Views/OnboardingView.swift
  - Watch/Z24x4TrainerWatch.entitlements
  - App/Views/ManualEntryView.swift
  - WatchComplications/Z24x4WatchComplications.swift
  - App/Health/HealthKitService.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - App/Views/GuidedPlayerView.swift
  - SharedCore/Sources/SharedCore/Readiness.swift
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - App/Views/HistoryView.swift
  - SharedCore/Tests/SharedCoreTests/UnitsExportTests.swift
  - WatchComplications/Z24x4WatchComplications.entitlements
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
  - App/GuidedSessionEngine.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - project.yml
  - App/Health/HealthProviding.swift
  - SharedCore/Sources/SharedCore/UnitConvert.swift
  - Watch/WorkoutListView.swift
  - App/Views/RootView.swift
-->

---
### Requirement: Imperial body-metric entry
When the preference is imperial, weight entry SHALL be in pounds and height entry SHALL be in feet and inches, converted to metric before storage; onboarding validation SHALL keep rejecting non-positive values.

#### Scenario: Imperial onboarding entry
- **WHEN** the preference is imperial and the user enters 165 lb and 5 ft 11 in
- **THEN** the stored profile holds approximately 75 kg and 180 cm

#### Scenario: Non-positive imperial input rejected
- **WHEN** the imperial weight or height fields are zero or empty
- **THEN** the onboarding submit action stays disabled


<!-- @trace
source: units-export
updated: 2026-06-11
code:
  - App/Notifications/ReminderScheduler.swift
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - Tests/HealthWritebackTests.swift
  - App/Persistence/ProfileRecord.swift
  - App/Health/PreviewHealthService.swift
  - Watch/WorkoutSync.swift
  - PROGRESS.md
  - App/Sync/PhoneStatusPublisher.swift
  - App/Views/SettingsView.swift
  - SharedCore/Sources/SharedCore/WorkoutExport.swift
  - App/WidgetSnapshotWriter.swift
  - Widgets/Z24x4Widgets.swift
  - SharedCore/Sources/SharedCore/UnitPreference.swift
  - App/Views/OnboardingView.swift
  - Watch/Z24x4TrainerWatch.entitlements
  - App/Views/ManualEntryView.swift
  - WatchComplications/Z24x4WatchComplications.swift
  - App/Health/HealthKitService.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - App/Views/GuidedPlayerView.swift
  - SharedCore/Sources/SharedCore/Readiness.swift
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - App/Views/HistoryView.swift
  - SharedCore/Tests/SharedCoreTests/UnitsExportTests.swift
  - WatchComplications/Z24x4WatchComplications.entitlements
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
  - App/GuidedSessionEngine.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - project.yml
  - App/Health/HealthProviding.swift
  - SharedCore/Sources/SharedCore/UnitConvert.swift
  - Watch/WorkoutListView.swift
  - App/Views/RootView.swift
-->

---
### Requirement: Workout history export
The app SHALL export the workout history as CSV and as JSON through the system share sheet. CSV SHALL include a header row, ISO 8601 dates, and RFC 4180 quoting so notes containing commas, quotes, or newlines round-trip safely; JSON SHALL encode the same rows.

#### Scenario: CSV escapes notes
- **WHEN** a workout note contains a comma, a double quote, or a newline and the history is exported as CSV
- **THEN** the affected field is quoted and inner quotes are doubled per RFC 4180

#### Scenario: Export offered in both formats
- **WHEN** the user opens the export menu on the History screen
- **THEN** share options for CSV and JSON are offered and produce files containing one row per logged workout

#### Scenario: Empty history exports header only
- **WHEN** the history contains no workouts and CSV export is invoked
- **THEN** the CSV contains only the header row and JSON contains an empty array

<!-- @trace
source: units-export
updated: 2026-06-11
code:
  - App/Notifications/ReminderScheduler.swift
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - Tests/HealthWritebackTests.swift
  - App/Persistence/ProfileRecord.swift
  - App/Health/PreviewHealthService.swift
  - Watch/WorkoutSync.swift
  - PROGRESS.md
  - App/Sync/PhoneStatusPublisher.swift
  - App/Views/SettingsView.swift
  - SharedCore/Sources/SharedCore/WorkoutExport.swift
  - App/WidgetSnapshotWriter.swift
  - Widgets/Z24x4Widgets.swift
  - SharedCore/Sources/SharedCore/UnitPreference.swift
  - App/Views/OnboardingView.swift
  - Watch/Z24x4TrainerWatch.entitlements
  - App/Views/ManualEntryView.swift
  - WatchComplications/Z24x4WatchComplications.swift
  - App/Health/HealthKitService.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - App/Views/GuidedPlayerView.swift
  - SharedCore/Sources/SharedCore/Readiness.swift
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - App/Views/HistoryView.swift
  - SharedCore/Tests/SharedCoreTests/UnitsExportTests.swift
  - WatchComplications/Z24x4WatchComplications.entitlements
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
  - App/GuidedSessionEngine.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - project.yml
  - App/Health/HealthProviding.swift
  - SharedCore/Sources/SharedCore/UnitConvert.swift
  - Watch/WorkoutListView.swift
  - App/Views/RootView.swift
-->