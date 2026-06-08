## MODIFIED Requirements

### Requirement: Accessibility
Screens SHALL support Dynamic Type and expose VoiceOver labels for non-text indicators. Every screen SHALL adopt the design system's accessibility foundation: status is conveyed with a non-color signal in addition to color, steppers expose distinct label/value/hint, form fields expose accessibility labels, interactive controls keep a tap target of at least 44×44pt, and motion respects the Reduce Motion setting.

#### Scenario: Large type and VoiceOver
- **WHEN** the device uses a large Dynamic Type size and VoiceOver is on
- **THEN** text scales without clipping and non-text indicators expose meaningful labels

#### Scenario: Celebration respects Reduce Motion
- **WHEN** Reduce Motion is enabled and an achievement unlocks
- **THEN** the celebration reaches its final state without confetti or animated transitions

#### Scenario: Steppers announce label and value
- **WHEN** VoiceOver focuses any stepper on the Settings or Onboarding screen
- **THEN** it announces the field label followed by the current value, with increment and decrement actions

#### Scenario: Status is distinguishable without color
- **WHEN** the readiness indicator, a History fitness-trend delta, or an HR zone chip is shown
- **THEN** a glyph, +/− sign, or text label conveys the state in addition to color

##### Example: trend delta encodes direction
| Delta | Color | Non-color signal | VoiceOver |
| ----- | ----- | ---------------- | --------- |
| +2.1 | success | "▲ +2.1" | "improved by 2.1" |
| -1.4 | danger | "▼ −1.4" | "declined by 1.4" |

#### Scenario: History chart is readable by VoiceOver
- **WHEN** VoiceOver navigates the weekly training-minutes chart with data present
- **THEN** it announces a per-day value summary rather than nothing

#### Scenario: Form fields are labelled
- **WHEN** VoiceOver focuses the weight, height, or active-energy field on Onboarding or manual entry
- **THEN** it announces a descriptive label (e.g., "Weight in kilograms") rather than only a placeholder

#### Scenario: Tap targets meet minimum size
- **WHEN** an interactive control such as the daily-target completion mark or an achievement badge cell is shown
- **THEN** its tap target is at least 44×44pt

#### Scenario: Locked badges are distinguishable
- **WHEN** the Achievements grid shows locked and unlocked badges
- **THEN** locked state is conveyed by a lock glyph with sufficient contrast, not by opacity alone
