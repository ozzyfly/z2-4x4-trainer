# design-system Specification

## Purpose

TBD - created by archiving change 'ui-ux-refresh'. Update Purpose after archive.

## Requirements

### Requirement: Shared design system
The app SHALL provide reusable theme tokens and components (`Card`, `SectionHeader`, `TargetBar`,
`PrimaryButton`, `ZoneChip`, accent color, `HRZone` color map) that every screen uses.

#### Scenario: Components render consistently
- **WHEN** any restyled screen is shown
- **THEN** it uses the shared card, header, accent, and progress components rather than default `Form` styling


<!-- @trace
source: ui-ux-refresh
updated: 2026-06-07
code:
  - App/DesignSystem/Motion.swift
  - App/Views/ShareCard.swift
  - Watch/WorkoutListView.swift
  - App/DesignSystem/AccessibleControls.swift
  - SharedCore/Tests/SharedCoreTests/StreaksAchievementsTests.swift
  - SharedCore/Sources/SharedCore/AchievementEvaluator.swift
  - App/Views/HistoryView.swift
  - SharedCore/Sources/SharedCore/Readiness.swift
  - SharedCore/Sources/SharedCore/MetricSample.swift
  - App/Assets.xcassets/AccentColor.colorset/Contents.json
  - SharedCore/Sources/SharedCore/StreakCalculator.swift
  - App/Views/StreakBanner.swift
  - App/DesignSystem/Theme.swift
  - SharedCore/Tests/SharedCoreTests/PrecisionZonesTests.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - App/DesignSystem/Buttons.swift
  - SharedCore/Sources/SharedCore/HRZoneCalculator.swift
  - App/DesignSystem/Components.swift
  - SharedCore/Sources/SharedCore/WorkoutRecord.swift
  - App/Views/RootView.swift
  - App/Views/WeekView.swift
  - App/Views/TodayView.swift
  - SharedCore/Sources/SharedCore/UserProfile.swift
  - App/Persistence/ProfileRecord.swift
  - App/Views/OnboardingView.swift
  - App/Views/Celebration.swift
  - App/Health/HealthKitService.swift
  - App/Views/ManualEntryView.swift
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - App/Persistence/AchievementRecord.swift
  - App/Health/PreviewHealthService.swift
  - App/Views/SettingsView.swift
  - App/Health/HealthStore.swift
  - App/Views/WorkoutDetailView.swift
  - App/Z24x4TrainerApp.swift
  - SharedCore/Sources/SharedCore/ZoneMethod.swift
  - App/Notifications/ReminderScheduler.swift
  - App/DesignSystem/ZoneStyle.swift
  - App/Health/HealthProviding.swift
  - PROGRESS.md
  - SharedCore/Sources/SharedCore/Achievement.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - App/Views/AchievementsView.swift
  - SharedCore/Sources/SharedCore/PlanProgression.swift
-->

---
### Requirement: Correct in light and dark
The UI SHALL render correctly in both light and dark appearance, using adaptive colors with legible contrast.

#### Scenario: Light and dark both legible
- **WHEN** the device appearance is light, then dark
- **THEN** every screen's text, cards, and accent remain legible with no invisible or clashing elements

##### Example: Today in both modes
- **GIVEN** a seeded profile + workouts
- **WHEN** Today is screenshotted with `simctl ui booted appearance light` and `… dark`
- **THEN** the session card, zone chips, and daily target bar are clearly visible in both


