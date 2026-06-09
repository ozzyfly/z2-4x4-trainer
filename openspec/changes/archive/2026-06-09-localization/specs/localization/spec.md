## ADDED Requirements

### Requirement: String Catalog drives UI localization
The app SHALL use a String Catalog (`Localizable.xcstrings`) with English as the source language, from which core user-facing UI strings (tab labels, screen titles, primary actions, section headers) are localized.

#### Scenario: Catalog provides translations
- **WHEN** the app is built
- **THEN** the String Catalog compiles and its localized strings are available to the UI

### Requirement: Section headers are localizable
Section headers SHALL accept a localizable key so their text is translated like other UI strings.

#### Scenario: Header localizes
- **WHEN** the device language is a supported non-English language with a translated header
- **THEN** the section header shows the translated text rather than the English source

### Requirement: Traditional Chinese is provided
The core UI chrome SHALL be fully translated into Traditional Chinese (zh-Hant).

#### Scenario: zh-Hant shows translated chrome
- **WHEN** the app runs with the language set to Traditional Chinese
- **THEN** the tab labels, screen titles, and primary actions appear in Traditional Chinese

### Requirement: Additional languages registered with safe fallback
Spanish (es) and Japanese (ja) SHALL be registered, and any untranslated string SHALL fall back to the English source without error.

#### Scenario: Missing translation falls back
- **WHEN** the app runs in a registered language for which a given string has no translation
- **THEN** the English source string is shown and the app does not crash
