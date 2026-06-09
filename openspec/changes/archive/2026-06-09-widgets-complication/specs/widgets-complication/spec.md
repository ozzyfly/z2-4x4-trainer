## ADDED Requirements

### Requirement: Shared widget snapshot
The app SHALL publish a snapshot of the current training state (today's planned session, this week's done/target training minutes, this week's done/target hard sessions) to a shared App Group container, encoded as a codec-stable format that widgets can read without launching the app.

#### Scenario: Snapshot round-trips
- **WHEN** a `WidgetSnapshot` is encoded and then decoded
- **THEN** the decoded value equals the original

#### Scenario: Snapshot updates after logging
- **WHEN** the user logs a workout
- **THEN** the published snapshot reflects the new weekly done minutes and the widgets are asked to reload

#### Scenario: Missing container is safe
- **WHEN** no snapshot has been written (or the App Group container is unavailable)
- **THEN** reading returns no snapshot and widgets render their placeholder without crashing

### Requirement: Home and Lock widgets
The iOS app SHALL provide widgets showing today's planned session and this week's training-minutes progress, in Home-screen (small and medium) and Lock-screen (rectangular and circular) families.

#### Scenario: Small widget shows today's session
- **WHEN** the small Home widget is shown with a snapshot whose today session is Zone 2, 40 minutes
- **THEN** it displays the session type and duration (or "Rest" on a rest day)

#### Scenario: Medium widget shows weekly progress
- **WHEN** the medium Home widget is shown
- **THEN** it displays today's session and the week's done/target training minutes

#### Scenario: Lock widgets show glanceable state
- **WHEN** a Lock-screen widget is shown
- **THEN** the circular family shows the weekly progress and the rectangular family shows today's session

### Requirement: Widget tap opens the app
Tapping any iOS widget SHALL open the app on the Today screen.

#### Scenario: Tap deep-links to Today
- **WHEN** the user taps a Home or Lock widget
- **THEN** the app opens and shows the Today tab

### Requirement: Watch complication shows next session
The watch SHALL provide a complication showing the next non-rest planned session.

#### Scenario: Complication shows next session
- **WHEN** the watch complication is rendered
- **THEN** the circular family shows the session glyph and the corner family shows the session type and duration of the next non-rest session
