# watch-workout-ui Specification

## Purpose

TBD - created by archiving change 'watch-screen-polish'. Update Purpose after archive.

## Requirements

### Requirement: Live screen exposes VoiceOver labels
The watch live-workout screen SHALL expose VoiceOver labels for its non-text and glanceable elements: the heart rate, the current zone, the interval banner, and each workout row on the list screen.

#### Scenario: Heart rate is spoken with units
- **WHEN** VoiceOver focuses the live heart-rate display showing 142
- **THEN** it announces "Heart rate, 142 beats per minute" rather than a bare number

#### Scenario: Zone and interval are labelled
- **WHEN** VoiceOver focuses the zone label or the interval banner during a session
- **THEN** it announces the zone name (e.g. "Zone 2") or the interval kind and countdown

#### Scenario: Workout rows are labelled
- **WHEN** VoiceOver focuses a row on the workout-picker list
- **THEN** it announces the workout name


<!-- @trace
source: watch-screen-polish
updated: 2026-06-07
code:
  - App/DesignSystem/Components.swift
  - App/Views/HistoryView.swift
  - App/Views/SettingsView.swift
  - App/Views/ShareCard.swift
  - App/Views/OnboardingView.swift
  - App/Views/Celebration.swift
  - App/Views/WorkoutDetailView.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - Watch/WorkoutListView.swift
  - App/DesignSystem/Buttons.swift
  - Watch/WorkoutSessionManager.swift
  - App/DesignSystem/ZoneStyle.swift
  - Watch/LiveWorkoutView.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
-->

---
### Requirement: Live screen supports Dynamic Type
The watch live-workout screen SHALL use scalable text styles for its primary readouts (heart rate, interval countdown) so they grow with the user's text size instead of clipping.

#### Scenario: Large text does not clip
- **WHEN** the watch text size is set large
- **THEN** the heart-rate number and the interval countdown remain fully visible without truncation


<!-- @trace
source: watch-screen-polish
updated: 2026-06-07
code:
  - App/DesignSystem/Components.swift
  - App/Views/HistoryView.swift
  - App/Views/SettingsView.swift
  - App/Views/ShareCard.swift
  - App/Views/OnboardingView.swift
  - App/Views/Celebration.swift
  - App/Views/WorkoutDetailView.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - Watch/WorkoutListView.swift
  - App/DesignSystem/Buttons.swift
  - Watch/WorkoutSessionManager.swift
  - App/DesignSystem/ZoneStyle.swift
  - Watch/LiveWorkoutView.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
-->

---
### Requirement: Zone shown without color alone
The watch zone label SHALL convey the zone with a non-color signal (the zone glyph) in addition to its colored capsule, so the zone is distinguishable without color perception.

#### Scenario: Zone glyph present
- **WHEN** a zone is active on the live screen
- **THEN** the zone is shown with its glyph (and name), and the colored capsule is marked decorative for VoiceOver


<!-- @trace
source: watch-screen-polish
updated: 2026-06-07
code:
  - App/DesignSystem/Components.swift
  - App/Views/HistoryView.swift
  - App/Views/SettingsView.swift
  - App/Views/ShareCard.swift
  - App/Views/OnboardingView.swift
  - App/Views/Celebration.swift
  - App/Views/WorkoutDetailView.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - Watch/WorkoutListView.swift
  - App/DesignSystem/Buttons.swift
  - Watch/WorkoutSessionManager.swift
  - App/DesignSystem/ZoneStyle.swift
  - Watch/LiveWorkoutView.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
-->

---
### Requirement: In-zone status feedback
The live screen SHALL indicate whether the current heart rate is within the target range, using a non-color signal in addition to color.

#### Scenario: In-zone vs out-of-zone
- **WHEN** the current heart rate is inside the target range, then drifts outside it
- **THEN** an indicator (glyph) shows in-zone, then out-of-zone, and exposes that state to VoiceOver


<!-- @trace
source: watch-screen-polish
updated: 2026-06-07
code:
  - App/DesignSystem/Components.swift
  - App/Views/HistoryView.swift
  - App/Views/SettingsView.swift
  - App/Views/ShareCard.swift
  - App/Views/OnboardingView.swift
  - App/Views/Celebration.swift
  - App/Views/WorkoutDetailView.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - Watch/WorkoutListView.swift
  - App/DesignSystem/Buttons.swift
  - Watch/WorkoutSessionManager.swift
  - App/DesignSystem/ZoneStyle.swift
  - Watch/LiveWorkoutView.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
-->

---
### Requirement: Zone-change haptic
The watch SHALL play a haptic when the current training zone changes during a session.

#### Scenario: Crossing a zone boundary buzzes
- **WHEN** the current zone changes from one zone to another during an active session
- **THEN** a haptic plays


<!-- @trace
source: watch-screen-polish
updated: 2026-06-07
code:
  - App/DesignSystem/Components.swift
  - App/Views/HistoryView.swift
  - App/Views/SettingsView.swift
  - App/Views/ShareCard.swift
  - App/Views/OnboardingView.swift
  - App/Views/Celebration.swift
  - App/Views/WorkoutDetailView.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - Watch/WorkoutListView.swift
  - App/DesignSystem/Buttons.swift
  - Watch/WorkoutSessionManager.swift
  - App/DesignSystem/ZoneStyle.swift
  - Watch/LiveWorkoutView.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
