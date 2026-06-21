## ADDED Requirements

### Requirement: Guided session completion records a workout

When a guided player session (Zone 2 or Norwegian 4×4) runs to its full prescribed duration and finishes normally, the app SHALL insert exactly one `WorkoutLog` record so the session appears in the Today, Week, and History statistics. The record SHALL carry the session type, the completed duration in minutes, the completion date, the active energy in kilocalories when available, and a source marker identifying it as a guided session. The app SHALL update the widget snapshot after inserting the record so widgets and complications reflect the new session. When a guided session is cancelled before its prescribed duration completes, the app SHALL NOT insert a `WorkoutLog`.

#### Scenario: Completing a guided 4×4 records one workout

- **WHEN** the user starts the guided Norwegian 4×4 player and lets it run through warmup, all four intervals, and cooldown to completion
- **THEN** the app inserts exactly one `WorkoutLog` with type Norwegian 4×4, the completed duration, and source marked guided
- **AND** the session appears in Today, Week, and History without a separate manual entry

#### Scenario: Completing a guided Zone 2 records one workout

- **WHEN** the user starts the guided Zone 2 player and lets it run to its prescribed duration
- **THEN** the app inserts exactly one `WorkoutLog` with type Zone 2, the completed duration, and source marked guided

#### Scenario: Cancelling a guided session records nothing

- **WHEN** the user starts a guided session and ends it before the prescribed duration completes
- **THEN** the app inserts no `WorkoutLog`
- **AND** the Today, Week, and History statistics are unchanged
