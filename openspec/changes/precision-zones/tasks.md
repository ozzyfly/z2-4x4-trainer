# Tasks — precision-zones

## 1. 領域 (Requirement: Selectable zone method)

- [ ] 1.1 `SharedCore`：`UserProfile` 加入 `zoneMethod: ZoneMethod`（.ageMax/.karvonen/.custom）與 `customZones: [HRRange]?`；`HRZoneCalculator` 依方法計算（Karvonen 用 reserve，custom 用使用者帶）。Requirement: Selectable zone method。
  行為：同一 maxHR 下三種方法給不同帶。驗證：Swift Testing 對應 spec 三場景（Karvonen reserve、age-max 不變、custom）。
- [ ] 1.2 缺 resting HR 時 Karvonen 退回 age-max。Requirement: Karvonen needs resting HR。
  行為：resting 為 nil 時用 age-max。驗證：單元測試 nil resting → age-max 值。

## 2. UI (Requirement: Selectable zone method)

- [ ] 2.1 `SettingsView` 加入 zone-method picker 與（custom 時）band 編輯；`ProfileRecord` 新增 `zoneMethodRaw`/`customZones`，`.domain` 帶入。
  行為：切換方法後 Today/Detail 的帶即時改變。驗證：sim 切換 Karvonen/custom 截圖確認帶變化。
