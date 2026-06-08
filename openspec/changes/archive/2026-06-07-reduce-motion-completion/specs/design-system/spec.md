## MODIFIED Requirements

### Requirement: Motion and haptics
Key actions SHALL give subtle motion and haptic feedback without harming usability. Every animation in the design system and screens SHALL respect the system Reduce Motion setting: when Reduce Motion is enabled, animated transitions SHALL degrade to an immediate state change while non-motion feedback (haptics) MAY still fire.

#### Scenario: Target fill animates; actions confirm
- **WHEN** a progress target updates, or the user saves a workout / connects Health
- **THEN** the progress bar animates and a `.sensoryFeedback` haptic fires

#### Scenario: Animations degrade under Reduce Motion
- **WHEN** Reduce Motion is enabled and the daily/weekly target bar appears or updates, a primary or secondary button is pressed, a goal toggle reveals its rate field, or an achievement celebration plays
- **THEN** the affected views reach their final state without an animated transition, and any associated haptic still fires
