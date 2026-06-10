## ADDED Requirements

### Requirement: Selectable zone method
The calculator SHALL compute zones by age-max, Karvonen/HRR, or custom bands per the profile's
selected method, defaulting to age-max.

#### Scenario: Karvonen uses heart-rate reserve
- **WHEN** the method is Karvonen with maxHR 190 and resting HR 50
- **THEN** the Zone 2 band uses reserve: lower = 50 + 0.60·(190−50), upper = 50 + 0.70·(190−50)

#### Scenario: Age-max default unchanged
- **WHEN** the method is age-max with maxHR 190
- **THEN** Zone 2 is 114–133 bpm, exactly as before this change

#### Scenario: Custom bands honored
- **WHEN** the method is custom with a user-set Zone 2 band of 120–140
- **THEN** the calculator returns 120–140 for Zone 2

### Requirement: Karvonen needs resting HR
The app SHALL fall back to age-max when Karvonen is selected without a resting HR.

#### Scenario: Missing resting HR
- **WHEN** Karvonen is selected but resting HR is nil
- **THEN** zones are computed by age-max and the UI prompts for resting HR
