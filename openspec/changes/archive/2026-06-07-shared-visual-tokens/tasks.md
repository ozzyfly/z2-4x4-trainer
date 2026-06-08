## 1. SharedCore token 定義

- [x] 1.1 滿足需求「Non-color token signal」與「Zone colors preserved across the move」：新增 `SharedCore/Sources/SharedCore/HRZone+UI.swift`，以 `import SwiftUI` 提供 `public extension HRZone { var color: Color; var displayName: String; var glyph: String }`；color 沿用 z1 gray/z2 green/z3 blue/z4 orange/z5 red，glyph 用 `1.circle.fill`…`5.circle.fill`，displayName 用 "Zone N"。
- [x] 1.2 滿足需求「Non-color token signal」：新增 `SharedCore/Sources/SharedCore/IntervalKind+UI.swift`，以 `import SwiftUI` 提供 `public extension IntervalKind { var bannerColor: Color; var glyph: String }`；bannerColor 沿用 warmup blue/hard red/recovery green/cooldown teal，glyph 用 `figure.walk`/`bolt.fill`/`arrow.down.heart.fill`/`wind`。

## 2. 移除重複定義

- [x] 2.1 滿足需求「Shared design system」與「Zone and interval tokens have one definition」（token 單一來源）：刪除 `App/DesignSystem/ZoneStyle.swift` 整檔（其 `HRZone.color`/`label` 由 SharedCore 取代；`label` 無呼叫端）。
- [x] 2.2 刪除 `App/Views/WorkoutDetailView.swift` 內的 `extension IntervalKind { var bannerColor }`（改用 SharedCore）；確認檔案已 `import SharedCore`、`interval.kind.bannerColor` 呼叫端不變。
- [x] 2.3 刪除 `Watch/LiveWorkoutView.swift` 內的 `extension HRZone`（color/displayName）與 `extension IntervalKind { bannerColor }`；確認 `zone.color`/`zone.displayName`/`kind.bannerColor` 呼叫端改由 SharedCore 解析、行為不變。

## 3. 驗證

- [x] 3.1 執行 `xcodegen generate` 後，以 `xcodebuild` 編譯 iOS target（`Z24x4Trainer` scheme，iPhone 17 Pro simulator）成功。
- [x] 3.2 以 `xcodebuild` 編譯 watch target（`Z24x4TrainerWatch` scheme，watchOS 26.5 simulator）成功。
- [x] 3.3 `cd SharedCore && swift test` 通過（58/58），確認 SharedCore 含 SwiftUI 擴充仍可編譯；以 grep 確認全專案僅 `SharedCore` 各有一處 `HRZone.color`/`IntervalKind.bannerColor` 定義（無重複）。
