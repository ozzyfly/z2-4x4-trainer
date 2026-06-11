## ADDED Requirements

### Requirement: Manual entries save to Apple Health
The app SHALL save manually entered workouts to Apple Health as workout samples when Health share authorization is granted, recording the returned workout UUID on the local log so subsequent Health imports deduplicate against it. When the save fails or authorization is denied, the local log SHALL be kept and a non-blocking notice SHALL be shown.

#### Scenario: Successful save records UUID
- **WHEN** the user saves a manual workout and the Health save succeeds
- **THEN** the local log's health UUID is set to the saved workout's UUID

#### Scenario: Re-import does not duplicate
- **WHEN** a Health import runs after a manual entry was saved to Health
- **THEN** the imported workout with the same UUID is skipped and no duplicate log is created

#### Scenario: Failed save keeps local log
- **WHEN** the Health save throws or share authorization is denied
- **THEN** the local log is kept without a health UUID and a non-blocking notice is shown

### Requirement: Watch workouts persist to Health
The watch app SHALL persist completed live workout sessions to Apple Health via the live workout builder, so watch-recorded sessions appear in Health without phone involvement.

#### Scenario: Finished session is in Health
- **WHEN** a live watch workout session ends
- **THEN** the workout is finished through the live workout builder and persisted to Apple Health

## MODIFIED Requirements

(none)