-->

---
### Requirement: Elapsed time for open-ended sessions
For an unstructured (Zone 2) session, the live screen SHALL show the elapsed session time.

#### Scenario: Zone 2 shows elapsed time
- **WHEN** a Zone 2 session has been running for some minutes
- **THEN** the live screen shows the running elapsed time (minutes and seconds)

<!-- @trace
source: watch-screen-polish
updated: 2026-06-07
code:
  - App/DesignSystem/Components.swift
  - App/Views/HistoryView.swift
  - App/Views/SettingsView.swift
  - App/Views/ShareCard.swift
  - App/Views/OnboardingView.swift
  - App/Views/Celebration.swift
  - App/Views/WorkoutDetailView.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - Watch/WorkoutListView.swift
  - App/DesignSystem/Buttons.swift
  - Watch/WorkoutSessionManager.swift
  - App/DesignSystem/ZoneStyle.swift
  - Watch/LiveWorkoutView.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
-->

---
### Requirement: Watch status section
The watch workout-list screen SHALL show a status section with the readiness score and label, the current streak in weeks, and this week's done/target training minutes, sourced from the cached snapshot. When no snapshot has been received the section SHALL show a neutral placeholder instead of stale or fabricated values.

#### Scenario: Status section shows synced insight
- **WHEN** the watch has a cached snapshot with readinessValue 100, streakWeeks 2, and weekly minutes 90 of 163
- **THEN** the status section displays the readiness score and label, the 2-week streak, and the 90/163 minute progress

#### Scenario: Placeholder before first sync
- **WHEN** the watch has never received a snapshot
- **THEN** the status section shows a placeholder state and the workout list remains usable


<!-- @trace
source: watch-parity-widgets
updated: 2026-06-10
code:
  - SharedCore/Sources/SharedCore/Readiness.swift
  - SharedCore/Sources/SharedCore/UnitConvert.swift
  - App/WidgetSnapshotWriter.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - Watch/WorkoutListView.swift
  - App/GuidedSessionEngine.swift
  - App/Views/SettingsView.swift
  - Watch/WorkoutSync.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - App/Sync/PhoneStatusPublisher.swift
  - App/Views/RootView.swift
  - SharedCore/Sources/SharedCore/WorkoutExport.swift
  - App/Health/PreviewHealthService.swift
  - PROGRESS.md
  - Tests/HealthWritebackTests.swift
  - App/Health/HealthProviding.swift
  - App/Notifications/ReminderScheduler.swift
  - App/Health/HealthKitService.swift
  - App/Views/GuidedPlayerView.swift
  - App/Views/ManualEntryView.swift
  - project.yml
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - WatchComplications/Z24x4WatchComplications.entitlements
  - Watch/Z24x4TrainerWatch.entitlements
  - SharedCore/Tests/SharedCoreTests/UnitsExportTests.swift
  - SharedCore/Sources/SharedCore/UnitPreference.swift
  - Widgets/Z24x4Widgets.swift
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
  - WatchComplications/Z24x4WatchComplications.swift
-->

---
### Requirement: Watch uses synced profile
The watch app SHALL derive heart-rate zones from profile values synced from the phone (age, max-HR override, zone method) when available, and SHALL fall back to its built-in default profile only when no synced profile exists.

#### Scenario: Synced profile drives zones
- **WHEN** the phone has pushed a profile with a max-HR override of 185
- **THEN** the watch zone calculations use 185 as max HR instead of the default profile

#### Scenario: Fallback without sync
- **WHEN** no profile has ever been synced
- **THEN** the watch uses its built-in default profile and the workout list still renders

<!-- @trace
source: watch-parity-widgets
updated: 2026-06-10
code:
  - SharedCore/Sources/SharedCore/Readiness.swift
  - SharedCore/Sources/SharedCore/UnitConvert.swift
  - App/WidgetSnapshotWriter.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - Watch/WorkoutListView.swift
  - App/GuidedSessionEngine.swift
  - App/Views/SettingsView.swift
  - Watch/WorkoutSync.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift
  - App/Sync/PhoneStatusPublisher.swift
  - App/Views/RootView.swift
  - SharedCore/Sources/SharedCore/WorkoutExport.swift
  - App/Health/PreviewHealthService.swift
  - PROGRESS.md
  - Tests/HealthWritebackTests.swift
  - App/Health/HealthProviding.swift
  - App/Notifications/ReminderScheduler.swift
  - App/Health/HealthKitService.swift
  - App/Views/GuidedPlayerView.swift
  - App/Views/ManualEntryView.swift
  - project.yml
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - WatchComplications/Z24x4WatchComplications.entitlements
  - Watch/Z24x4TrainerWatch.entitlements
  - SharedCore/Tests/SharedCoreTests/UnitsExportTests.swift
  - SharedCore/Sources/SharedCore/UnitPreference.swift
  - Widgets/Z24x4Widgets.swift
  - SharedCore/Sources/SharedCore/WidgetSnapshot.swift
  - WatchComplications/Z24x4WatchComplications.swift
-->