<!-- @trace
source: ui-ux-refresh
updated: 2026-06-07
code:
  - App/DesignSystem/Motion.swift
  - App/Views/ShareCard.swift
  - Watch/WorkoutListView.swift
  - App/DesignSystem/AccessibleControls.swift
  - SharedCore/Tests/SharedCoreTests/StreaksAchievementsTests.swift
  - SharedCore/Sources/SharedCore/AchievementEvaluator.swift
  - App/Views/HistoryView.swift
  - SharedCore/Sources/SharedCore/Readiness.swift
  - SharedCore/Sources/SharedCore/MetricSample.swift
  - App/Assets.xcassets/AccentColor.colorset/Contents.json
  - SharedCore/Sources/SharedCore/StreakCalculator.swift
  - App/Views/StreakBanner.swift
  - App/DesignSystem/Theme.swift
  - SharedCore/Tests/SharedCoreTests/PrecisionZonesTests.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - App/DesignSystem/Buttons.swift
  - SharedCore/Sources/SharedCore/HRZoneCalculator.swift
  - App/DesignSystem/Components.swift
  - SharedCore/Sources/SharedCore/WorkoutRecord.swift
  - App/Views/RootView.swift
  - App/Views/WeekView.swift
  - App/Views/TodayView.swift
  - SharedCore/Sources/SharedCore/UserProfile.swift
  - App/Persistence/ProfileRecord.swift
  - App/Views/OnboardingView.swift
  - App/Views/Celebration.swift
  - App/Health/HealthKitService.swift
  - App/Views/ManualEntryView.swift
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - App/Persistence/AchievementRecord.swift
  - App/Health/PreviewHealthService.swift
  - App/Views/SettingsView.swift
  - App/Health/HealthStore.swift
  - App/Views/WorkoutDetailView.swift
  - App/Z24x4TrainerApp.swift
  - SharedCore/Sources/SharedCore/ZoneMethod.swift
  - App/Notifications/ReminderScheduler.swift
  - App/DesignSystem/ZoneStyle.swift
  - App/Health/HealthProviding.swift
  - PROGRESS.md
  - SharedCore/Sources/SharedCore/Achievement.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - App/Views/AchievementsView.swift
  - SharedCore/Sources/SharedCore/PlanProgression.swift
-->

---
### Requirement: Behavior preserved
Restyling SHALL NOT change app behavior, data, or navigation.

#### Scenario: Flows still work after restyle
- **WHEN** a new user completes onboarding, logs a workout, and opens each tab
- **THEN** the same data and navigation work as before, and `SharedCore` tests stay green


<!-- @trace
source: ui-ux-refresh
updated: 2026-06-07
code:
  - App/DesignSystem/Motion.swift
  - App/Views/ShareCard.swift
  - Watch/WorkoutListView.swift
  - App/DesignSystem/AccessibleControls.swift
  - SharedCore/Tests/SharedCoreTests/StreaksAchievementsTests.swift
  - SharedCore/Sources/SharedCore/AchievementEvaluator.swift
  - App/Views/HistoryView.swift
  - SharedCore/Sources/SharedCore/Readiness.swift
  - SharedCore/Sources/SharedCore/MetricSample.swift
  - App/Assets.xcassets/AccentColor.colorset/Contents.json
  - SharedCore/Sources/SharedCore/StreakCalculator.swift
  - App/Views/StreakBanner.swift
  - App/DesignSystem/Theme.swift
  - SharedCore/Tests/SharedCoreTests/PrecisionZonesTests.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - App/DesignSystem/Buttons.swift
  - SharedCore/Sources/SharedCore/HRZoneCalculator.swift
  - App/DesignSystem/Components.swift
  - SharedCore/Sources/SharedCore/WorkoutRecord.swift
  - App/Views/RootView.swift
  - App/Views/WeekView.swift
  - App/Views/TodayView.swift
  - SharedCore/Sources/SharedCore/UserProfile.swift
  - App/Persistence/ProfileRecord.swift
  - App/Views/OnboardingView.swift
  - App/Views/Celebration.swift
  - App/Health/HealthKitService.swift
  - App/Views/ManualEntryView.swift
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - App/Persistence/AchievementRecord.swift
  - App/Health/PreviewHealthService.swift
  - App/Views/SettingsView.swift
  - App/Health/HealthStore.swift
  - App/Views/WorkoutDetailView.swift
  - App/Z24x4TrainerApp.swift
  - SharedCore/Sources/SharedCore/ZoneMethod.swift
  - App/Notifications/ReminderScheduler.swift
  - App/DesignSystem/ZoneStyle.swift
  - App/Health/HealthProviding.swift
  - PROGRESS.md
  - SharedCore/Sources/SharedCore/Achievement.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - App/Views/AchievementsView.swift
  - SharedCore/Sources/SharedCore/PlanProgression.swift
