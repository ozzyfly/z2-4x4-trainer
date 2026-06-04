## ADDED Requirements

### Requirement: Distributable signed build
The `Z24x4Trainer` app SHALL be archivable and uploadable to App Store Connect with a valid
distribution signing identity and the HealthKit capability enabled.

#### Scenario: Archive uploads to App Store Connect
- **WHEN** the developer archives `Z24x4Trainer` with automatic signing under the enrolled team
- **THEN** the archive validates and uploads to App Store Connect with no signing or capability errors

### Requirement: Privacy compliance for HealthKit
The submission SHALL include a reachable privacy-policy URL and an App Privacy label that
declares the app does not collect or transmit user data.

#### Scenario: Privacy policy is reachable
- **WHEN** App Store review opens the privacy-policy URL recorded for the app
- **THEN** the page loads and states that Health data stays on device and is never shared or used for advertising

#### Scenario: Privacy label matches behavior
- **WHEN** the App Privacy questionnaire is answered
- **THEN** every Health data type is marked Data Not Collected, consistent with the local-only implementation

### Requirement: Release metadata and assets present
The App Store record SHALL carry a final (non-placeholder) icon, the required screenshots, and
complete listing metadata before submission.

#### Scenario: Listing is complete
- **WHEN** the developer submits the app for review
- **THEN** the 1024² icon is final artwork, iPhone screenshots are attached, and name/subtitle/description/keywords/category are filled

### Requirement: TestFlight build passes before submission
A build SHALL install and run a full Zone 2 and Norwegian 4×4 session via TestFlight before the
app is submitted for review.

#### Scenario: Internal TestFlight run
- **WHEN** an internal tester installs the TestFlight build and completes one Zone 2 and one 4×4 session
- **THEN** the app records both sessions and shows updated Today/Week/History without crashing
