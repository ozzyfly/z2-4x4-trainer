## Context

`ui-ux-refresh` 已交付 `App/DesignSystem/`（`Theme.swift`、`Components.swift`、`ZoneStyle.swift`），全部 iOS 畫面採卡片式風格。UX 稽核發現跨畫面、重複的無障礙與互動基礎缺口，需先抽成可重用元件，後續兩個變更（`accessibility-pass`、`usability-onboarding-polish`）再採用。本變更只動設計系統層，畫面不改。

## Goals / Non-Goals

**Goals:**

- 提供保證對比的語意狀態色 token（success/warning/danger/info），淺/深色皆 ≥4.5:1。
- 提供 `SecondaryButton`、`AccessibleStepper` 兩個可重用元件，命中區 ≥44pt、VoiceOver 正確。
- 提供 Reduce Motion helper，讓動畫在系統開啟降級時即時切換狀態。
- 修正 `SectionHeader` 大寫做法；補 `Spacing.xxs`。
- 每個新元件附 preview，於淺/深色與 Dynamic Type XL 下可檢視。

**Non-Goals:**

- 不修改任何畫面檔（`App/Views/*`）。
- 不改 `SharedCore/`、HealthKit、persistence。
- 不重做既有 `Card`/`TargetBar`/`ZoneChip` 視覺。

## Decisions

- **色彩定義方式**：用 asset catalog 的 adaptive color set 或 `Color(light:dark:)` 風格定義，確保系統自動切換。token 以 `Theme.success` 等靜態屬性曝露，並提供 `onSuccess` 等配對前景色。對比以實際選色達成（非執行期計算），於 PR 描述附對比量測值。
- **非色彩訊號**：token 不自帶 glyph；由採用端搭配符號/正負號/文字。spec「Color is never the only signal」的落實在後續畫面變更，本變更僅保證 token 與元件 API 容許傳入符號。
- **`SecondaryButton`**：實作為 `ButtonStyle`（與 `PrimaryButton` 對稱），tinted/bordered 樣式，沿用既有按壓 `scaleEffect` 動效並掛 `.sensoryFeedback(.selection)`。
- **`AccessibleStepper`**：包裝 SwiftUI `Stepper`，外層 `.accessibilityElement(children: .ignore)` + `.accessibilityLabel` + `.accessibilityValue` + `.accessibilityHint`，命中區用 `.frame(minHeight: 44)`/`.contentShape`。值的格式化由呼叫端以 closure 提供。
- **Motion helper**：提供 `withMotion(_:_:)` 函式或 `View.motionAware(...)` modifier，讀 `@Environment(\.accessibilityReduceMotion)`；開啟時以無 animation 套用狀態變更。
- **`SectionHeader`**：移除 `.uppercased()` 字串呼叫，改 `.textCase(.uppercase)`。
- **Spacing**：`Spacing` 加 `xxs = 2`。

## Implementation Contract

**Behavior（採用端可觀察）：**

- `Theme.success/.warning/.danger/.info` 及配對前景色可用；於淺/深色 render 文字於配對面上對比 ≥4.5:1。
- `SecondaryButton(title:action:)` 渲染為次要樣式、命中區 ≥44×44pt、按壓有動效、觸發時發 haptic。
- `AccessibleStepper`（label、value 字串、範圍、step、onChange）渲染標準 stepper，VoiceOver 念「<label>, <value>」並提供加/減動作，命中區 ≥44pt。
- 透過 motion helper 套用的狀態變更：Reduce Motion 開→無動畫即時到位；關→正常動畫。
- `SectionHeader` 全大寫由 `.textCase` 達成；VoiceOver 對 "VO2max" 念法自然。

**Interface / 形狀：**

- `Theme`：新增 static `success`、`warning`、`danger`、`info`，以及對應 `onSuccess` 等前景色（命名於實作時確定，須在 design-system 內一致）。
- `Spacing`：新增 `static let xxs: CGFloat = 2`。
- 新檔 `App/DesignSystem/Buttons.swift`：`SecondaryButton` view 或 `SecondaryButtonStyle: ButtonStyle`。
- 新檔 `App/DesignSystem/AccessibleControls.swift`：`AccessibleStepper` view。
- 新檔 `App/DesignSystem/Motion.swift`：motion helper 函式/modifier。

**Failure modes：**

- 缺色彩 asset → 編譯期或預覽即可見錯誤，不可靜默回退到無對比保證的系統色。
- `AccessibleStepper` 值超出範圍 → 沿用 SwiftUI `Stepper` 的 clamp 行為，不另拋錯。

**Acceptance criteria：**

- `xcodebuild` 編譯 iOS target 成功。
- 每個新元件有 SwiftUI `#Preview`，於淺/深色 + Dynamic Type XL 下不裁切、不重疊。
- 以 Accessibility Inspector 或 preview 確認 `AccessibleStepper` 念「label, value」、`SectionHeader` 念法自然。
- 對比值（每個 token 文字 vs 配對面，淺+深）以對比工具量測 ≥4.5:1，記於 PR。
- 既有畫面未改、`SharedCore` 測試仍綠。

**Scope boundaries：**

- In scope：`App/DesignSystem/` 內新增/修改檔；`Spacing` token。
- Out of scope：任何 `App/Views/*`、`Watch/*`、`SharedCore/*` 修改；畫面採用新元件（屬後續變更）。

## Risks / Trade-offs

- **對比靠人工選色**：無執行期驗證，靠 PR 量測把關；風險是日後改色破壞保證——以 spec scenario + PR 量測流程緩解。
- **元件未被採用前無回歸覆蓋**：本變更只加元件、不接畫面，故行為價值要等後續變更才顯現；可接受，換取乾淨的平行化。
