## 1. SharedCore 強化（TDD，Mac 上 swift test）

- [x] 1.1 `FitnessTrend`：先在 SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift 加空集合與單一樣本測試（期望：回傳無趨勢、不 crash），再以 guard let 改寫 SharedCore/Sources/SharedCore/FitnessTrend.swift 的 sorted.first! / sorted.last!。完成條件：swift test 全綠（驗證需求：Trend math is total）。

## 2. Health 寫回

- [x] 2.1 `App/Health/HealthProviding.swift` 新增 saveWorkout(type:start:durationMin:energyKcal:) async throws -> String（回傳 HKWorkout UUID 字串）；requestAuthorization 的 share set 加入 workout type 與 activeEnergyBurned。`App/Health/PreviewHealthService.swift` 實作：回傳固定 UUID，提供 shouldFailSave 失敗注入屬性。完成條件：iOS 編譯通過（驗證需求：Manual entries save to Apple Health）。
- [x] 2.2 `App/Health/HealthKitService.swift` 以 HKWorkoutBuilder 實作 saveWorkout：beginCollection(at:) → 有 energyKcal 時加入 activeEnergyBurned 的 HKQuantitySample → endCollection → finishWorkout，回傳 workout.uuid.uuidString。完成條件：iOS 編譯通過；模擬器授權後手動紀錄出現在 Health App（驗證需求：Manual entries save to Apple Health）。
- [x] 2.3 `App/Views/ManualEntryView.swift` save()：本地 insert 後若已授權則 await saveWorkout；成功把 UUID 寫入 log.healthUUID；失敗（throw 或未授權）保留本地紀錄並以非阻斷文案提示（新字串走 String Catalog 鍵，回報 zh-Hant/es/ja 片段，不直接改 catalog）。完成條件：成功與失敗路徑皆不 crash（驗證需求：Manual entries save to Apple Health、Failures are visible）。
- [x] 2.4 新增 Tests/HealthWritebackTests.swift（與 Tests/PhoneSessionReceiverTests.swift 同 bundle）：以 spy HealthProviding 驗證 (a) 成功時 healthUUID 被寫回；(b) 失敗注入時本地 log 保留且 healthUUID 為 nil；(c) 寫回後模擬匯入同 UUID 不產生重複 log。完成條件：xcodebuild test 該三測試綠（驗證需求：Manual entries save to Apple Health）。
- [x] 2.5 規格化 Watch 既有寫入：確認 Watch/WorkoutSessionManager.swift 的 finishAndSave 經 HKLiveWorkoutBuilder.finishWorkout 寫入 Health，不改程式碼，僅在 PROGRESS.md 註記實機驗證待辦（驗證需求：Watch workouts persist to Health）。

## 3. 失敗可見化

- [x] 3.1 `App/Notifications/ReminderScheduler.swift`：排程 API 改為回報結果（async throws 或回傳狀態 enum），移除 fire-and-forget try?；授權狀態可查詢。完成條件：iOS 編譯通過（驗證需求：Failures are visible）。
- [x] 3.2 `App/Views/SettingsView.swift` 提醒區：通知權限為 denied 時顯示行內警告文字與「開啟設定」連結（UIApplication.openNotificationSettingsURLString），開關呈現停用狀態。新字串走 String Catalog 鍵並回報翻譯片段。完成條件：模擬器拒絕授權後 Settings 顯示警告（驗證需求：Failures are visible）。
- [x] 3.3 `App/GuidedSessionEngine.swift`：configureAudioSession 失敗時設 private(set) var audioUnavailable = true；`App/Views/GuidedPlayerView.swift` 據此顯示「語音提示無法使用」橫幅，計時照常進行。新字串走 String Catalog 鍵並回報翻譯片段。完成條件：iOS 編譯通過（驗證需求：Failures are visible）。

## 4. 驗證

- [x] 4.1 `cd SharedCore && swift test` 全綠；xcodebuild iOS scheme test（含 HealthWritebackTests 三測試）與 watch build 皆綠；模擬器 -mockHealth 啟動手動紀錄成功/失敗兩路徑各跑一次無 crash。
