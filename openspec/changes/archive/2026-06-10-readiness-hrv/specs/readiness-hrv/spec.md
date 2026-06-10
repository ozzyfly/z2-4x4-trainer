## ADDED Requirements

### Requirement: Daily readiness score
The app SHALL compute a 0–100 readiness score from recent HRV and resting HR relative to the
user's own baseline, when Apple Health has the data.

#### Scenario: Above baseline reads high
- **WHEN** today's HRV is above the rolling baseline and resting HR is at or below baseline
- **THEN** readiness is high (≥ 67) and labelled "Go hard"

#### Scenario: Below baseline reads low
- **WHEN** today's HRV is well below baseline or resting HR is elevated
- **THEN** readiness is low (< 34) and labelled "Take it easy"

#### Scenario: No data
- **WHEN** Health has insufficient HRV/RHR history
- **THEN** no readiness score is shown (the UI hides the chip)

### Requirement: Readiness informs Today
Today SHALL surface the readiness score and a one-line recommendation when available.

#### Scenario: Chip on Today
- **WHEN** a readiness score exists
- **THEN** Today shows a readiness chip with the score, label, and a short recommendation
