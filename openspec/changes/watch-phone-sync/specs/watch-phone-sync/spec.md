## ADDED Requirements

### Requirement: Completed Watch workout syncs to the iPhone
The Watch app SHALL transfer a completed workout to the paired iPhone over WatchConnectivity,
and the iPhone SHALL persist it as a `WorkoutLog`.

#### Scenario: Workout finished on the Watch reaches the phone
- **WHEN** a user ends a Zone 2 or Norwegian 4×4 session on the Apple Watch
- **THEN** the Watch sends the session (date, type, duration, active energy, Health UUID) to the iPhone
- **AND** the iPhone inserts a matching `WorkoutLog` that appears in Today, Week, and History

#### Scenario: Phone unreachable at end of workout
- **WHEN** the iPhone is not reachable as the workout ends
- **THEN** the Watch SHALL queue the session for background transfer
- **AND** the iPhone SHALL persist it once delivery completes

##### Example: queued then delivered
- **GIVEN** a finished 4×4 session with healthUUID `ABC-123` and `WCSession.isReachable == false`
- **WHEN** the Watch calls `transferUserInfo` and the phone reconnects 2 minutes later
- **THEN** the iPhone stores one `WorkoutLog` with healthUUID `ABC-123`

### Requirement: Synced workouts are not duplicated
The iPhone SHALL NOT create a second `WorkoutLog` for a Watch session it has already stored.

#### Scenario: Same session delivered twice
- **WHEN** the iPhone receives a session whose Health UUID matches an existing `WorkoutLog`
- **THEN** the iPhone SHALL skip insertion and leave the existing record unchanged

### Requirement: Watch target compiles and runs
The `Z24x4TrainerWatch` target SHALL build for the watchOS simulator and run on a physical
Apple Watch, displaying live heart rate, current zone, and 4×4 interval cues.

#### Scenario: Watch build succeeds after SDK install
- **WHEN** the watchOS SDK is installed and the watch target is built
- **THEN** the build SHALL succeed with no errors

##### Example: clean watch build
- **GIVEN** `xcodebuild -downloadPlatform watchOS` has completed
- **WHEN** running `xcodebuild build -scheme Z24x4TrainerWatch -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)'`
- **THEN** the output contains `** BUILD SUCCEEDED **`

#### Scenario: Live session on hardware
- **WHEN** a Norwegian 4×4 session runs on a physical Apple Watch
- **THEN** the screen SHALL show the current heart rate and zone
- **AND** a haptic SHALL fire at each interval transition
