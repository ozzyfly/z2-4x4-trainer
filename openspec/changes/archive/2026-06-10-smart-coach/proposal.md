## Why

The weekly plan is static and the app shows effort but not **fitness progress**. A Norwegian-4×4
app's killer loop is showing VO2max rising and adapting the plan to what the user actually does.
This turns the app from a workout list into a coach.

## What Changes

- Read **VO2max** from Apple Health and show a **fitness-trend** chart on History.
- Add **adaptive plan progression**: the weekly plan progresses when the user consistently hits
  targets (more minutes / an extra 4×4), holds when they slip, and deloads periodically.
- Surface a **Coach card** on Today: this week's adapted plan + one short coaching tip.

## Non-Goals

- No GPS/pace or computing VO2max ourselves (read-only from Health).
- No backend/ML — progression is deterministic, rule-based, and unit-tested.

## Capabilities

### New Capabilities

- `smart-coach`: an adaptive, progressing training plan plus a fitness-trend (VO2max) view driven by real history.

### Modified Capabilities

<!-- none: base TrainingPlan stays; progression wraps it -->

## Impact

- `SharedCore`: `PlanProgression.adjust(base:history:profile:)`, `FitnessTrend` + tests (reuse `TrainingPlan`, `ActivityAggregator`, `TargetsCalculator`).
- `HealthService`: read VO2max series (`HKQuantityType(.vo2Max)`) added to `HealthProviding`/impl/mock.
- `App`: `TodayView` Coach card; `HistoryView` fitness-trend chart (Swift Charts + design system).
