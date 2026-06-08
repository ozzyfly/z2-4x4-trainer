## Summary

將 HR 區間與間歇類型的視覺 token（顏色 + 非色彩 glyph）集中到 `SharedCore`，讓 iOS 與 watchOS 兩個 target 共用單一來源，並補上色盲可辨的符號。

## Motivation

`HRZone` 的顏色/名稱與 `IntervalKind` 的 banner 顏色目前在三處重複定義：

- `App/DesignSystem/ZoneStyle.swift`（iOS：`HRZone.color`、`label`）
- `App/Views/WorkoutDetailView.swift`（iOS：`IntervalKind.bannerColor`）
- `Watch/LiveWorkoutView.swift`（watch：同樣的 `HRZone` 與 `IntervalKind` 行內 extension）

watch target 只能 import `SharedCore`（不能 import `App/DesignSystem`），所以顏色被手動複製、易走樣。Round-3 要做 watch 螢幕無障礙改版與 iOS IntervalRow 加符號，兩者都需要這些 token——先把它們抽到唯一來源，並加入 SF Symbol glyph 作為非色彩訊號的依據，後續變更才能一致採用。

## Proposed Solution

在 `SharedCore` 內以 `import SwiftUI` 新增兩個 UI 擴充檔（`SharedCore` 已支援 iOS 18 / watchOS 11 / macOS 14，兩個 app 皆 import 它）：

- `SharedCore/Sources/SharedCore/HRZone+UI.swift`：`public extension HRZone`，提供 `color: Color`、`displayName: String`、`glyph: String`（SF Symbol，如 `1.circle.fill`…`5.circle.fill`）。
- `SharedCore/Sources/SharedCore/IntervalKind+UI.swift`：`public extension IntervalKind`，提供 `bannerColor: Color`、`glyph: String`（warmup `figure.walk`、hard `bolt.fill`、recovery `arrow.down.heart.fill`、cooldown `wind`）。

顏色值沿用現有對應（z1 gray、z2 green、z3 blue、z4 orange、z5 red；warmup blue、hard red、recovery green、cooldown teal），確保視覺不變。

刪除三處重複定義：`App/DesignSystem/ZoneStyle.swift` 整檔、`App/Views/WorkoutDetailView.swift` 內的 `IntervalKind.bannerColor` extension、`Watch/LiveWorkoutView.swift` 內的 `HRZone`/`IntervalKind` 行內 extension。呼叫端（`HRZone.zone2.color`、`kind.bannerColor`、`zone.displayName`）名稱不變，免改。iOS 既有 `HRZone.label`（無呼叫端）一併移除。

## Non-Goals

- 不採用新的 glyph 到任何畫面（IntervalRow、watch zone label 的採用屬 round-3 後續變更 `ios-detail-polish`、`watch-screen-polish`）。
- 不改顏色值、不改任何畫面外觀。
- 不改 domain 邏輯（`HRZone`/`IntervalKind` 列舉本身不動）。
- 不新增 SPM target（以 `SharedCore` 內擴充達成，不另建 SharedUI 套件）。

## Alternatives Considered

- **新建 `SharedUI` SPM target**：被否決——需改 `project.yml` packages、兩 target 依賴與 xcodegen，較重；`SharedCore` 已是唯一共用層，直接在其內加 UI 擴充最省。
- **維持各自複製**：被否決——三處重複，round-3 的 watch 與 iOS 採用會持續分歧。

## Impact

- Affected specs: `design-system`（MODIFIED：視覺語言跨 iOS/watch 共用、HRZone/IntervalKind 提供非色彩 glyph）
- Affected code:
  - New:
    - SharedCore/Sources/SharedCore/HRZone+UI.swift
    - SharedCore/Sources/SharedCore/IntervalKind+UI.swift
  - Modified:
    - App/Views/WorkoutDetailView.swift
    - Watch/LiveWorkoutView.swift
  - Removed:
    - App/DesignSystem/ZoneStyle.swift
