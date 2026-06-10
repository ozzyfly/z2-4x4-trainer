## MODIFIED Requirements

### Requirement: String Catalog drives UI localization
The app SHALL use a String Catalog (`Localizable.xcstrings`) with English as the source language, from which user-facing UI strings are localized — including strings produced by helper functions or string interpolation, which SHALL be wrapped with `String(localized:)` so they resolve through the catalog rather than displaying the English source verbatim.

#### Scenario: Catalog provides translations
- **WHEN** the app is built
- **THEN** the String Catalog compiles and its localized strings are available to the UI

#### Scenario: Function-produced strings localize
- **WHEN** the device language is Traditional Chinese and a readiness title, coaching tip, week summary, session display name, or rest-day caption is shown
- **THEN** the translated text is displayed rather than the English source