-->

---
### Requirement: Motion and haptics
Key actions SHALL give subtle motion and haptic feedback without harming usability.

#### Scenario: Target fill animates; actions confirm
- **WHEN** a progress target updates, or the user saves a workout / connects Health
- **THEN** the progress bar animates and a `.sensoryFeedback` haptic fires


<!-- @trace
source: ui-ux-refresh
updated: 2026-06-07
code:
  - App/DesignSystem/Motion.swift
  - App/Views/ShareCard.swift
  - Watch/WorkoutListView.swift
  - App/DesignSystem/AccessibleControls.swift
  - SharedCore/Tests/SharedCoreTests/StreaksAchievementsTests.swift
  - SharedCore/Sources/SharedCore/AchievementEvaluator.swift
  - App/Views/HistoryView.swift
  - SharedCore/Sources/SharedCore/Readiness.swift
  - SharedCore/Sources/SharedCore/MetricSample.swift
  - App/Assets.xcassets/AccentColor.colorset/Contents.json
  - SharedCore/Sources/SharedCore/StreakCalculator.swift
  - App/Views/StreakBanner.swift
  - App/DesignSystem/Theme.swift
  - SharedCore/Tests/SharedCoreTests/PrecisionZonesTests.swift
  - SharedCore/Tests/SharedCoreTests/ReadinessTests.swift
  - App/DesignSystem/Buttons.swift
  - SharedCore/Sources/SharedCore/HRZoneCalculator.swift
  - App/DesignSystem/Components.swift
  - SharedCore/Sources/SharedCore/WorkoutRecord.swift
  - App/Views/RootView.swift
  - App/Views/WeekView.swift
  - App/Views/TodayView.swift
  - SharedCore/Sources/SharedCore/UserProfile.swift
  - App/Persistence/ProfileRecord.swift
  - App/Views/OnboardingView.swift
  - App/Views/Celebration.swift
  - App/Health/HealthKitService.swift
  - App/Views/ManualEntryView.swift
  - SharedCore/Sources/SharedCore/FitnessTrend.swift
  - App/Persistence/AchievementRecord.swift
  - App/Health/PreviewHealthService.swift
  - App/Views/SettingsView.swift
  - App/Health/HealthStore.swift
  - App/Views/WorkoutDetailView.swift
  - App/Z24x4TrainerApp.swift
  - SharedCore/Sources/SharedCore/ZoneMethod.swift
  - App/Notifications/ReminderScheduler.swift
  - App/DesignSystem/ZoneStyle.swift
  - App/Health/HealthProviding.swift
  - PROGRESS.md
  - SharedCore/Sources/SharedCore/Achievement.swift
  - SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - App/Views/AchievementsView.swift
  - SharedCore/Sources/SharedCore/PlanProgression.swift
-->

---
### Requirement: Accessibility
Screens SHALL support Dynamic Type and expose VoiceOver labels for non-text indicators. Every screen SHALL adopt the design system's accessibility foundation: status is conveyed with a non-color signal in addition to color, steppers expose distinct label/value/hint, form fields expose accessibility labels, interactive controls keep a tap target of at least 44×44pt, and motion respects the Reduce Motion setting.

#### Scenario: Large type and VoiceOver
- **WHEN** the device uses a large Dynamic Type size and VoiceOver is on
- **THEN** text scales without clipping and non-text indicators expose meaningful labels

#### Scenario: Celebration respects Reduce Motion
- **WHEN** Reduce Motion is enabled and an achievement unlocks
- **THEN** the celebration reaches its final state without confetti or animated transitions

#### Scenario: Steppers announce label and value
- **WHEN** VoiceOver focuses any stepper on the Settings or Onboarding screen
- **THEN** it announces the field label followed by the current value, with increment and decrement actions

#### Scenario: Status is distinguishable without color
- **WHEN** the readiness indicator, a History fitness-trend delta, or an HR zone chip is shown
- **THEN** a glyph, +/− sign, or text label conveys the state in addition to color

