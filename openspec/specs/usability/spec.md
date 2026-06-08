# usability Specification

## Purpose

TBD - created by archiving change 'usability-onboarding-polish'. Update Purpose after archive.

## Requirements

### Requirement: Onboarding input validation
The onboarding form SHALL prevent profile creation with invalid body metrics. The "Get started" action SHALL be disabled while weight or height is not a positive value.

#### Scenario: Cannot submit with non-positive metrics
- **WHEN** weight or height on the onboarding form is zero or empty
- **THEN** the "Get started" button is disabled and no profile is created

#### Scenario: Valid metrics enable submission
- **WHEN** weight and height are both positive
- **THEN** the "Get started" button is enabled and tapping it creates the profile


<!-- @trace
source: usability-onboarding-polish
updated: 2026-06-07
code:
  - App/Views/TodayView.swift
  - App/Views/WeekView.swift
  - App/Views/HistoryView.swift
  - App/DesignSystem/Components.swift
  - App/Views/ManualEntryView.swift
  - App/DesignSystem/AccessibleControls.swift
  - App/DesignSystem/Buttons.swift
  - App/DesignSystem/Motion.swift
  - App/DesignSystem/Theme.swift
  - App/Views/AchievementsView.swift
  - App/Views/Celebration.swift
  - App/Views/StreakBanner.swift
  - App/Views/OnboardingView.swift
  - App/Views/SettingsView.swift
-->

---
### Requirement: Onboarding explains why it asks
The onboarding form SHALL show a brief explanation that the collected metrics are used to compute personalized heart-rate zones.

#### Scenario: Purpose is visible on first run
- **WHEN** a new user opens onboarding
- **THEN** a short explanation of why the metrics are needed is visible before the inputs


<!-- @trace
source: usability-onboarding-polish
updated: 2026-06-07
code:
  - App/Views/TodayView.swift
  - App/Views/WeekView.swift
  - App/Views/HistoryView.swift
  - App/DesignSystem/Components.swift
  - App/Views/ManualEntryView.swift
  - App/DesignSystem/AccessibleControls.swift
  - App/DesignSystem/Buttons.swift
  - App/DesignSystem/Motion.swift
  - App/DesignSystem/Theme.swift
  - App/Views/AchievementsView.swift
  - App/Views/Celebration.swift
  - App/Views/StreakBanner.swift
  - App/Views/OnboardingView.swift
  - App/Views/SettingsView.swift
-->

---
### Requirement: Conditional fields animate
Conditional form fields that appear or disappear based on a toggle SHALL transition with animation rather than appearing instantly.

#### Scenario: Rate field animates in
- **WHEN** the user enables "Lose weight" on onboarding or in settings
- **THEN** the rate field appears with an animated transition


<!-- @trace
source: usability-onboarding-polish
updated: 2026-06-07
code:
  - App/Views/TodayView.swift
  - App/Views/WeekView.swift
  - App/Views/HistoryView.swift
  - App/DesignSystem/Components.swift
  - App/Views/ManualEntryView.swift
  - App/DesignSystem/AccessibleControls.swift
  - App/DesignSystem/Buttons.swift
  - App/DesignSystem/Motion.swift
  - App/DesignSystem/Theme.swift
  - App/Views/AchievementsView.swift
  - App/Views/Celebration.swift
  - App/Views/StreakBanner.swift
  - App/Views/OnboardingView.swift
  - App/Views/SettingsView.swift
-->

---
### Requirement: Manual entry rejects non-numeric energy
The manual-entry energy field SHALL accept only numeric input, and SHALL only record an energy value when a number is present. A future date SHALL NOT be selectable for a completed workout.

#### Scenario: Non-numeric energy is filtered
- **WHEN** the user types non-numeric characters into the active-energy field
- **THEN** the field retains only the numeric characters

#### Scenario: Empty energy records no value
- **WHEN** the energy field is left empty and the workout is saved
- **THEN** the workout is recorded with no energy value rather than zero

#### Scenario: Future dates are not selectable
- **WHEN** the user opens the date picker for a manual workout
- **THEN** dates after the current moment cannot be chosen


<!-- @trace
source: usability-onboarding-polish
updated: 2026-06-07
code:
  - App/Views/TodayView.swift
  - App/Views/WeekView.swift
  - App/Views/HistoryView.swift
  - App/DesignSystem/Components.swift
  - App/Views/ManualEntryView.swift
  - App/DesignSystem/AccessibleControls.swift
  - App/DesignSystem/Buttons.swift
  - App/DesignSystem/Motion.swift
  - App/DesignSystem/Theme.swift
  - App/Views/AchievementsView.swift
  - App/Views/Celebration.swift
  - App/Views/StreakBanner.swift
  - App/Views/OnboardingView.swift
  - App/Views/SettingsView.swift
-->

---
### Requirement: Rest-day cards do not imply interactivity
Rest-day cards SHALL present a consistent affordance: either visibly non-interactive, or navigating to a defined destination. A rest-day card SHALL NOT look tappable while doing nothing.

