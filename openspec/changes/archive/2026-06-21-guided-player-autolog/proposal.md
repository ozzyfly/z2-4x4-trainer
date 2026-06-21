## Why

`GuidedPlayerView` 的「結束」按鈕只呼叫 engine 停止與畫面關閉，從不寫入任何 WorkoutLog。Today／Week／History 三個畫面都由 SwiftData 的 WorkoutLog 查詢驅動，因此使用者在「手機上」完成引導式 Zone 2 或 4×4 後，該次訓練不會出現在任何統計中，與「完成訓練即被記錄」的直覺期待不符。此缺口在 app-store-submission 任務 4.1 的 de-risk 過程中發現。

## What Changes

- 引導式播放器（Zone 2 與 Norwegian 4×4）在正常跑完規定時長後，寫入一筆 WorkoutLog：date 為完成時間、type 對應該 session 類型、durationMin 為實際完成時長、activeEnergyKcal 在可取得時填入（否則留空或 0）。
- 寫入後同步呼叫既有的 widget 快照更新，使 Today／Week／History 與小工具一致反映新記錄。
- WorkoutLog 來源以既有 sourceRaw 機制標記為 guided（與 manual／health／watch 並列），供 History 來源圖示與匯出辨識。
- 引導式 session 中途取消（未跑完規定時長即提早結束）不寫入記錄。

## Non-Goals (optional)

- 不修改 watch 端流程：watch 透過 HKWorkoutSession 已會記錄並同步，本變更僅針對手機端引導式播放器。
- 不新增 HealthKit 寫回：是否將引導式 session 寫入 Apple Health 屬於 health-writeback 能力範圍，不在本變更內。
- 不改動引導式播放器的計時、語音提示或 haptic 行為。

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `guided-player-audio`: 新增需求——引導式 session 正常完成後須記錄一筆 WorkoutLog 並標記來源；中途取消不記錄。

## Impact

- Affected specs: guided-player-audio (modified)
- Affected code:
  - Modified: App/Views/GuidedPlayerView.swift（完成時插入 WorkoutLog 並更新 widget 快照）
  - Modified: App/Persistence/WorkoutLog.swift（如來源列舉需新增 guided 值）
  - New: Tests/GuidedPlayerLoggingTests.swift（斷言完成寫入一筆、取消不寫入）
