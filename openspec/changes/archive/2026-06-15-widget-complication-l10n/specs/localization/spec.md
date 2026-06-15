## ADDED Requirements

### Requirement: App extensions localize their own bundle strings
Each app extension that displays user-facing text (the Widgets extension and the WatchComplications extension) SHALL ship its own `Localizable.xcstrings` in that target so its strings resolve through a String Catalog rather than the English source. String-returning helpers used as display text SHALL be wrapped with `String(localized:)`, and count-bearing strings SHALL declare plural variations for languages with singular/plural agreement, matching the app target's localization behavior.

#### Scenario: Widget strings localize
- **WHEN** the device language is Spanish or Japanese and the user adds a Z2/4×4 widget
- **THEN** the widget's title, configuration display name, description, placeholder text, and unit labels render in the active language

#### Scenario: Complication strings localize
- **WHEN** the device language is Spanish or Japanese and the user adds a Z2/4×4 watch complication
- **THEN** the complication's configuration display name, description, and rendered labels render in the active language

#### Scenario: Helper-produced display text localizes
- **WHEN** a widget or complication renders text from a string-returning helper (session title, readiness label, streak count)
- **THEN** the text is localized, not the English source verbatim

#### Scenario: No needs-review entries remain
- **WHEN** the extension catalogs are populated and reviewed
- **THEN** the Widgets and WatchComplications String Catalogs contain zero needs-review entries for Spanish and Japanese

##### Example: Streak plural in widgets/complications

| Language | Count | Rendered |
| -------- | ----- | -------- |
| es | 1 | Racha de 1 semana |
| es | 3 | Racha de 3 semanas |
| en | 1 | 1-week streak |
