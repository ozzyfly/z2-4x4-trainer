## 1. WorkoutLog 來源標記

- [x] 1.1 確認 WorkoutLog 的來源列舉（sourceRaw 機制）含 guided 值；若缺則新增。行為：可建立 source 為 guided 的 WorkoutLog，History 來源圖示與 CSV/JSON 匯出皆能辨識 guided。驗證：在 Tests 新增單元測試建立 source=guided 的 WorkoutLog 並斷言 sourceRaw 往返一致；匯出測試輸出的 source 欄位為 guided。

## 2. 引導式播放器完成時寫入記錄（對應需求：Guided session completion records a workout）

- [x] 2.1 實作需求 Guided session completion records a workout：在 App/Views/GuidedPlayerView.swift 的「正常完成」（跑滿該 session 規定時長）路徑插入一筆 WorkoutLog：type 對應 session 類型、durationMin 為完成時長、date 為完成時間、activeEnergyKcal 在可得時填入、source 標記 guided，並呼叫 WidgetSnapshotWriter 更新 App Group 快照。行為：在手機上完成引導式 4×4 或 Zone 2 後，Today／Week／History 各多一筆對應記錄，且無需另行手動輸入。驗證：在 Tests/GuidedPlayerLoggingTests.swift 以 in-memory SwiftData 模擬完成事件，斷言 WorkoutLog 數量 +1、欄位與 session 相符、且快照更新被觸發。
- [x] 2.2 引導式 session 在跑滿規定時長前被結束（取消）時不插入 WorkoutLog。行為：提早結束引導式 session 後 Today／Week／History 統計不變。驗證：在同一測試檔斷言取消路徑下 WorkoutLog 數量維持不變（新增 0 筆）。

## 3. 驗證與回歸

- [x] 3.1 確認領域與 iOS 測試全綠且無回歸。行為：新增測試通過，既有測試不受影響。驗證：cd SharedCore && swift test 全綠；xcodebuild -project Z24x4Trainer.xcodeproj -scheme Z24x4Trainer -destination 'platform=iOS Simulator,name=iPhone 17' build test 輸出 BUILD SUCCEEDED 與 TEST SUCCEEDED。
- [x] 3.2 模擬器 smoke 驗證完成記錄端到端可見。行為：以 -mockHealth 啟動 App，完成一次引導式 session 後 History 出現該筆記錄。驗證：模擬器操作觀察並截圖，結果記於 PROGRESS.md（註明 sim-only；實機端到端仍由 app-store-submission 任務 4.1 涵蓋）。
