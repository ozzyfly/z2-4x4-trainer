## ADDED Requirements

### Requirement: Snapshot refreshes after Apple Health import
When the app imports workouts from Apple Health and at least one new `WorkoutLog` is created, the app SHALL refresh the shared widget snapshot so the Home and Lock widgets and the watch complication reflect the imported workouts' contribution to this week's done minutes and hard sessions. When an import creates no new records — because every returned workout is already logged (deduped by health UUID) or no workouts are returned — the app SHALL NOT refresh the snapshot.

#### Scenario: Importing a new Health workout refreshes the snapshot
- **WHEN** the app imports an Apple Health workout whose health UUID is not already logged
- **THEN** the published snapshot's weekly done minutes include the imported workout's duration
- **AND** the widgets are asked to reload

#### Scenario: An import with no new workouts does not refresh
- **WHEN** every workout returned by the import already exists in the store (deduped by health UUID)
- **THEN** the snapshot is not rewritten
