# design-system Specification

## Purpose

TBD - created by archiving change 'ui-ux-refresh'. Update Purpose after archive.

## Requirements

### Requirement: Shared design system
The app SHALL provide reusable theme tokens and components (`Card`, `SectionHeader`, `TargetBar`, `PrimaryButton`, `SecondaryButton`, `ZoneChip`, accent color) that every screen uses. The HR-zone and interval-kind visual tokens (color and SF-Symbol glyph) SHALL be defined once in `SharedCore` so the iOS and watchOS targets share a single source rather than duplicating them.

#### Scenario: Components render consistently
- **WHEN** any restyled screen is shown
- **THEN** it uses the shared card, header, accent, and progress components rather than default `Form` styling

#### Scenario: Zone and interval tokens have one definition
- **WHEN** the iOS app or the watchOS app renders an HR-zone color, an HR-zone name, or an interval-kind color
- **THEN** it resolves the value from the `SharedCore` token definitions, and no target redefines those tokens locally


<!-- @trace
source: shared-visual-tokens
updated: 2026-06-07
code:
  - App/Views/WorkoutDetailView.swift
  - App/Views/Celebration.swift
  - App/Views/ShareCard.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
  - Watch/WorkoutSessionManager.swift
  - Watch/LiveWorkoutView.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - App/Views/SettingsView.swift
  - Watch/WorkoutListView.swift
  - App/DesignSystem/ZoneStyle.swift
  - App/DesignSystem/Components.swift
  - App/Views/OnboardingView.swift
  - App/DesignSystem/Buttons.swift
  - App/Views/HistoryView.swift
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
Key actions SHALL give subtle motion and haptic feedback without harming usability. Every animation in the design system and screens SHALL respect the system Reduce Motion setting: when Reduce Motion is enabled, animated transitions SHALL degrade to an immediate state change while non-motion feedback (haptics) MAY still fire.

#### Scenario: Target fill animates; actions confirm
- **WHEN** a progress target updates, or the user saves a workout / connects Health
- **THEN** the progress bar animates and a `.sensoryFeedback` haptic fires

#### Scenario: Animations degrade under Reduce Motion
- **WHEN** Reduce Motion is enabled and the daily/weekly target bar appears or updates, a primary or secondary button is pressed, a goal toggle reveals its rate field, or an achievement celebration plays
- **THEN** the affected views reach their final state without an animated transition, and any associated haptic still fires


<!-- @trace
source: reduce-motion-completion
updated: 2026-06-07
code:
  - App/Views/ShareCard.swift
  - App/Views/Celebration.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
  - App/DesignSystem/ZoneStyle.swift
  - Watch/LiveWorkoutView.swift
  - App/DesignSystem/Buttons.swift
  - Watch/WorkoutSessionManager.swift
  - App/DesignSystem/Components.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - Watch/WorkoutListView.swift
  - App/Views/HistoryView.swift
  - App/Views/OnboardingView.swift
  - App/Views/SettingsView.swift
  - App/Views/WorkoutDetailView.swift
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

---
### Requirement: Non-color token signal
Each HR-zone and each interval-kind SHALL expose a non-color signal (an SF-Symbol glyph) alongside its color, so that adopting screens can convey the state without relying on color alone.

#### Scenario: Every zone and interval kind has a glyph
- **WHEN** code requests the glyph for any `HRZone` case or any `IntervalKind` case
- **THEN** a non-empty SF-Symbol name is returned that is distinct per case

##### Example: zone glyphs
| Case | Color | Glyph |
| ---- | ----- | ----- |
| zone1 | gray | 1.circle.fill |
| zone2 | green | 2.circle.fill |
| zone3 | blue | 3.circle.fill |
| zone4 | orange | 4.circle.fill |
| zone5 | red | 5.circle.fill |

##### Example: interval-kind glyphs
| Case | Color | Glyph |
| ---- | ----- | ----- |
| warmup | blue | figure.walk |
| hard | red | bolt.fill |
| recovery | green | arrow.down.heart.fill |
| cooldown | teal | wind |


<!-- @trace
source: shared-visual-tokens
updated: 2026-06-07
code:
  - App/Views/WorkoutDetailView.swift
  - App/Views/Celebration.swift
  - App/Views/ShareCard.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
  - Watch/WorkoutSessionManager.swift
  - Watch/LiveWorkoutView.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - App/Views/SettingsView.swift
  - Watch/WorkoutListView.swift
  - App/DesignSystem/ZoneStyle.swift
  - App/DesignSystem/Components.swift
  - App/Views/OnboardingView.swift
  - App/DesignSystem/Buttons.swift
  - App/Views/HistoryView.swift
-->

---
### Requirement: Zone colors preserved across the move
Moving the tokens into `SharedCore` SHALL NOT change any existing color value. The zone color mapping (zone1 gray, zone2 green, zone3 blue, zone4 orange, zone5 red) and the interval mapping (warmup blue, hard red, recovery green, cooldown teal) SHALL stay identical to the pre-move iOS and watch definitions.

