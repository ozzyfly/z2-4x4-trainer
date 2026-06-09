## Why

Glanceable surfaces drive daily re-engagement. Today's session and weekly progress should be one
glance away on the Home/Lock screen and the watch face.

## What Changes

- A **WidgetKit** extension: Home + Lock-screen widgets (today's session, weekly progress ring).
- A **Watch complication** showing the next session.
- Share a small data snapshot via an **App Group** so widgets read without launching the app.

## Non-Goals
- No interactive widgets beyond deep-link tap. No live timer in widget.

## Capabilities
### New Capabilities
- `widgets-complication`: home/lock widgets + a watch complication fed by a shared snapshot.
### Modified Capabilities
<!-- none -->

## Impact
- New widget extension target(s) in `project.yml`; App Group entitlement; a tiny shared snapshot writer.
  Reuses `TrainingPlan`/`TargetsCalculator`. **Roadmap (Round 2).**
