## ADDED Requirements

### Requirement: Shared design system
The app SHALL provide reusable theme tokens and components (`Card`, `SectionHeader`, `TargetBar`,
`PrimaryButton`, `ZoneChip`, accent color, `HRZone` color map) that every screen uses.

#### Scenario: Components render consistently
- **WHEN** any restyled screen is shown
- **THEN** it uses the shared card, header, accent, and progress components rather than default `Form` styling

### Requirement: Correct in light and dark
The UI SHALL render correctly in both light and dark appearance, using adaptive colors with legible contrast.

#### Scenario: Light and dark both legible
- **WHEN** the device appearance is light, then dark
- **THEN** every screen's text, cards, and accent remain legible with no invisible or clashing elements

##### Example: Today in both modes
- **GIVEN** a seeded profile + workouts
- **WHEN** Today is screenshotted with `simctl ui booted appearance light` and `… dark`
- **THEN** the session card, zone chips, and daily target bar are clearly visible in both

### Requirement: Behavior preserved
Restyling SHALL NOT change app behavior, data, or navigation.

#### Scenario: Flows still work after restyle
- **WHEN** a new user completes onboarding, logs a workout, and opens each tab
- **THEN** the same data and navigation work as before, and `SharedCore` tests stay green

### Requirement: Motion and haptics
Key actions SHALL give subtle motion and haptic feedback without harming usability.

#### Scenario: Target fill animates; actions confirm
- **WHEN** a progress target updates, or the user saves a workout / connects Health
- **THEN** the progress bar animates and a `.sensoryFeedback` haptic fires

### Requirement: Accessibility
Screens SHALL support Dynamic Type and expose VoiceOver labels for non-text indicators.

#### Scenario: Large type and VoiceOver
- **WHEN** Dynamic Type is enlarged and VoiceOver is on
- **THEN** layouts adapt without clipping and progress bars / chips announce meaningful labels
