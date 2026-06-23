## Problem

幾個面向使用者的「每週」單位標籤是寫死的英文，未經 String Catalog，因此在 es／ja／zh-Hant 語系下不會翻譯：減重速率顯示 "0.50 kg/week"／"lb/week"（Settings 與 Onboarding），以及 Week 畫面的 "%lld/week"（hard sessions）與 "%lld kcal/week"（運動能量）。西語使用者會看到 "0.50 kg/week" 而非 "0,50 kg/semana"。

## Root Cause

這些字串以 String(format:) 或字串插值組成，未透過 String(localized:)／catalog，數字也未以 locale 格式化（小數點分隔符）。

## Proposed Solution

將四處使用者可見的字串改為 String(localized:) 形式，鍵交由 String Catalog 擷取，並補上 es／ja／zh-Hant 翻譯；速率數字以 locale-aware 格式化（`.formatted(.number.precision(.fractionLength(2)))`）。預覽（#Preview Demo）中的字串不在範圍內。

## Non-Goals (optional)

- 不改動數值計算或單位換算邏輯（kg↔lb 換算照舊）。
- 不處理 #Preview Demo 內的展示字串（非使用者可見）。

## Success Criteria

- Settings、Onboarding 的速率標籤與 Week 畫面的 hard-sessions、energy 標籤在 es／ja／zh-Hant 下顯示翻譯後的單位（如 "kg/semana"、"kcal/週"）。
- App String Catalog 新增對應鍵，且三語皆為 translated（0 needs_review）。
- iOS build 綠燈、既有測試不回歸。

## Impact

- Affected code:
  - Modified: App/Views/SettingsView.swift
  - Modified: App/Views/OnboardingView.swift
  - Modified: App/Views/WeekView.swift
  - Modified: App/Localizable.xcstrings
