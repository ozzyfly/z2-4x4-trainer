## Summary

擴充共用設計系統（`App/DesignSystem/`），補上無障礙與互動所需的基礎元件與色彩 token，供後續 accessibility 與 usability 變更採用。

## Motivation

`ui-ux-refresh` 已建立卡片式設計系統，但 UX 稽核（4 個 agent，橫跨全部畫面）發現一批跨畫面、重複出現的基礎缺口，無法在單一畫面內就地修補：

- 狀態色（readiness、History 趨勢、HR 區間）直接用 `.green/.orange/.red`，未保證 ≥4.5:1 對比，且色盲使用者無替代符號。
- Stepper 在 Settings 與 Onboarding 各自手刻，label/value 混在一句、無 hint、命中區可能 <44pt。
- 只有 `PrimaryButton`，次要動作用 `.card()` + NavigationLink 拼湊，視覺與互動階層不清。
- 慶祝動畫未檢查 Reduce Motion。
- `SectionHeader` 用 `.uppercased()` 字串而非 `.textCase`，破壞 VoiceOver 發音。

先把這些做成可重用的基礎，screens 才能一致採用、避免每個畫面各自重造。本變更只動「呈現基礎元件」，不改任何畫面的資料或流程。

## Proposed Solution

在 `App/DesignSystem/` 內新增 / 擴充：

1. **無障礙語意色 token**（`Theme`）：`success`、`warning`、`danger`、`info`，於淺色與深色皆保證對前景 ≥4.5:1 對比；提供搭配用的前景/背景組合。
2. **`SecondaryButton`** 元件：與 `PrimaryButton` 同尺寸的次要樣式（bordered/tinted），含按壓動效與 `.sensoryFeedback`。
3. **`AccessibleStepper`** 包裝元件：合併 label/value、加 hint、命中區 ≥44pt，VoiceOver 念為「<label>，<value>」。
4. **Reduce Motion helper**：讀 `@Environment(\.accessibilityReduceMotion)` 的 view modifier / 包裝函式，動畫在開啟時降級為即時狀態切換。
5. **`SectionHeader` 修正**：`.uppercased()` → `.textCase(.uppercase)`，保留語意大小寫。
6. **補 spacing token**：新增 `Spacing.xxs`（給目前散落的 `spacing: 2` 字面值）。

每個新元件附 SwiftUI preview，於淺/深色與 Dynamic Type XL 下檢視。

## Non-Goals

- 不修改任何畫面（Today/Week/History/Settings/Onboarding 等）的行為、資料或導覽——畫面採用留給後續的 `accessibility-pass` 與 `usability-onboarding-polish` 變更。
- 不改 `SharedCore/`、persistence、HealthKit 邏輯。
- 不新增畫面或功能。
- 不重做既有 `Card`/`TargetBar`/`ZoneChip` 的視覺風格（僅在需要時讓它們吃新的 token）。

## Alternatives Considered

- **直接在各畫面就地修**：被否決——狀態色、Stepper、次要按鈕在多畫面重複，就地修會產生分歧實作與重複程式碼。
- **一次大改（基礎 + 全畫面）**：被否決——難以平行化、難 review；先抽基礎再讓畫面採用較乾淨。

## Impact

- Affected specs: `design-system`（MODIFIED：擴充無障礙與元件需求）
- Affected code:
  - Modified:
    - App/DesignSystem/Theme.swift
    - App/DesignSystem/Components.swift
  - New:
    - App/DesignSystem/Buttons.swift
    - App/DesignSystem/AccessibleControls.swift
    - App/DesignSystem/Motion.swift
  - Removed: (none)
