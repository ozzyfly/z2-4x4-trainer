## Why

Hard sessions on under-recovered days hurt progress. A morning readiness signal helps the user
train hard when fresh and back off when not.

## What Changes

- Read HRV (heart-rate variability) + resting HR from Apple Health.
- Compute a daily **readiness score** (baseline-relative) and surface it on Today with a
  "go hard / go easy / rest" suggestion that can nudge the prescribed session.

## Non-Goals
- No medical claims; guidance only. No backend.

## Capabilities
### New Capabilities
- `readiness-hrv`: a recovery-aware daily readiness score that adapts today's recommendation.
### Modified Capabilities
<!-- none -->

## Impact
- `SharedCore`: readiness algorithm (baseline + deviation) + tests. `HealthService`: HRV/RHR reads.
  `App`: Today readiness chip. **Roadmap (Round 2).**
