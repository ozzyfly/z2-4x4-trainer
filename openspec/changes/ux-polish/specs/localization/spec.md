## ADDED Requirements

### Requirement: Spanish and Japanese are finalized
The Spanish and Japanese translations in the app and SharedCore String Catalogs SHALL be reviewed and marked as translated (not needs-review) before release, after all strings introduced in the same round are merged.

#### Scenario: No needs-review entries remain
- **WHEN** the round's catalog merge is complete and the es/ja review pass has run
- **THEN** the app and SharedCore String Catalogs contain zero needs-review entries for Spanish and Japanese

#### Scenario: Reviewed UI renders
- **WHEN** the app runs with the device language set to Spanish or Japanese
- **THEN** core screens render the reviewed translations with English fallback only for untranslated keys
