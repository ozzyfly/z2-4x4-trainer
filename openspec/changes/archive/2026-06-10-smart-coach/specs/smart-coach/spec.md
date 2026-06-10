## ADDED Requirements

### Requirement: Adaptive plan progression
The plan SHALL progress when recent weekly targets are met, hold when they are missed, and deload
periodically, deterministically from training history.

#### Scenario: Progress after consistent weeks
- **WHEN** the athlete met the weekly training-minute target for the last 3 weeks
- **THEN** the adjusted plan adds volume (more Zone 2 minutes or an extra 4×4) versus the base plan

#### Scenario: Hold after a missed week
- **WHEN** the most recent week missed the target
- **THEN** the adjusted plan keeps the base volume (no increase)

#### Scenario: Deload week
- **WHEN** the current week is a scheduled deload (every 4th progression week)
- **THEN** the adjusted plan reduces volume below the base plan

### Requirement: Fitness trend from VO2max
The app SHALL present the user's VO2max over time when Apple Health has VO2max samples.

#### Scenario: Trend shown
- **WHEN** Health returns VO2max samples
- **THEN** History shows a dated VO2max line; the latest value and its change are summarized

#### Scenario: No VO2max data
- **WHEN** Health has no VO2max samples
- **THEN** History shows a friendly empty state instead of an empty chart

### Requirement: Coach card
Today SHALL show a coach summary of the adapted week plus one short, relevant tip.

#### Scenario: Coach summary
- **WHEN** Today is shown
- **THEN** a Coach card states the adapted week (e.g. "3 Zone 2 + 1× 4×4") and one tip