#### Scenario: Rest-day card affordance matches behavior
- **WHEN** a rest-day card is shown on the Today, Week, or Workout-detail screen
- **THEN** its appearance matches whether it navigates anywhere (non-interactive styling when it does not)


<!-- @trace
source: usability-onboarding-polish
updated: 2026-06-07
code:
  - App/Views/TodayView.swift
  - App/Views/WeekView.swift
  - App/Views/HistoryView.swift
  - App/DesignSystem/Components.swift
  - App/Views/ManualEntryView.swift
  - App/DesignSystem/AccessibleControls.swift
  - App/DesignSystem/Buttons.swift
  - App/DesignSystem/Motion.swift
  - App/DesignSystem/Theme.swift
  - App/Views/AchievementsView.swift
  - App/Views/Celebration.swift
  - App/Views/StreakBanner.swift
  - App/Views/OnboardingView.swift
  - App/Views/SettingsView.swift
-->

---
### Requirement: Empty states offer an action
Empty states that ask the user to do something SHALL provide a tappable control to start that action.

#### Scenario: History empty state has a CTA
- **WHEN** the History screen has no workout data
- **THEN** it shows a tappable control to log a workout or connect Apple Health

#### Scenario: Streak empty state has a CTA
- **WHEN** the streak banner shows no active streak
- **THEN** it provides a tappable control to log a workout


<!-- @trace
source: usability-onboarding-polish
updated: 2026-06-07
code:
  - App/Views/TodayView.swift
  - App/Views/WeekView.swift
  - App/Views/HistoryView.swift
  - App/DesignSystem/Components.swift
  - App/Views/ManualEntryView.swift
  - App/DesignSystem/AccessibleControls.swift
  - App/DesignSystem/Buttons.swift
  - App/DesignSystem/Motion.swift
  - App/DesignSystem/Theme.swift
  - App/Views/AchievementsView.swift
  - App/Views/Celebration.swift
  - App/Views/StreakBanner.swift
  - App/Views/OnboardingView.swift
  - App/Views/SettingsView.swift
-->

---
### Requirement: Required-setting warnings are prominent
When a selected setting requires another input that is missing, the warning SHALL be visually prominent rather than de-emphasized.

#### Scenario: Karvonen warning is prominent
- **WHEN** the heart-rate-reserve (Karvonen) method is selected without a resting heart rate set
- **THEN** the "resting HR required" warning is shown in a prominent style, not muted secondary text


<!-- @trace
source: usability-onboarding-polish
updated: 2026-06-07
code:
  - App/Views/TodayView.swift
  - App/Views/WeekView.swift
  - App/Views/HistoryView.swift
  - App/DesignSystem/Components.swift
  - App/Views/ManualEntryView.swift
  - App/DesignSystem/AccessibleControls.swift
  - App/DesignSystem/Buttons.swift
  - App/DesignSystem/Motion.swift
  - App/DesignSystem/Theme.swift
  - App/Views/AchievementsView.swift
  - App/Views/Celebration.swift
  - App/Views/StreakBanner.swift
  - App/Views/OnboardingView.swift
  - App/Views/SettingsView.swift
-->

---
### Requirement: Connected Health shows sync scope
When Apple Health is connected, settings SHALL show which data categories are in scope.

#### Scenario: Sync scope is listed when connected
- **WHEN** Apple Health is connected
- **THEN** settings list the synced data categories


<!-- @trace
source: usability-onboarding-polish
updated: 2026-06-07
code:
  - App/Views/TodayView.swift
  - App/Views/WeekView.swift
  - App/Views/HistoryView.swift
  - App/DesignSystem/Components.swift
  - App/Views/ManualEntryView.swift
  - App/DesignSystem/AccessibleControls.swift
  - App/DesignSystem/Buttons.swift
  - App/DesignSystem/Motion.swift
  - App/DesignSystem/Theme.swift
  - App/Views/AchievementsView.swift
  - App/Views/Celebration.swift
  - App/Views/StreakBanner.swift
  - App/Views/OnboardingView.swift
  - App/Views/SettingsView.swift
-->

---
### Requirement: Action hierarchy is clear
Secondary actions SHALL use the design system's `SecondaryButton`, visually subordinate to primary actions, rather than improvised styling.

#### Scenario: Secondary action uses SecondaryButton
- **WHEN** a screen presents a secondary action alongside a primary one (e.g., "Log a workout" beside "Start workout" on Today)
- **THEN** the secondary action renders with `SecondaryButton` styling

<!-- @trace
source: usability-onboarding-polish
updated: 2026-06-07
code:
  - App/Views/TodayView.swift
  - App/Views/WeekView.swift
  - App/Views/HistoryView.swift
  - App/DesignSystem/Components.swift
  - App/Views/ManualEntryView.swift
  - App/DesignSystem/AccessibleControls.swift
  - App/DesignSystem/Buttons.swift
  - App/DesignSystem/Motion.swift
  - App/DesignSystem/Theme.swift
  - App/Views/AchievementsView.swift
  - App/Views/Celebration.swift
  - App/Views/StreakBanner.swift
  - App/Views/OnboardingView.swift
  - App/Views/SettingsView.swift
-->