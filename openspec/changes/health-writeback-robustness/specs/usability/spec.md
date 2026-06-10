## ADDED Requirements

### Requirement: Failures are visible
The app SHALL surface failures of background conveniences instead of failing silently. Reminder scheduling SHALL report denied notification authorization with an inline warning and a link to system Settings; the guided player SHALL show a notice when the audio session cannot be configured; a failed Health write SHALL show a non-blocking notice.

#### Scenario: Denied notifications show warning
- **WHEN** the user enables reminders while notification authorization is denied
- **THEN** the reminders section shows an inline warning with a link to open system Settings instead of a silently inactive toggle

#### Scenario: Audio unavailable is announced
- **WHEN** the guided player cannot configure the audio session
- **THEN** the player shows a "voice cues unavailable" notice and the session timer still runs

#### Scenario: Health write failure is noticed
- **WHEN** saving a manual entry to Apple Health fails
- **THEN** a non-blocking notice is shown and the entry remains saved locally

### Requirement: Trend math is total
Fitness trend computation SHALL handle empty and single-sample inputs without force-unwrapping, returning no trend for inputs that cannot produce one.

#### Scenario: Empty input yields no trend
- **WHEN** the fitness trend is computed from zero samples
- **THEN** no trend is returned and no crash occurs

#### Scenario: Single sample yields no slope
- **WHEN** the fitness trend is computed from one sample
- **THEN** the result contains no slope-based classification and no crash occurs