##### Example: trend delta encodes direction
| Delta | Color | Non-color signal | VoiceOver |
| ----- | ----- | ---------------- | --------- |
| +2.1 | success | "▲ +2.1" | "improved by 2.1" |
| -1.4 | danger | "▼ −1.4" | "declined by 1.4" |

#### Scenario: History chart is readable by VoiceOver
- **WHEN** VoiceOver navigates the weekly training-minutes chart with data present
- **THEN** it announces a per-day value summary rather than nothing

#### Scenario: Form fields are labelled
- **WHEN** VoiceOver focuses the weight, height, or active-energy field on Onboarding or manual entry
- **THEN** it announces a descriptive label (e.g., "Weight in kilograms") rather than only a placeholder

#### Scenario: Tap targets meet minimum size
- **WHEN** an interactive control such as the daily-target completion mark or an achievement badge cell is shown
- **THEN** its tap target is at least 44×44pt

#### Scenario: Locked badges are distinguishable
- **WHEN** the Achievements grid shows locked and unlocked badges
- **THEN** locked state is conveyed by a lock glyph with sufficient contrast, not by opacity alone


<!-- @trace
source: accessibility-pass
updated: 2026-06-07
code:
  - App/Views/OnboardingView.swift
  - App/Views/SettingsView.swift
  - App/DesignSystem/AccessibleControls.swift
  - App/DesignSystem/Motion.swift
  - App/DesignSystem/Theme.swift
  - App/Views/Celebration.swift
  - App/Views/ManualEntryView.swift
  - App/Views/HistoryView.swift
  - App/Views/StreakBanner.swift
  - App/Views/TodayView.swift
  - App/Views/WeekView.swift
  - App/DesignSystem/Components.swift
  - App/DesignSystem/Buttons.swift
  - App/Views/AchievementsView.swift
-->

---
### Requirement: Accessible semantic color tokens
The design system SHALL provide semantic status color tokens — `success`, `warning`, `danger`, and `info` — each exposing a foreground/background pairing that maintains a contrast ratio of at least 4.5:1 against its intended surface in both light and dark appearance. Screens SHALL use these tokens instead of raw system colors (`.green`, `.orange`, `.red`) for status indication.

#### Scenario: Status tokens are legible in both appearances
- **WHEN** a status token is rendered as foreground text on its paired surface in light, then dark appearance
- **THEN** the text remains legible with a measured contrast ratio of at least 4.5:1 in both

##### Example: token contrast targets
| Token | Use | Min contrast (text on paired surface) |
| ----- | --- | ------------------------------------- |
| success | "Ready" readiness, positive trend | 4.5:1 |
| warning | "Caution" readiness, required-field notice | 4.5:1 |
| danger | "Rest" readiness, negative trend | 4.5:1 |
| info | neutral/secondary callout | 4.5:1 |


<!-- @trace
source: design-system-a11y
updated: 2026-06-07
code:
  - App/DesignSystem/Buttons.swift
  - App/Views/SettingsView.swift
  - App/Views/AchievementsView.swift
  - App/DesignSystem/Components.swift
  - App/DesignSystem/Motion.swift
  - App/Views/WeekView.swift
  - App/Views/TodayView.swift
  - App/DesignSystem/AccessibleControls.swift
  - App/Views/ManualEntryView.swift
  - App/Views/Celebration.swift
  - App/Views/StreakBanner.swift
  - App/DesignSystem/Theme.swift
  - App/Views/HistoryView.swift
  - App/Views/OnboardingView.swift
-->

---
### Requirement: Color is never the only signal
Where the design system conveys state through color, it SHALL also provide a non-color signal (symbol, sign, or text) so that the state is distinguishable without color perception.

#### Scenario: State distinguishable without color
- **WHEN** a status or trend indicator is shown
- **THEN** a glyph, +/− sign, or text label communicates the same state as the color does


