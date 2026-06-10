## Why

Zones are currently age-based only (maxHR = 220 − age). Athletes with a known resting HR or true
max get more accurate prescriptions from heart-rate-reserve (Karvonen) or custom zones. More
accuracy = better training.

## What Changes

- Add a `ZoneMethod` (`.ageMax` / `.karvonen` / `.custom`) to the profile.
- Extend `HRZoneCalculator` to compute zones via **Karvonen/HRR** (using resting HR) and via
  user-defined **custom** bands, alongside the existing age-max method.
- Let the user pick the method (and edit custom bands) in Settings; persist it.

## Non-Goals

- Lactate-threshold (LTHR) field test — roadmap (`readiness-hrv`/later).
- Changing the default for existing behavior: `.ageMax` stays the default.

## Capabilities

### New Capabilities

- `precision-zones`: compute heart-rate zones by age-max, Karvonen/HRR, or custom bands, user-selectable.

### Modified Capabilities

<!-- none: additive; existing age-max behavior unchanged -->

## Impact

- `SharedCore`: `UserProfile` (+`zoneMethod`, `customZones`), `HRZoneCalculator` (HRR + custom paths) + tests.
- `App`: `SettingsView` (method picker + custom editor), `ProfileRecord` (+fields, lightweight migration).
- Today/Workout-detail auto-benefit (they already read the calculator).
