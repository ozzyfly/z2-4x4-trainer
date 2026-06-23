## 1. 匯入後刷新快照（對應需求：Snapshot refreshes after Apple Health import）

- [x] 1.1 實作需求 Snapshot refreshes after Apple Health import：讓 App/Health/HealthStore.swift 的 importWorkouts 回傳本次新增的 WorkoutLog 筆數，並僅在筆數大於 0 時呼叫 WidgetSnapshotWriter.update(context:)；全部為重複或無資料時不刷新。行為：匯入含新訓練後快照被刷新、全部重複時不重寫。驗證：新增 Tests/HealthImportSnapshotTests.swift，以 SpyHealthService（設定 importableWorkouts）配合 seeded ProfileRecord 的 in-memory context，斷言匯入新 healthUUID 時回傳 1 且 WorkoutLog 數量 +1；再次匯入相同 healthUUID 時回傳 0 且數量不變。
- [x] 1.2 確認既有 Health 匯入去重與寫回行為不回歸。行為：ManualEntry 寫回後再匯入同 UUID 仍不重複。驗證：既有 Tests/HealthWritebackTests.swift 全部案例維持綠燈。

## 2. 驗證與回歸

- [x] 2.1 確認領域與 iOS 測試全綠且無回歸。行為：新增測試通過，既有測試不受影響。驗證：cd SharedCore && swift test 全綠；xcodebuild -project Z24x4Trainer.xcodeproj -scheme Z24x4Trainer -destination 'platform=iOS Simulator,name=iPhone 17' build test 輸出 BUILD SUCCEEDED 與 TEST SUCCEEDED。
