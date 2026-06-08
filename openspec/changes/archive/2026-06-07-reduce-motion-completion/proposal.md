## Summary

讓 round-2 之後仍忽略系統 Reduce Motion 的動畫一律改用既有 motion helper，補齊無障礙一致性。

## Motivation

Round-2（`design-system-a11y`）已新增 motion helper（`App/DesignSystem/Motion.swift` 的 `withMotion`、`View.motionAware`），並讓 Celebration confetti 尊重 Reduce Motion。但稽核發現仍有數個動畫未檢查 Reduce Motion，違反 WCAG 與 Apple 指南（前庭敏感使用者）：

- `App/DesignSystem/Components.swift` 的 `TargetBar`：`onAppear`/`onChange` 的 `withAnimation(.spring…)`。
- `App/DesignSystem/Buttons.swift` 的 `PrimaryButton`、`SecondaryButton`：按壓 `.animation(.easeOut…)`。
- `App/Views/SettingsView.swift`、`App/Views/OnboardingView.swift`：減重目標 toggle 的 `.animation`/條件欄位 `.transition`。
- `App/Views/Celebration.swift` 的 `ConfettiBurst` 內部 `withAnimation(.easeOut(duration:1.3))`：雖然 Reduce Motion 開啟時整個 burst 不會 render（外層已 gate），但內部動畫未防護，屬殘留風險。

helper 已存在，採用成本低、風險小，純 iOS。

## Proposed Solution

於各處注入 `@Environment(\.accessibilityReduceMotion)` 並改用既有 helper：

- `TargetBar`：兩處 `withAnimation` 改 `withMotion(...)`，Reduce Motion 開啟時即時設定 `animatedFraction`、不動畫。
- `PrimaryButton`/`SecondaryButton`：按壓 `.animation(...)` 改為 Reduce Motion 開啟時不套用（以 `.motionAware` 或條件 animation）。
- `SettingsView`/`OnboardingView`：toggle 的 `.animation` 改 `.motionAware`；條件欄位 `.transition` 在 Reduce Motion 開啟時不套用。
- `ConfettiBurst`：傳入 `reduceMotion`，開啟時 `onAppear` 直接設最終狀態、不 `withAnimation`。

不新增 helper、不改動畫的視覺設計（僅在 Reduce Motion 開啟時降級）。

## Non-Goals

- 不新增/改 motion helper 本身（`Motion.swift` 不動）。
- 不改任何動畫在 Reduce Motion 關閉時的外觀。
- 不動 watch、SharedCore、domain。

## Alternatives Considered

- **全域停用動畫**：被否決——只該在使用者開啟 Reduce Motion 時降級，否則保留既有動效。
- **不處理 ConfettiBurst 內部**：被否決——外層 gate 雖足夠，但內部留未防護動畫是日後回歸風險，一併修。

## Impact

- Affected specs: `design-system`（MODIFIED：強化 Motion 需求——所有動畫尊重 Reduce Motion）
- Affected code:
  - Modified:
    - App/DesignSystem/Components.swift
    - App/DesignSystem/Buttons.swift
    - App/Views/SettingsView.swift
    - App/Views/OnboardingView.swift
    - App/Views/Celebration.swift
  - New: (none)
  - Removed: (none)
