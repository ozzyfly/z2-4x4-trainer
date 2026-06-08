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