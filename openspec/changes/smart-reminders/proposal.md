## Why

Gentle nudges on plan days (or when behind the weekly target) keep the habit going — no backend needed.

## What Changes

- Schedule **local notifications** for plan training days and a weekly catch-up nudge, with a
  user toggle + quiet-hours respect.

## Non-Goals
- No push server. No spammy frequency — opt-in, limited.

## Capabilities
### New Capabilities
- `smart-reminders`: local notification reminders for plan days and weekly-target catch-up.
### Modified Capabilities
<!-- none -->

## Impact
- `App`: `UNUserNotificationCenter` scheduling, Settings toggle. Reuses `TrainingPlan`. **Roadmap (Round 2).**
