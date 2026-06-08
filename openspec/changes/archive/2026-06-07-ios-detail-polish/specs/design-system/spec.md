## ADDED Requirements

### Requirement: Interval rows convey kind without color
An interval row SHALL convey the interval kind with a non-color signal (the interval-kind glyph) in addition to its colored bar, so the kind is distinguishable without color perception.

#### Scenario: Interval kind shown with glyph
- **WHEN** an interval row for a Norwegian 4×4 structure is shown
- **THEN** the interval kind is conveyed by a glyph (and text) alongside the colored bar, not by color alone

### Requirement: Share card is accessible
The shareable summary card SHALL expose a single combined accessibility element summarizing its content (week minutes, sessions, streak), and its title SHALL not overflow its fixed-width layout.

#### Scenario: Share card has an accessibility summary
- **WHEN** VoiceOver focuses the share card
- **THEN** it announces a summary including the week's minutes, session count, and streak

#### Scenario: Title fits the card
- **WHEN** the share card renders its title
- **THEN** the title stays on one line within the fixed card width, scaling down if needed rather than wrapping or clipping

### Requirement: Charts label their axes and units
History charts SHALL show Y-axis scale marks and state the metric/unit, so a value can be read without external context.

#### Scenario: Chart shows axis and unit
- **WHEN** a History chart with data is shown
- **THEN** it displays Y-axis scale marks and a caption naming the metric and unit

### Requirement: Zone colors are not reused for non-zone metrics
HR-zone colors SHALL be reserved for HR-zone contexts; a non-zone metric chart SHALL use a neutral/accent color rather than an HR-zone color.

#### Scenario: Weight chart uses a non-zone color
- **WHEN** the body-weight trend chart is shown
- **THEN** its line uses the accent (or a neutral metric) color, not an HR-zone color
