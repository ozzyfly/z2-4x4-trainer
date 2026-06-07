# Tasks — readiness-hrv

## 1. 領域 (Requirement: Daily readiness score)

- [ ] 1.1 `SharedCore`：`ReadinessCalculator`（HRV + RHR 對 baseline → 0–100 分 + 等級 go-hard/steady/easy）。Requirement: Daily readiness score。
  行為：高於 baseline→高分；低於→低分；資料不足→nil。驗證：Swift Testing 三場景（high/low/nil）。

## 2. HealthKit (Requirement: Daily readiness score)

- [ ] 2.1 `HealthProviding`/`HealthKitService`/`PreviewHealthService` 讀 HRV（SDNN）+ resting HR 序列。
  行為：授權後回樣本（sim 空）。驗證：mock 回 canned；iOS build 綠。

## 3. UI (Requirement: Readiness informs Today)

- [ ] 3.1 `TodayView` 加 readiness chip（分數 + 等級 + 一句建議），無資料時隱藏。Requirement: Readiness informs Today。
  行為：有 readiness 顯示 chip。驗證：mock readiness 截圖 light+dark。
