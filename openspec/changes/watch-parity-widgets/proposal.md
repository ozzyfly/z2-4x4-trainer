## Why

Watch 端（Phase 4 範圍的延伸）目前完全看不到手機端已計算的洞察：readiness 分數、週連續（streak）、本週進度都只在 iPhone 上；Watch App 還用寫死的預設 profile 計算區間。Widget 與錶面複雜功能也各只有 1 種（TodayWidget、NextSessionComplication），無法呈現 readiness 或 streak。

## What Changes

- `WidgetSnapshot`（SharedCore）擴充為 v2：新增可選欄位 `readinessValue: Int?`、`readinessLabel`、`streakWeeks: Int?`，舊 JSON 仍可解碼（向後相容）；`ReadinessLabel` 改為 raw-value `Codable`
- 手機端 `WidgetSnapshotWriter` 簽名改為 update(context:readiness:)（readiness 預設 nil），以 `StreakCalculator` 算 streak，並在每次快照寫入後由新的 `PhoneStatusPublisher` 透過 WCSession `updateApplicationContext` 推送到 Watch
- Watch 端 `WatchWorkoutSender`（現有唯一 WCSession delegate）新增 `didReceiveApplicationContext` 接收：解碼快照 → 以 SharedCore `WidgetSnapshotStore` 寫入 Watch 端 App Group → reload 錶面 timeline；啟動時讀 `receivedApplicationContext`
- Watch `WorkoutListView` 新增狀態區塊：readiness、streak 週數、本週分鐘進度環；尚未同步時顯示 placeholder
- iOS Widgets 新增 2 種：`StreakWidget`、`ReadinessWidget`（共用既有 Provider）
- 錶面複雜功能新增 `ReadinessComplication`、`StreakComplication`；`NextSessionComplication` 優先讀快照、無快照時退回現行計算
- project.yml：為 Z24x4TrainerWatch 與 Z24x4WatchComplications 兩個 target 加上 App Group entitlement（group.ca.logolo.z24x4），再 xcodegen generate
- 延伸（stretch）：applicationContext payload 夾帶 profile 基本資料（年齡、maxHR override、zone method），取代 Watch 寫死的 defaultProfile

## Non-Goals

- 不在 Watch 端重算 readiness/streak（完整資料只在手機端：手動紀錄 + Health 匯入 + Watch 工作階段）；採手機計算、applicationContext 推送
- 不新增第二個 WCSession delegate（每個 process 只允許一個）；只擴充既有 delegate
- 不改動既有 TodayWidget 與快照既有欄位語意；v2 新欄位一律 optional
- 不做歷史資料同步或離線佇列；applicationContext 為 latest-state 語意，新值覆蓋舊值即符合需求

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `widgets-complication`: 快照 v2（readiness/streak 欄位、向後相容解碼）、新 widget 種類、Watch 端 App Group 快取與 applicationContext 推送
- `watch-workout-ui`: Watch 清單頁新增狀態區塊（readiness/streak/週進度），以及同步 profile 取代寫死預設值

## Impact

- Affected specs: `widgets-complication`（modified）、`watch-workout-ui`（modified）
- Affected code:
  - New: App/Sync/PhoneStatusPublisher.swift
  - Modified: SharedCore/Sources/SharedCore/WidgetSnapshot.swift, SharedCore/Sources/SharedCore/Readiness.swift, SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift, App/WidgetSnapshotWriter.swift, App/Sync/PhoneSessionReceiver.swift, App/Z24x4TrainerApp.swift, App/Views/ManualEntryView.swift, Watch/WorkoutSync.swift, Watch/WorkoutListView.swift, Widgets/Z24x4Widgets.swift, WatchComplications/Z24x4WatchComplications.swift, project.yml
  - Removed: (none)

註：applicationContext 實際送達與錶面複雜功能更新時機，只能在實體 Apple Watch 上完整驗證；模擬器只能驗證建置、UI placeholder 與快照解碼。
