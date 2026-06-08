## Context

HR 區間與間歇類型的視覺 token 在 iOS（`App/DesignSystem/ZoneStyle.swift`、`App/Views/WorkoutDetailView.swift`）與 watch（`Watch/LiveWorkoutView.swift`）重複定義。watch target 只能 import `SharedCore`。本變更把 token 抽到 `SharedCore`，並加 SF Symbol glyph，作為 round-3 後續 iOS/watch 採用的基礎。純呈現層，不動 domain 邏輯或顏色值。

## Goals / Non-Goals

**Goals:**

- `HRZone` 與 `IntervalKind` 的 color 與 glyph 在 `SharedCore` 唯一定義，兩 target 共用。
- 顏色值與既有完全一致（視覺不變）。
- 刪除三處重複定義；呼叫端名稱不變、免改。

**Non-Goals:**

- 不在任何畫面採用新 glyph（屬後續變更）。
- 不改顏色、不改畫面外觀、不動 domain 列舉。
- 不新增 SPM target。

## Decisions

- **放在 `SharedCore` 內**：新增 `HRZone+UI.swift`、`IntervalKind+UI.swift`，以 `import SwiftUI` 提供 `Color`/glyph。`SharedCore` 平台為 iOS18/watchOS11/macOS14，SwiftUI 於三者皆可用；`swift test`（macOS host）亦能編譯。權衡：`SharedCore` 取得 SwiftUI 相依（領域層輕度耦合 UI），以獨立 `+UI.swift` 檔隔離。
- **命名沿用**：`HRZone.color`、`HRZone.displayName`、`IntervalKind.bannerColor` 維持原名，呼叫端不改。新增 `HRZone.glyph`、`IntervalKind.glyph`。
- **移除 `HRZone.label`**：iOS `ZoneStyle.label` 無呼叫端，刪除（以 `displayName` 為準）。
- **glyph 選用**：zone 用數字圓圈 `1.circle.fill`…`5.circle.fill`；interval 用 `figure.walk`/`bolt.fill`/`arrow.down.heart.fill`/`wind`。

## Implementation Contract

**Behavior（可觀察）：**

- `HRZone.<case>.color` 回傳與移動前相同顏色（z1 gray…z5 red）；`HRZone.<case>.displayName` 回傳 "Zone N"；`HRZone.<case>.glyph` 回傳上表 SF Symbol。
- `IntervalKind.<case>.bannerColor` 回傳與移動前相同（warmup blue、hard red、recovery green、cooldown teal）；`.glyph` 回傳上表 SF Symbol。
- 兩 target build 後畫面顏色不變。

**Interface / 形狀：**

- 新檔 `SharedCore/Sources/SharedCore/HRZone+UI.swift`：`public extension HRZone { var color: Color; var displayName: String; var glyph: String }`。
- 新檔 `SharedCore/Sources/SharedCore/IntervalKind+UI.swift`：`public extension IntervalKind { var bannerColor: Color; var glyph: String }`。
- 刪除：`App/DesignSystem/ZoneStyle.swift`、`App/Views/WorkoutDetailView.swift` 內的 `extension IntervalKind { var bannerColor }`、`Watch/LiveWorkoutView.swift` 內的 `extension HRZone`/`extension IntervalKind`。

**Failure modes：**

- 若刪除後仍有目標 import 舊路徑 → 編譯期錯誤即現，須補 `import SharedCore`（兩 view 檔已 import）。
- glyph 名稱錯字 → 執行期顯示問號方塊；以 spec 範例表為準避免。

**Acceptance criteria：**

- `xcodegen generate` 後 `xcodebuild` iOS target 成功；watch target（`Z24x4TrainerWatch` scheme，watchOS 26.5 simulator）成功。
- `cd SharedCore && swift test` 通過（58/58）且 `SharedCore` 含 SwiftUI 檔仍能編譯。
- 全專案無 `HRZone`/`IntervalKind` 的重複 color/bannerColor 定義（grep 僅 `SharedCore` 各一處）。
- iOS 畫面（Today zones、WorkoutDetail bands、History weight chart）顏色與移動前一致。

**Scope boundaries：**

- In scope：新增 `SharedCore` 兩擴充檔；刪除三處重複；必要的 `import` 調整。
- Out of scope：採用 glyph 到畫面、改顏色、改 domain、改 watch UI 行為。

## Risks / Trade-offs

- **`SharedCore` 取得 SwiftUI 相依**：領域套件混入 UI；以 `+UI.swift` 命名與檔案隔離緩解，且 SwiftUI 於所有目標平台可用。
- **xcodegen 重生**：新增/刪除檔需 `xcodegen generate`（xcodeproj 為 gitignore），忘記會導致檔案未納入編譯——驗收步驟明列。
