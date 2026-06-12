## ADDED Requirements

### Requirement: Runtime string-catalog lookup for dynamic UI text
UI components that receive display text through `String`-typed parameters SHALL route user-facing labels through the String Catalog (via `LocalizedStringKey` parameters or `String(localized:)` at the call site) so that switching the app language localizes them at runtime. Weekday abbreviations in charts SHALL come from the locale's calendar symbols rather than hardcoded English arrays.

#### Scenario: Stepper titles localize
- **WHEN** the app runs in Spanish or Japanese and Settings or onboarding shows stepper rows (Age, Max HR, Resting HR, Rate)
- **THEN** the row titles render in the active language

#### Scenario: Activity levels show display names
- **WHEN** the activity pickers in Settings and onboarding render
- **THEN** each level shows a localized display name, not the raw enum value

#### Scenario: Chart text localizes
- **WHEN** the History screen renders in Spanish or Japanese
- **THEN** the minutes-chart caption, VO2 trend caption and latest-value summary, and weekday axis labels render localized, with weekday abbreviations taken from the locale's calendar

#### Scenario: Zone chips localize
- **WHEN** the Today screen's zone chips render in Spanish
- **THEN** the chip titles render localized (e.g., "Zona 2")

### Requirement: Plural-aware streak strings
Strings that embed a week count SHALL declare plural variations in the String Catalog for languages with singular/plural agreement, so a count of 1 renders the singular form.

#### Scenario: Spanish singular streak
- **WHEN** the streak banner renders in Spanish with a 1-week streak
- **THEN** it shows "Racha de 1 semana" (not "1 semanas")

##### Example: Streak plural forms

| Language | Count | Rendered |
| -------- | ----- | -------- |
| es | 1 | Racha de 1 semana |
| es | 3 | Racha de 3 semanas |
| en | 1 | 1-week streak |
