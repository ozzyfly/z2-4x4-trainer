# Tasks — smart-reminders

## 1. 排程 (Requirement: Opt-in training reminders; Permission respected)

- [ ] 1.1 `App/Notifications/ReminderScheduler.swift`：請求授權；依 `TrainingPlan` 非休息日於指定時間排程 local notification；關閉時清除全部。Requirement: Opt-in training reminders; Permission respected。
  行為：開啟→排程各訓練日；關閉→清除；拒絕授權→不排程。驗證：sim 開關後 `getPendingNotificationRequests` 數量變化（log 或手動）。

## 2. UI (Requirement: Opt-in training reminders)

- [ ] 2.1 `SettingsView` 加「Reminders」區：開關 + 時間選擇；綁定 `ReminderScheduler`。
  行為：切換開關即排程/清除。驗證：Settings 截圖；開啟後出現權限請求。
