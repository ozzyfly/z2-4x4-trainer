## ADDED Requirements

### Requirement: Opt-in training reminders
The app SHALL schedule local notifications for plan training days only when the user has enabled
reminders, and SHALL remove them when disabled.

#### Scenario: Enabling schedules plan-day reminders
- **WHEN** the user enables reminders and grants notification permission
- **THEN** a local notification is scheduled for each non-rest day in the weekly plan at the chosen time

#### Scenario: Disabling clears them
- **WHEN** the user disables reminders
- **THEN** all the app's pending reminder notifications are cancelled

### Requirement: Permission respected
The app SHALL request notification authorization before scheduling and SHALL not schedule if denied.

#### Scenario: Denied permission
- **WHEN** notification permission is denied
- **THEN** no notifications are scheduled and the UI reflects the disabled state
