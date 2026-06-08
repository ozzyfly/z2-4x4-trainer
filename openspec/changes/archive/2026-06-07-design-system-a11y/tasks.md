## 1. 色彩 token

- [x] 1.1 滿足需求「Accessible semantic color tokens」：在 `App/DesignSystem/Theme.swift` 新增語意狀態色 `success`/`warning`/`danger`/`info` 與各自配對前景色（`onSuccess` 等），以 adaptive（淺/深）方式定義；以對比工具量測每個「前景色 vs 配對面」於淺與深皆 ≥4.5:1，將量測值記於 PR 描述。
- [x] 1.2 滿足需求「Color is never the only signal」：token API 不綁定色彩唯一訊號——`success`/`warning`/`danger`/`info` 僅提供色彩，採用端可搭配 glyph/正負號/文字；在 `Theme` 註解標明此約定（實際符號落實於後續畫面變更）。
- [x] 1.3 在 `Theme.swift`（或 `Spacing` 所在處）新增 `Spacing.xxs = 2`。

## 2. 元件

- [x] 2.1 滿足需求「Secondary button component」：新增 `App/DesignSystem/Buttons.swift`：實作 `SecondaryButton`（與 `PrimaryButton` 同尺寸/命中區 ≥44pt 的 tinted/bordered 次要樣式），沿用按壓 `scaleEffect` 動效並於觸發時發 `.sensoryFeedback(.selection)`；附 `#Preview` 與 `PrimaryButton` 並列。
- [x] 2.2 滿足需求「Accessible stepper component」：新增 `App/DesignSystem/AccessibleControls.swift`：實作 `AccessibleStepper`（label、value 字串、range、step、onChange），外層合併為單一 accessibility element，設定 `accessibilityLabel`/`accessibilityValue`/`accessibilityHint`，命中區 ≥44pt；附 `#Preview` 並以 Accessibility Inspector/preview 確認 VoiceOver 念「<label>, <value>」。
- [x] 2.3 滿足需求「Reduce Motion respected by motion helper」：新增 `App/DesignSystem/Motion.swift`：實作讀 `@Environment(\.accessibilityReduceMotion)` 的 motion helper（`withMotion` 函式或 `motionAware` modifier）——開啟時無動畫即時套用狀態、關閉時正常動畫；附說明用 `#Preview` 或註解範例。

## 3. 既有元件修正

- [x] 3.1 在 `App/DesignSystem/Components.swift` 將 `SectionHeader` 的 `.uppercased()` 字串改為 `.textCase(.uppercase)` modifier；以 preview/Accessibility Inspector 確認含 "VO2max" 的標題 VoiceOver 念法自然。

## 4. 驗證

- [x] 4.1 以 `xcodebuild` 編譯 iOS target 成功；確認未修改任何 `App/Views/*`、`Watch/*`、`SharedCore/*`，且 `SharedCore` 測試仍綠；於淺/深色 + Dynamic Type XL 檢視所有新 `#Preview` 不裁切、不重疊。