#### Scenario: Visuals unchanged after refactor
- **WHEN** a screen that previously rendered a zone or interval color is shown after the tokens move to `SharedCore`
- **THEN** the rendered color is identical to before the move

<!-- @trace
source: shared-visual-tokens
updated: 2026-06-07
code:
  - App/Views/WorkoutDetailView.swift
  - App/Views/Celebration.swift
  - App/Views/ShareCard.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
  - Watch/WorkoutSessionManager.swift
  - Watch/LiveWorkoutView.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - App/Views/SettingsView.swift
  - Watch/WorkoutListView.swift
  - App/DesignSystem/ZoneStyle.swift
  - App/DesignSystem/Components.swift
  - App/Views/OnboardingView.swift
  - App/DesignSystem/Buttons.swift
  - App/Views/HistoryView.swift
-->

---
### Requirement: Interval rows convey kind without color
An interval row SHALL convey the interval kind with a non-color signal (the interval-kind glyph) in addition to its colored bar, so the kind is distinguishable without color perception.

#### Scenario: Interval kind shown with glyph
- **WHEN** an interval row for a Norwegian 4×4 structure is shown
- **THEN** the interval kind is conveyed by a glyph (and text) alongside the colored bar, not by color alone


<!-- @trace
source: ios-detail-polish
updated: 2026-06-07
code:
  - Watch/LiveWorkoutView.swift
  - App/Views/ShareCard.swift
  - App/Views/WorkoutDetailView.swift
  - App/DesignSystem/Components.swift
  - App/Views/OnboardingView.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
  - Watch/WorkoutSessionManager.swift
  - App/Views/Celebration.swift
  - App/DesignSystem/Buttons.swift
  - App/DesignSystem/ZoneStyle.swift
  - App/Views/SettingsView.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - App/Views/HistoryView.swift
  - Watch/WorkoutListView.swift
-->

---
### Requirement: Share card is accessible
The shareable summary card SHALL expose a single combined accessibility element summarizing its content (week minutes, sessions, streak), and its title SHALL not overflow its fixed-width layout.

#### Scenario: Share card has an accessibility summary
- **WHEN** VoiceOver focuses the share card
- **THEN** it announces a summary including the week's minutes, session count, and streak

#### Scenario: Title fits the card
- **WHEN** the share card renders its title
- **THEN** the title stays on one line within the fixed card width, scaling down if needed rather than wrapping or clipping


<!-- @trace
source: ios-detail-polish
updated: 2026-06-07
code:
  - Watch/LiveWorkoutView.swift
  - App/Views/ShareCard.swift
  - App/Views/WorkoutDetailView.swift
  - App/DesignSystem/Components.swift
  - App/Views/OnboardingView.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
  - Watch/WorkoutSessionManager.swift
  - App/Views/Celebration.swift
  - App/DesignSystem/Buttons.swift
  - App/DesignSystem/ZoneStyle.swift
  - App/Views/SettingsView.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - App/Views/HistoryView.swift
  - Watch/WorkoutListView.swift
-->

---
### Requirement: Charts label their axes and units
History charts SHALL show Y-axis scale marks and state the metric/unit, so a value can be read without external context.

#### Scenario: Chart shows axis and unit
- **WHEN** a History chart with data is shown
- **THEN** it displays Y-axis scale marks and a caption naming the metric and unit


<!-- @trace
source: ios-detail-polish
updated: 2026-06-07
code:
  - Watch/LiveWorkoutView.swift
  - App/Views/ShareCard.swift
  - App/Views/WorkoutDetailView.swift
  - App/DesignSystem/Components.swift
  - App/Views/OnboardingView.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
  - Watch/WorkoutSessionManager.swift
  - App/Views/Celebration.swift
  - App/DesignSystem/Buttons.swift
  - App/DesignSystem/ZoneStyle.swift
  - App/Views/SettingsView.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - App/Views/HistoryView.swift
  - Watch/WorkoutListView.swift
-->

---
### Requirement: Zone colors are not reused for non-zone metrics
HR-zone colors SHALL be reserved for HR-zone contexts; a non-zone metric chart SHALL use a neutral/accent color rather than an HR-zone color.

#### Scenario: Weight chart uses a non-zone color
- **WHEN** the body-weight trend chart is shown
- **THEN** its line uses the accent (or a neutral metric) color, not an HR-zone color

<!-- @trace
source: ios-detail-polish
updated: 2026-06-07
code:
  - Watch/LiveWorkoutView.swift
  - App/Views/ShareCard.swift
  - App/Views/WorkoutDetailView.swift
  - App/DesignSystem/Components.swift
  - App/Views/OnboardingView.swift
  - SharedCore/Sources/SharedCore/HRZone+UI.swift
  - Watch/WorkoutSessionManager.swift
  - App/Views/Celebration.swift
  - App/DesignSystem/Buttons.swift
  - App/DesignSystem/ZoneStyle.swift
  - App/Views/SettingsView.swift
  - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - App/Views/HistoryView.swift
  - Watch/WorkoutListView.swift
-->