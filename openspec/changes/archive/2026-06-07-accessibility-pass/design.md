## Context

`design-system-a11y`（基礎變更）提供：狀態色 token（`Theme.success/.warning/.danger/.info`）、`AccessibleStepper`、Reduce Motion helper、`SectionHeader` 修正、`Spacing.xxs`。本變更讓各 iOS 畫面採用這些基礎，修掉 UX 稽核發現的具體無障礙缺陷。前置：`design-system-a11y` 須先 apply。

## Goals / Non-Goals

**Goals:**

- 所有色彩狀態同時帶非色彩訊號（glyph/正負號/文字）。
- Celebration 動畫尊重 Reduce Motion。
- Settings/Onboarding 改用 `AccessibleStepper`。
- History 圖表對 VoiceOver 可讀。
- 表單欄位有 accessibilityLabel。
- Dynamic Type 下不裁切；命中區 ≥44pt；鎖定徽章不靠 opacity。

**Non-Goals:**

- 不改畫面資料、流程、導覽。
- 不新增/重做 design-system 元件或 token。
- 不改可用性/onboarding 內容（屬 `usability-onboarding-polish`）。

## Decisions

- **採用優先於重造**：所有 stepper 一律換成基礎的 `AccessibleStepper`，不再就地手刻。
- **狀態色集中**：readiness/趨勢/區間改吃 `Theme` 狀態 token；色塊以 `accessibilityHidden(true)` 隱藏，狀態由文字/glyph 表達。
- **圖表可讀**：Swift Charts 以 `accessibilityLabel` + per-day `accessibilityValue` 摘要曝露；不改圖表視覺。
- **Dynamic Type**：WeekView 星期欄移除固定 `width`，改 `minimumScaleFactor(0.8)` + 自然排版；History 圖表高度以 `@ScaledMetric` 或字級比例縮放，設下限/上限避免過大或過小。
- **命中區**：以 `.frame(minHeight: 44)` + `.contentShape(Rectangle())` 擴大 TargetBar 勾與徽章格的可點區，不改視覺尺寸。

## Implementation Contract

**Behavior（可觀察）：**

- Reduce Motion 開啟 → Achievements 解鎖時 Celebration 直接到最終態、無 confetti/動畫；關閉 → 照舊播。
- VoiceOver 聚焦 Settings/Onboarding 任一 stepper → 念「<label>, <value>」並有加/減動作。
- readiness、History 趨勢、HR zone chip → 除色彩外有 glyph/正負號/文字；趨勢 +2.1 顯示「▲ +2.1」、-1.4 顯示「▼ −1.4」。
- VoiceOver 在有資料的週訓練分鐘圖表上 → 念逐日數值摘要（非靜默）。
- VoiceOver 聚焦體重/身高/能量欄位 → 念描述性 label（如「Weight in kilograms」）。
- 大 Dynamic Type 下 WeekView 星期列與 History 圖表不裁切/不重疊。
- TargetBar 完成勾、徽章格命中區 ≥44×44pt。
- Achievements 鎖定態以鎖頭 glyph（對比達標）表達，不靠 opacity。

**Interface / 形狀：**

- 不新增公開 API；僅在既有 View 套用基礎元件與無障礙 modifier。
- 受影響 View：`Celebration`、`TodayView`、`HistoryView`、`SettingsView`、`OnboardingView`、`ManualEntryView`、`WeekView`、`AchievementsView`，以及 `Components.swift` 中相關元件（如 `TargetBar`）。

**Failure modes：**

- 圖表無資料 → 既有 empty state 不變，無障礙摘要不套用於空狀態。
- token 取用失敗（缺基礎）→ 編譯期錯誤，提示先 apply `design-system-a11y`。

**Acceptance criteria：**

- `xcodebuild` 編譯 iOS target 成功；`SharedCore` 測試仍綠。
- 以 Accessibility Inspector 或模擬器逐項驗證上述 Behavior（Reduce Motion、stepper 念法、趨勢符號、圖表可讀、欄位 label）。
- 開啟 Dynamic Type XL + Larger Accessibility Fonts，WeekView 與 History 不裁切。
- 命中區以 Accessibility Inspector 量測 ≥44pt。

**Scope boundaries：**

- In scope：上列 `App/Views/*` 與 `Components.swift` 的無障礙/呈現修改。
- Out of scope：資料/流程/導覽改動；design-system 元件新增；可用性與 onboarding 內容（另案）。

## Risks / Trade-offs

- **與 `usability-onboarding-polish` 共改 Settings/Onboarding**：兩案都碰這兩檔——須順序 apply（本案先，或反之），避免衝突；同檔不同區段時可平行，否則序列化。
- **圖表 VoiceOver 摘要為近似**：逐日摘要字串為可讀近似，非互動式資料瀏覽；對本階段足夠。
