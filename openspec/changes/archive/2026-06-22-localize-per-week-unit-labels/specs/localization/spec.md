## ADDED Requirements

### Requirement: Per-week unit labels are localized
All user-facing per-week unit labels SHALL be produced through the String Catalog so they translate in every shipped locale (en, zh-Hant, es, ja). This covers the weight-loss rate label ("kg/week" / "lb/week") on the Settings and Onboarding screens, and the per-week stat labels on the Week screen: the hard-session count ("N/week") and the exercise energy ("N kcal/week"). The rate's numeric value SHALL be formatted with the current locale's conventions (for example, its decimal separator).

#### Scenario: Rate label translates in a non-English locale
- **WHEN** the app runs in Spanish and shows the weight-loss rate
- **THEN** the unit period reads "/semana" (e.g. "kg/semana"), not "kg/week"

#### Scenario: Week stat labels translate
- **WHEN** the app runs in a non-English locale and shows the Week screen hard-session and energy stats
- **THEN** the "/week" and "kcal/week" period appears in the localized form
