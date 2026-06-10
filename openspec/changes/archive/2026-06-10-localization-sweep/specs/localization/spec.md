## ADDED Requirements

### Requirement: Function-produced and SharedCore strings localize
User-facing strings produced by helper functions, string interpolation, or defined in the `SharedCore` package SHALL localize through a String Catalog rather than displaying the English source. App-target interpolated/function strings SHALL use `String(localized:)`; SharedCore strings SHALL use `String(localized:bundle: .module)` with the package's String Catalog and `defaultLocalization`.

#### Scenario: Remaining App screens localize
- **WHEN** the device language is Traditional Chinese and the Week, Settings, History, Onboarding, or Achievements screen is shown
- **THEN** its user-facing labels appear in Traditional Chinese rather than English

#### Scenario: SharedCore strings localize
- **WHEN** the device language is Traditional Chinese and an achievement title/detail or a readiness recommendation is shown
- **THEN** the translated text is displayed rather than the English source

#### Scenario: Untranslated falls back
- **WHEN** a string lacks a translation for the current language
- **THEN** the English source is shown without error
