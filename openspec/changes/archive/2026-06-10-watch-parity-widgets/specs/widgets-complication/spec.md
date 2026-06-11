## ADDED Requirements

### Requirement: Streak and readiness widgets
The iOS app SHALL provide a streak widget and a readiness widget in addition to the today widget. The streak widget SHALL show the current weekly streak in weeks; the readiness widget SHALL show the readiness score and its label. Both SHALL render a placeholder when the snapshot lacks the corresponding optional field.

#### Scenario: Streak widget shows weeks
- **WHEN** the streak widget is shown with a snapshot whose streakWeeks is 2
- **THEN** it displays a 2-week streak

#### Scenario: Readiness widget shows score
- **WHEN** the readiness widget is shown with a snapshot whose readinessValue is 100 and label is goHard
- **THEN** it displays the score 100 and the label text

#### Scenario: Missing fields render placeholder
- **WHEN** a streak or readiness widget reads a snapshot without the corresponding optional field
- **THEN** it renders a neutral placeholder without crashing

### Requirement: Phone publishes snapshot to watch
The iPhone app SHALL push the current widget snapshot to the paired watch via WatchConnectivity application context after every snapshot write, and the watch app SHALL cache the received snapshot in its own App Group container so the watch app and its complications can read it while the phone is unreachable.

#### Scenario: Snapshot pushed after logging
- **WHEN** the user logs a workout on the phone and the WCSession is activated
- **THEN** the updated snapshot is sent via application context

#### Scenario: Watch caches received snapshot
- **WHEN** the watch receives an application context containing a snapshot
- **THEN** it writes the snapshot to the watch App Group container and reloads its complication timelines

#### Scenario: No snapshot received yet
- **WHEN** the watch has never received a snapshot
- **THEN** the watch app and complications render placeholders without crashing

## MODIFIED Requirements

### Requirement: Shared widget snapshot
The app SHALL publish a snapshot of the current training state (today's planned session, this week's done/target training minutes, this week's done/target hard sessions, and — when available — the readiness score with its label and the current streak weeks) to a shared App Group container, encoded as a codec-stable format that widgets can read without launching the app. The readiness and streak fields SHALL be optional so that snapshots persisted by earlier app versions still decode.

#### Scenario: Snapshot round-trips
- **WHEN** a `WidgetSnapshot` including readiness and streak fields is encoded and then decoded
- **THEN** the decoded value equals the original

#### Scenario: Legacy snapshot still decodes
- **WHEN** a snapshot JSON produced before the readiness/streak fields existed is decoded
- **THEN** decoding succeeds and the new fields are nil

#### Scenario: Snapshot updates after logging
- **WHEN** the user logs a workout
- **THEN** the published snapshot reflects the new weekly done minutes and streak, and the widgets are asked to reload

#### Scenario: Missing container is safe
- **WHEN** no snapshot has been written (or the App Group container is unavailable)
- **THEN** reading returns no snapshot and widgets render their placeholder without crashing

### Requirement: Watch complication shows next session
The watch SHALL provide complications for the next non-rest planned session, the readiness score, and the current streak. The next-session complication SHALL prefer the cached snapshot and SHALL fall back to the locally computed plan when no snapshot is cached. Readiness and streak complications SHALL render placeholders when their fields are absent.

#### Scenario: Complication shows next session
- **WHEN** the watch complication is rendered
- **THEN** the circular family shows the session glyph and the corner family shows the session type and duration of the next non-rest session

#### Scenario: Next session prefers snapshot
- **WHEN** a cached snapshot exists with a today session
- **THEN** the next-session complication displays the snapshot's session rather than the locally computed default

#### Scenario: Readiness and streak complications render
- **WHEN** the cached snapshot contains readinessValue 80 and streakWeeks 3
- **THEN** the readiness complication shows 80 and the streak complication shows 3 weeks