<!-- @trace
source: design-system-a11y
updated: 2026-06-07
code:
  - App/DesignSystem/Buttons.swift
  - App/Views/SettingsView.swift
  - App/Views/AchievementsView.swift
  - App/DesignSystem/Components.swift
  - App/DesignSystem/Motion.swift
  - App/Views/WeekView.swift
  - App/Views/TodayView.swift
  - App/DesignSystem/AccessibleControls.swift
  - App/Views/ManualEntryView.swift
  - App/Views/Celebration.swift
  - App/Views/StreakBanner.swift
  - App/DesignSystem/Theme.swift
  - App/Views/HistoryView.swift
  - App/Views/OnboardingView.swift
-->

---
### Requirement: Secondary button component
The design system SHALL provide a `SecondaryButton` component that matches `PrimaryButton` in size and tap target but renders a visually subordinate (tinted/bordered) style, with the same press animation and `.sensoryFeedback` haptic on activation.

#### Scenario: Secondary action is visually subordinate yet equally tappable
- **WHEN** a `SecondaryButton` is placed alongside a `PrimaryButton`
- **THEN** it reads as the lower-priority action while keeping a tap target of at least 44×44pt and firing a haptic on tap


<!-- @trace
source: design-system-a11y
updated: 2026-06-07
code:
  - App/DesignSystem/Buttons.swift
  - App/Views/SettingsView.swift
  - App/Views/AchievementsView.swift
  - App/DesignSystem/Components.swift
  - App/DesignSystem/Motion.swift
  - App/Views/WeekView.swift
  - App/Views/TodayView.swift
  - App/DesignSystem/AccessibleControls.swift
  - App/Views/ManualEntryView.swift
  - App/Views/Celebration.swift
  - App/Views/StreakBanner.swift
  - App/DesignSystem/Theme.swift
  - App/Views/HistoryView.swift
  - App/Views/OnboardingView.swift
-->

---
### Requirement: Accessible stepper component
The design system SHALL provide an `AccessibleStepper` wrapper that exposes a single accessibility element with a distinct label and value, an increment/decrement hint, and a tap target of at least 44×44pt. VoiceOver SHALL announce the control as its label followed by its current value.

#### Scenario: VoiceOver reads label then value
- **WHEN** VoiceOver focuses an `AccessibleStepper` labelled "Age" with value 30
- **THEN** it announces "Age, 30" with adjustable increment/decrement actions, not a single concatenated phrase


<!-- @trace
source: design-system-a11y
updated: 2026-06-07
code:
  - App/DesignSystem/Buttons.swift
  - App/Views/SettingsView.swift
  - App/Views/AchievementsView.swift
  - App/DesignSystem/Components.swift
  - App/DesignSystem/Motion.swift
  - App/Views/WeekView.swift
  - App/Views/TodayView.swift
  - App/DesignSystem/AccessibleControls.swift
  - App/Views/ManualEntryView.swift
  - App/Views/Celebration.swift
  - App/Views/StreakBanner.swift
  - App/DesignSystem/Theme.swift
  - App/Views/HistoryView.swift
  - App/Views/OnboardingView.swift
-->

---
### Requirement: Reduce Motion respected by motion helper
The design system SHALL provide a motion helper that reads the system Reduce Motion setting. When Reduce Motion is enabled, animations applied through the helper SHALL degrade to an immediate, non-animated state change.

#### Scenario: Animation degrades under Reduce Motion
- **WHEN** Reduce Motion is enabled and a state change is applied through the motion helper
- **THEN** the final state is reached without an animated transition

#### Scenario: Animation plays when Reduce Motion is off
- **WHEN** Reduce Motion is disabled and the same state change is applied
- **THEN** the transition animates normally

<!-- @trace
source: design-system-a11y
updated: 2026-06-07
code:
  - App/DesignSystem/Buttons.swift
  - App/Views/SettingsView.swift
  - App/Views/AchievementsView.swift
  - App/DesignSystem/Components.swift
  - App/DesignSystem/Motion.swift
  - App/Views/WeekView.swift
  - App/Views/TodayView.swift
  - App/DesignSystem/AccessibleControls.swift
  - App/Views/ManualEntryView.swift
  - App/Views/Celebration.swift
  - App/Views/StreakBanner.swift
  - App/DesignSystem/Theme.swift
  - App/Views/HistoryView.swift
  - App/Views/OnboardingView.swift
-->