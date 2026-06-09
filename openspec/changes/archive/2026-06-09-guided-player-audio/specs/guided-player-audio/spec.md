## ADDED Requirements

### Requirement: Guided 4×4 player
The app SHALL provide an on-iPhone guided player for the Norwegian 4×4 session that advances through the prescribed intervals with a live countdown, shows the current and next interval, fires a haptic on each transition, and speaks a voice cue when entering each interval.

#### Scenario: Countdown advances through intervals
- **WHEN** the guided 4×4 player runs
- **THEN** the current interval's remaining time counts down each second and, on reaching zero, advances to the next interval until the session completes

#### Scenario: Transition feedback
- **WHEN** the player enters a new interval
- **THEN** a haptic fires and a spoken cue announces the interval (e.g. "Hard" / "Recover")

#### Scenario: Completion
- **WHEN** the final interval elapses
- **THEN** the player stops and announces that the session is complete

### Requirement: Guided Zone 2 player
The app SHALL provide a guided Zone 2 mode showing elapsed time, with a spoken reminder at the start and periodically thereafter.

#### Scenario: Zone 2 elapsed and reminder
- **WHEN** the Zone 2 guided session runs
- **THEN** elapsed time is displayed and a spoken reminder to stay in Zone 2 plays at the start and at regular intervals

### Requirement: Interval cue text is well-defined
Each interval kind, and the session-complete state, SHALL map to a defined non-empty spoken cue string, independent of any view.

#### Scenario: Every kind has a cue
- **WHEN** a cue is requested for entering any `IntervalKind`, or for session completion
- **THEN** a non-empty string is returned

### Requirement: Audio plays over other audio
While a guided session plays, its voice cues SHALL be audible over other playing audio by ducking it, and normal audio SHALL resume when the session ends.

#### Scenario: Voice ducks music
- **WHEN** a guided session is playing while other audio plays
- **THEN** the other audio is ducked for the spoken cues, and resumes after the session ends

### Requirement: Guided player entry point
The workout detail screen SHALL offer a way to start the guided session for the shown workout.

#### Scenario: Start from workout detail
- **WHEN** the user views a Zone 2 or Norwegian 4×4 workout detail
- **THEN** a control is available to start its guided session
