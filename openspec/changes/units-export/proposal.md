## Why

App（Phase 2 iOS 範圍的補強）目前只有公制（kg、cm），美國等英制地區使用者無法以慣用單位輸入體重身高；訓練歷史也沒有任何匯出方式，資料被鎖在裝置裡，與「資料屬於使用者」的本地化定位不符。

## What Changes

- SharedCore 新增 `UnitPreference`（metric/imperial 的 String raw-value enum，含依 Locale.measurementSystem 推預設值的 defaultValue(for:)）與 `UnitConvert` 純函式（kgToLb/lbToKg、cmToFeetInches/feetInchesToCm），TDD 含 round-trip 容差測試；儲存層一律維持公制不變（ProfileRecord.weightKg/heightCm、所有計算器不動）
- SharedCore 新增 `WorkoutExport` 純函式：輸入輕量列（date、type、durationMin、energyKcal、note、source）→ csv()（含表頭、RFC-4180 引號跳脫、ISO8601 日期）與 json() -> Data，TDD 含逗號/引號/換行跳脫與空清單案例
- `ProfileRecord` 新增 unitsRaw: String 欄位（預設 metric，SwiftData 遷移安全）＋ computed units；onboarding 依 Locale.current 初始化
- `OnboardingView`：英制時體重欄為 lb、身高欄為 ft+in 兩欄；`SettingsView`：新增單位 picker，體重欄與每週減重速率（kg/week ↔ lb/week）跟著切換；`HistoryView`：體重圖表軸與數列依單位換算顯示
- `HistoryView` 工具列新增匯出 Menu：兩個 ShareLink（CSV 與 JSON），以 Transferable 包 WorkoutLog 查詢結果

## Non-Goals

- 不改任何儲存格式或既有紀錄（顯示層換算而已）
- 不做匯入（僅匯出）
- 不改 HR/能量單位（bpm、kcal 全球通用）；身高體重以外的距離/速度單位不在範圍
- ShareCard 不顯示體重（已確認），不需改

## Capabilities

### New Capabilities

- `units-export`: 公英制單位偏好（顯示層換算、儲存維持公制）與訓練歷史 CSV/JSON 匯出

### Modified Capabilities

(none)

## Impact

- Affected specs: `units-export`（new）
- Affected code:
  - New: SharedCore/Sources/SharedCore/UnitPreference.swift, SharedCore/Sources/SharedCore/UnitConvert.swift, SharedCore/Sources/SharedCore/WorkoutExport.swift, SharedCore/Tests/SharedCoreTests/UnitsExportTests.swift
  - Modified: App/Persistence/ProfileRecord.swift, App/Views/OnboardingView.swift, App/Views/SettingsView.swift, App/Views/HistoryView.swift
  - Removed: (none)
