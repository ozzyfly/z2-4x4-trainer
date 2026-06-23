## Problem

匯入 Apple Health 訓練後，Home／Lock 小工具與 Apple Watch complication 仍顯示過時的本週統計（分鐘數、hard sessions、streak），直到其他變更路徑（手動輸入、手錶同步、引導式記錄）再次觸發刷新為止。從使用者角度看，剛匯入的訓練在小工具上「消失」。

## Root Cause

`App/Health/HealthStore.swift` 的 importWorkouts 在插入 WorkoutLog 後沒有呼叫 WidgetSnapshotWriter.update；而其他三個插入路徑（ManualEntryView、PhoneSessionReceiver、GuidedSessionLogger）插入後都有刷新快照。匯入路徑遺漏這一步。

## Proposed Solution

在 importWorkouts 至少新增一筆 WorkoutLog 後，呼叫 WidgetSnapshotWriter.update(context:) 刷新 App Group 快照並要求小工具重載。若本次匯入沒有任何新增（全部為重複或來源為空），則不刷新，避免無謂寫入與時間軸重載。

## Non-Goals (optional)

- 匯入的訓練一律標記為 .zone2 是合理預設：HKWorkout 的活動類型無法分辨 Norwegian 4×4，故不在本次修正範圍。
- 不改動 HealthKit 查詢回呼的錯誤處理（屬於另一個 sync robustness 範疇）。
- 不改動 WidgetSnapshotWriter.update 本身的快照計算邏輯。

## Success Criteria

- 匯入含新訓練後，WidgetSnapshotStore 中的快照本週 done 分鐘數包含該筆匯入訓練，且小工具時間軸被要求重載。
- 匯入沒有新增（全部重複）時不再次刷新快照。
- 以單元測試覆蓋上述兩種情形。

## Impact

- Affected code:
  - Modified: App/Health/HealthStore.swift
  - New: Tests/HealthImportSnapshotTests.swift
