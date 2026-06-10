## Why

The app has no habit loop. Streaks, badges, and small celebrations make training sticky and
rewarding — proven retention drivers — and they're fully local (no backend).

## What Changes

- Compute **training streaks** (current + longest) from workout history.
- Define an **achievement catalog** (e.g. first 4×4, 7-day streak, 10 sessions, weekly target ×4,
  VO2max up) and evaluate which are unlocked.
- Show a **streak banner** on Today, an **Achievements** screen (badge grid, locked/unlocked), and a
  **celebration** (confetti + haptic) when something unlocks or the day's target is met.

## Non-Goals

- No leaderboards / social / sharing (sharing is a separate roadmap epic).
- No server — unlock state stored locally in SwiftData.

## Capabilities

### New Capabilities

- `streaks-achievements`: local streak tracking, an achievement system, and celebratory feedback.

### Modified Capabilities

<!-- none -->

## Impact

- `SharedCore`: `StreakCalculator`, `Achievement` catalog + `AchievementEvaluator` + tests (reuse `ActivitySample`/`ActivityAggregator`).
- `App`: `StreakBanner` (Today), `AchievementsView` (new), celebration overlay, `AchievementRecord` (SwiftData), Achievements entry in navigation.
