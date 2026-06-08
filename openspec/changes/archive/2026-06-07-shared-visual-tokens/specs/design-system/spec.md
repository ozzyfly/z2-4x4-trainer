## MODIFIED Requirements

### Requirement: Shared design system
The app SHALL provide reusable theme tokens and components (`Card`, `SectionHeader`, `TargetBar`, `PrimaryButton`, `SecondaryButton`, `ZoneChip`, accent color) that every screen uses. The HR-zone and interval-kind visual tokens (color and SF-Symbol glyph) SHALL be defined once in `SharedCore` so the iOS and watchOS targets share a single source rather than duplicating them.

#### Scenario: Components render consistently
- **WHEN** any restyled screen is shown
- **THEN** it uses the shared card, header, accent, and progress components rather than default `Form` styling

#### Scenario: Zone and interval tokens have one definition
- **WHEN** the iOS app or the watchOS app renders an HR-zone color, an HR-zone name, or an interval-kind color
- **THEN** it resolves the value from the `SharedCore` token definitions, and no target redefines those tokens locally

## ADDED Requirements

### Requirement: Non-color token signal
Each HR-zone and each interval-kind SHALL expose a non-color signal (an SF-Symbol glyph) alongside its color, so that adopting screens can convey the state without relying on color alone.

#### Scenario: Every zone and interval kind has a glyph
- **WHEN** code requests the glyph for any `HRZone` case or any `IntervalKind` case
- **THEN** a non-empty SF-Symbol name is returned that is distinct per case

##### Example: zone glyphs
| Case | Color | Glyph |
| ---- | ----- | ----- |
| zone1 | gray | 1.circle.fill |
| zone2 | green | 2.circle.fill |
| zone3 | blue | 3.circle.fill |
| zone4 | orange | 4.circle.fill |
| zone5 | red | 5.circle.fill |

##### Example: interval-kind glyphs
| Case | Color | Glyph |
| ---- | ----- | ----- |
| warmup | blue | figure.walk |
| hard | red | bolt.fill |
| recovery | green | arrow.down.heart.fill |
| cooldown | teal | wind |

### Requirement: Zone colors preserved across the move
Moving the tokens into `SharedCore` SHALL NOT change any existing color value. The zone color mapping (zone1 gray, zone2 green, zone3 blue, zone4 orange, zone5 red) and the interval mapping (warmup blue, hard red, recovery green, cooldown teal) SHALL stay identical to the pre-move iOS and watch definitions.

#### Scenario: Visuals unchanged after refactor
- **WHEN** a screen that previously rendered a zone or interval color is shown after the tokens move to `SharedCore`
- **THEN** the rendered color is identical to before the move
