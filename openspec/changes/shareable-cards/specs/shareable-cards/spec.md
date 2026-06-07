## ADDED Requirements

### Requirement: Share a summary card
The app SHALL render a branded summary image (this week's training) and present it via the system
share sheet.

#### Scenario: Share from History
- **WHEN** the user taps Share on History
- **THEN** the app renders a branded card image (app name, week dates, minutes, sessions, streak) and opens the share sheet with it

#### Scenario: Card reflects real data
- **WHEN** the week has 3 sessions totalling 120 minutes
- **THEN** the card shows 3 sessions and 120 minutes
