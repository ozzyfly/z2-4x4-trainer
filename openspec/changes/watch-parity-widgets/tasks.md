## 1. SharedCore 快照 v2（TDD，Mac 上 swift test）

- [ ] 1.1 `ReadinessLabel` 改為 `String` raw-value 並採用 `Codable`（SharedCore/Sources/SharedCore/Readiness.swift）。完成條件：encode→decode round-trip 測試通過，且既有 Readiness 測試不變綠。
- [ ] 1.2 `WidgetSnapshot` 新增 optional 欄位 `readinessValue: Int?`、`readinessLabel: ReadinessLabel?`、`streakWeeks: Int?`（SharedCore/Sources/SharedCore/WidgetSnapshot.swift）。先寫測試：(a) 含新欄位 round-trip 相等；(b) 不含新欄位的舊版 JSON 字串可解碼且新欄位為 nil；(c) placeholder 快照新欄位為 nil。測試加在 SharedCore/Tests/SharedCoreTests/WidgetSnapshotTests.swift，`swift test` 全綠。（驗證需求：Shared widget snapshot）

## 2. 手機端：快照計算與推送

- [ ] 2.1 `WidgetSnapshotWriter.update` 簽名改為 `update(context:readiness:)`（readiness 參數型別為可選的 readiness 結果，預設 nil），內部以 `StreakCalculator` 由 WorkoutLog 計算 streakWeeks 並填入快照（App/WidgetSnapshotWriter.swift）。所有呼叫端（App/Z24x4TrainerApp.swift、App/Views/ManualEntryView.swift、App/Sync/PhoneSessionReceiver.swift、App/Views/RootView.swift 若有）改為傳入 HealthStore 目前的 readiness。完成條件：iOS target 編譯通過，logging 一筆手動紀錄後快照含 streak 值。（驗證需求：Shared widget snapshot）
- [ ] 2.2 新增 `App/Sync/PhoneStatusPublisher.swift`：提供 publish(snapshot:) — 將快照 JSON 包成 ["snapshot": Data] 後呼叫 WCSession `updateApplicationContext`；僅在 `activationState == .activated` 時送出，失敗不得讓 App crash（錯誤记录到 console 即可）。`WidgetSnapshotWriter` 每次寫入後呼叫它。完成條件：iOS 編譯通過；模擬器無配對 Watch 時 logging 也不 crash。（驗證需求：Phone publishes snapshot to watch）

## 3. Watch 端：接收與狀態 UI

- [ ] 3.1 `Watch/WorkoutSync.swift` 的 `WatchWorkoutSender`（既有唯一 delegate）實作 `session(_:didReceiveApplicationContext:)`：解出 "snapshot" Data → `WidgetSnapshot` 解碼 → `WidgetSnapshotStore.write` 寫入 Watch 端 App Group → `WidgetCenter.shared.reloadAllTimelines()`；activation 完成時讀 `receivedApplicationContext` 套用同一路徑。解碼失敗 SHALL 忽略該訊息不得 crash。完成條件：watch target 編譯通過。（驗證需求：Phone publishes snapshot to watch）
- [ ] 3.2 `Watch/WorkoutListView.swift` 上方新增狀態區塊：readiness 分數+標籤、streak 週數、本週分鐘進度（done/target）；資料來源為 Watch 端 `WidgetSnapshotStore.read()`；無快照時顯示 placeholder 文案且清單仍可用。新字串以 String Catalog 鍵撰寫並回報 zh-Hant/es/ja 片段（不直接改 catalog 檔）。完成條件：watch 編譯通過，watch 模擬器顯示 placeholder。（驗證需求：Watch status section）
- [ ] 3.3（stretch）applicationContext payload 加入 profile 基本資料（age、maxHR override、zoneMethod raw value），Watch 端解碼後存入 App Group 並用於 `HRZoneCalculator`，無同步資料時退回 `defaultProfile`。完成條件：watch 編譯通過；單元層面以 SharedCore 既有型別測 profile 編解碼 round-trip。（驗證需求：Watch uses synced profile）

## 4. Widgets 與錶面複雜功能

- [ ] 4.1 project.yml：Z24x4TrainerWatch 與 Z24x4WatchComplications 加上 App Group entitlement（group.ca.logolo.z24x4），執行 xcodegen generate。完成條件：兩個 watch target 編譯通過且 entitlements 檔含該 App Group。
- [ ] 4.2 `Widgets/Z24x4Widgets.swift`：WidgetBundle 加入 `StreakWidget`（systemSmall、accessoryCircular、accessoryInline）與 `ReadinessWidget`（systemSmall、accessoryCircular、accessoryRectangular），共用既有 Provider；欄位為 nil 時顯示 placeholder。完成條件：iOS 編譯通過，widget gallery 顯示 3 種 widget。（驗證需求：Streak and readiness widgets）
- [ ] 4.3 `WatchComplications/Z24x4WatchComplications.swift`：加入 `ReadinessComplication` 與 `StreakComplication`（accessoryCircular、accessoryCorner、accessoryInline），改 `NextSessionComplication` 優先讀 `WidgetSnapshotStore.read()`、無快照時用現行 `TrainingPlan` 計算。完成條件：watch 編譯通過，複雜功能 gallery 顯示 3 種。（驗證需求：Watch complication shows next session）

## 5. 驗證

- [ ] 5.1 `cd SharedCore && swift test` 全綠；`xcodebuild` iOS 與 watch scheme 皆 BUILD SUCCEEDED；iPhone 模擬器以 -mockHealth -seedProfile 啟動後 logging 一筆紀錄不 crash；watch 模擬器清單頁顯示狀態區塊 placeholder。實體 Apple Watch 的 applicationContext 送達與錶面更新時機列為硬體待驗證項，記入 PROGRESS.md。
