## Why

手機端（Phase 3 HealthKit 範圍的補強）手動輸入的訓練從未寫回 Apple Health，使用者的 Health 紀錄不完整；多處失敗是無聲的（提醒排程 try?、語音 audio session try?），使用者完全不知道功能沒生效；SharedCore `FitnessTrend` 還有兩處 force-unwrap。Watch 端訓練已由 `HKLiveWorkoutBuilder.finishWorkout` 自動存入 Health，不在本變更範圍。

## What Changes

- `HealthProviding` 協議新增 saveWorkout(type:start:durationMin:energyKcal:) async throws，回傳 HKWorkout UUID 字串；requestAuthorization 一併要求 share 權限（workout type、active energy）。`HealthKitService` 以 `HKWorkoutBuilder` 實作（iOS 17+ 路徑：beginCollection → 加 activeEnergy sample → finishWorkout）；`PreviewHealthService` 回傳固定 UUID 並提供失敗注入開關
- `ManualEntryView.save()`：本地插入後嘗試寫入 Health；成功時把回傳 UUID 寫到 `WorkoutLog.healthUUID`（與 `HealthStore.importWorkouts` 既有 UUID 去重路徑自動相容，避免下次匯入重複）；失敗時保留本地紀錄並顯示非阻斷提示
- `ReminderScheduler`：排程改為可回報結果（不再 fire-and-forget try?）；Settings 提醒區在通知權限被拒時顯示行內警告與「開啟設定」連結，不再呈現無效的開關
- `GuidedSessionEngine`：audio session 設定失敗時設 audioUnavailable 旗標；`GuidedPlayerView` 顯示「語音提示無法使用」橫幅
- SharedCore `FitnessTrend`：以 guard let 取代 sorted.first! / sorted.last!，加入空集合與單一樣本的邊界測試
- 新增 Tests/HealthWritebackTests.swift（模擬器 test bundle，仿 PhoneSessionReceiverTests）：以 spy HealthProviding 驗證 UUID 寫回與匯入去重 round-trip

## Non-Goals

- 不改 Watch 端寫入路徑（已存在且正確）
- 不做 Health 端刪除/編輯同步（本地刪除不回刪 Health）
- 不把既有歷史手動紀錄回填到 Health（僅新紀錄寫回）
- 不引入第三方錯誤回報；失敗提示一律 App 內呈現

## Capabilities

### New Capabilities

- `health-writeback`: 手動紀錄寫回 Apple Health 並以 UUID 去重；涵蓋既有 Watch 自動寫入行為的規格化

### Modified Capabilities

- `usability`: 失敗狀態可見化 — 提醒權限被拒、語音不可用、Health 寫入失敗都有使用者可見的回饋

## Impact

- Affected specs: `health-writeback`（new）、`usability`（modified）
- Affected code:
  - New: Tests/HealthWritebackTests.swift
  - Modified: App/Health/HealthProviding.swift, App/Health/HealthKitService.swift, App/Health/PreviewHealthService.swift, App/Views/ManualEntryView.swift, App/Notifications/ReminderScheduler.swift, App/Views/SettingsView.swift, App/GuidedSessionEngine.swift, App/Views/GuidedPlayerView.swift, SharedCore/Sources/SharedCore/FitnessTrend.swift, SharedCore/Tests/SharedCoreTests/SmartCoachTests.swift
  - Removed: (none)

註：實際 Health 寫入需在模擬器授權對話框授權後驗證；實機驗證列入 TestFlight 清單。
