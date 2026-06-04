# Tasks — watch-phone-sync

## 1. Watch 端傳送完成的訓練 (Requirement: Completed Watch workout syncs to the iPhone)

- [x] 1.1 在 `Watch/WorkoutSessionManager.swift` 以 `WCSession` 取代 `// TODO: WatchConnectivity` 標記：訓練結束時將 session（date、type、durationMin、activeEnergyKcal、healthUUID）編碼送出。
  行為：session 結束後 `WCSession.default` 觸發一次傳送（Requirement: Completed Watch workout syncs to the iPhone）。驗證：在 manager 加入單元測試，斷言結束流程呼叫了傳送（以 protocol 模擬 `WCSession`）。
- [x] 1.2 手機無法連線時改用 `transferUserInfo` 背景佇列，不遺失資料。
  行為：`isReachable == false` 時 session 進入背景傳送佇列。驗證：以模擬的不可達 session 測試走背景路徑。

## 2. iPhone 端接收並儲存

- [x] 2.1 新增 `App/Sync/PhoneSessionReceiver.swift`，實作 `WCSessionDelegate` 接收 session 並插入 SwiftData `WorkoutLog`。
  行為：收到 payload 後 store 多出一筆對應的 `WorkoutLog`。驗證：以樣本 payload 呼叫 receiver，斷言 `WorkoutLog` 數量 +1 且欄位相符。
- [x] 2.2 在 `App/Z24x4TrainerApp.swift` 啟用並 activate `WCSession`，注入共用的 `modelContext`。
  行為：App 啟動後 `WCSession` 為 activated 狀態。驗證：模擬器啟動 App，log 顯示 activationState == .activated，無 crash。

## 3. 去除重複 (Requirement: Synced workouts are not duplicated)

- [x] 3.1 接收時以 `healthUUID` 去重：已存在則略過。
  行為：相同 `healthUUID` 的 session 第二次送達不會新增記錄（Requirement: Synced workouts are not duplicated）。驗證：對應 spec 場景「Same session delivered twice」的單元測試，送兩次後 `WorkoutLog` 數量不變。

## 4. 編譯 watch target (Requirement: Watch target compiles and runs)

- [x] 4.1 安裝 watchOS SDK（`xcodebuild -downloadPlatform watchOS`）後編譯 `Z24x4TrainerWatch`。
  行為：watch target 成功建置（Requirement: Watch target compiles and runs）。驗證：`xcodebuild build -scheme Z24x4TrainerWatch -destination 'platform=watchOS Simulator,name=Apple Watch ...'` 輸出 `** BUILD SUCCEEDED **`。

## 5. 實機驗證（需 Apple Watch 硬體）

- [ ] 5.1 在實體 Apple Watch 上跑一次 Norwegian 4×4，確認即時心率、區間顏色、間歇切換 haptic。
  行為：執行中畫面顯示心率與區間，每段切換有震動。驗證：手動實機測試，記錄結果於 `PROGRESS.md`。
- [ ] 5.2 確認完成的訓練同步回 iPhone 並出現在 Today/Week/History，且不重複。
  行為：手錶完成的 session 出現在手機端統計。驗證：手動端到端測試，於兩裝置觀察單一記錄。
