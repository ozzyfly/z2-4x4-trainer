## ADDED Requirements

### Requirement: Accessible semantic color tokens
The design system SHALL provide semantic status color tokens — `success`, `warning`, `danger`, and `info` — each exposing a foreground/background pairing that maintains a contrast ratio of at least 4.5:1 against its intended surface in both light and dark appearance. Screens SHALL use these tokens instead of raw system colors (`.green`, `.orange`, `.red`) for status indication.

#### Scenario: Status tokens are legible in both appearances
- **WHEN** a status token is rendered as foreground text on its paired surface in light, then dark appearance
- **THEN** the text remains legible with a measured contrast ratio of at least 4.5:1 in both

##### Example: token contrast targets
| Token | Use | Min contrast (text on paired surface) |
| ----- | --- | ------------------------------------- |
| success | "Ready" readiness, positive trend | 4.5:1 |
| warning | "Caution" readiness, required-field notice | 4.5:1 |
| danger | "Rest" readiness, negative trend | 4.5:1 |
| info | neutral/secondary callout | 4.5:1 |

### Requirement: Color is never the only signal
Where the design system conveys state through color, it SHALL also provide a non-color signal (symbol, sign, or text) so that the state is distinguishable without color perception.

#### Scenario: State distinguishable without color
- **WHEN** a status or trend indicator is shown
- **THEN** a glyph, +/− sign, or text label communicates the same state as the color does

### Requirement: Secondary button component
The design system SHALL provide a `SecondaryButton` component that matches `PrimaryButton` in size and tap target but renders a visually subordinate (tinted/bordered) style, with the same press animation and `.sensoryFeedback` haptic on activation.

#### Scenario: Secondary action is visually subordinate yet equally tappable
- **WHEN** a `SecondaryButton` is placed alongside a `PrimaryButton`
- **THEN** it reads as the lower-priority action while keeping a tap target of at least 44×44pt and firing a haptic on tap

### Requirement: Accessible stepper component
The design system SHALL provide an `AccessibleStepper` wrapper that exposes a single accessibility element with a distinct label and value, an increment/decrement hint, and a tap target of at least 44×44pt. VoiceOver SHALL announce the control as its label followed by its current value.

#### Scenario: VoiceOver reads label then value
- **WHEN** VoiceOver focuses an `AccessibleStepper` labelled "Age" with value 30
- **THEN** it announces "Age, 30" with adjustable increment/decrement actions, not a single concatenated phrase

### Requirement: Reduce Motion respected by motion helper
The design system SHALL provide a motion helper that reads the system Reduce Motion setting. When Reduce Motion is enabled, animations applied through the helper SHALL degrade to an immediate, non-animated state change.

#### Scenario: Animation degrades under Reduce Motion
- **WHEN** Reduce Motion is enabled and a state change is applied through the motion helper
- **THEN** the final state is reached without an animated transition

#### Scenario: Animation plays when Reduce Motion is off
- **WHEN** Reduce Motion is disabled and the same state change is applied
- **THEN** the transition animates normally

## MODIFIED Requirements

### Requirement: Accessibility
Screens SHALL support Dynamic Type and expose VoiceOver labels for non-text indicators. Text styled as all-caps SHALL use the `.textCase(.uppercase)` modifier rather than uppercasing the underlying string, so VoiceOver pronunciation and Dynamic Type are preserved.

#### Scenario: Large type and VoiceOver
- **WHEN** the device uses a large Dynamic Type size and VoiceOver is on
- **THEN** text scales without clipping and non-text indicators expose meaningful labels

#### Scenario: All-caps headers keep correct pronunciation
- **WHEN** VoiceOver reads a `SectionHeader` containing a term such as "VO2max"
- **THEN** it pronounces the term naturally rather than spelling each letter, because the casing is applied via `.textCase` not an uppercased string
