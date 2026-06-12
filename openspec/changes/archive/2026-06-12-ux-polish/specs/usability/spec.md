## ADDED Requirements

### Requirement: Today welcomes first-time users
When no workout has ever been logged, the Today screen SHALL show a welcome card that explains today's planned session and offers calls to action to start the first session or log one manually, instead of an unexplained default state.

#### Scenario: Empty state before first workout
- **WHEN** the app opens with zero logged workouts
- **THEN** the Today screen shows a welcome card with today's session and start/log calls to action

#### Scenario: Empty state disappears after first log
- **WHEN** the first workout is logged
- **THEN** the Today screen shows its regular content instead of the welcome card

### Requirement: Onboarding opens with an intro
Onboarding SHALL begin with an intro step that states what the app does and its three core points (Zone 2 + 4×4 prescriptions, Apple Health input, local-only data) before any data entry.

#### Scenario: Intro precedes the form
- **WHEN** a new user launches the app for the first time
- **THEN** an intro screen with the app's purpose and a continue action appears before the profile form

### Requirement: Workout notes are usable
Manual workout entry SHALL accept an optional note, and logged workouts SHALL be visible in a recent-workouts list on the History screen showing date, type, duration, source, and the note when present.

#### Scenario: Note round-trips
- **WHEN** the user saves a manual entry with a note
- **THEN** the note is stored on the log and visible in the recent-workouts list

#### Scenario: Recent list shows source
- **WHEN** the recent-workouts list renders logs from manual entry and from Health import or watch sync
- **THEN** each row distinguishes its source with an icon or label

## MODIFIED Requirements

(none)
