## ADDED Requirements

### Requirement: Watch status section
The watch workout-list screen SHALL show a status section with the readiness score and label, the current streak in weeks, and this week's done/target training minutes, sourced from the cached snapshot. When no snapshot has been received the section SHALL show a neutral placeholder instead of stale or fabricated values.

#### Scenario: Status section shows synced insight
- **WHEN** the watch has a cached snapshot with readinessValue 100, streakWeeks 2, and weekly minutes 90 of 163
- **THEN** the status section displays the readiness score and label, the 2-week streak, and the 90/163 minute progress

#### Scenario: Placeholder before first sync
- **WHEN** the watch has never received a snapshot
- **THEN** the status section shows a placeholder state and the workout list remains usable

### Requirement: Watch uses synced profile
The watch app SHALL derive heart-rate zones from profile values synced from the phone (age, max-HR override, zone method) when available, and SHALL fall back to its built-in default profile only when no synced profile exists.

#### Scenario: Synced profile drives zones
- **WHEN** the phone has pushed a profile with a max-HR override of 185
- **THEN** the watch zone calculations use 185 as max HR instead of the default profile

#### Scenario: Fallback without sync
- **WHEN** no profile has ever been synced
- **THEN** the watch uses its built-in default profile and the workout list still renders
