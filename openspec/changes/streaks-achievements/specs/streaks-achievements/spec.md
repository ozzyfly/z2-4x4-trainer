## ADDED Requirements

### Requirement: Training streaks
The app SHALL compute the current and longest streak of training weeks from history, where a week
counts when at least one workout is logged.

#### Scenario: Current streak counts consecutive trained weeks
- **WHEN** the athlete logged a workout each of the last 3 weeks and none the week before
- **THEN** the current streak is 3 weeks and the longest streak is at least 3

#### Scenario: A gap breaks the streak
- **WHEN** the most recent week has no workout
- **THEN** the current streak is 0

### Requirement: Achievement catalog
The app SHALL evaluate a fixed catalog of achievements against history and report which are unlocked.

#### Scenario: First 4×4 unlocks
- **WHEN** the history contains at least one Norwegian 4×4 workout
- **THEN** the "First 4×4" achievement is unlocked

#### Scenario: Locked when unmet
- **WHEN** the history has fewer than 10 workouts
- **THEN** the "10 sessions" achievement is locked

### Requirement: Celebration on unlock
The app SHALL show a celebration (visual + haptic) when an achievement unlocks or the day's target is met.

#### Scenario: Celebrate a new unlock
- **WHEN** an achievement transitions from locked to unlocked
- **THEN** a celebration overlay appears and a success haptic fires once
