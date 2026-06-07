# Tasks — streaks-achievements

## 1. 領域 (Requirement: Training streaks; Achievement catalog)

- [ ] 1.1 `SharedCore`：`StreakCalculator`（current/longest 週連續，從 `[ActivitySample]`）。Requirement: Training streaks。
  行為：連續訓練週數正確、缺週歸零。驗證：Swift Testing 兩場景（連續 3 週、缺週斷）。
- [ ] 1.2 `Achievement` 目錄 + `AchievementEvaluator`（first 4×4、10 sessions、7 天連續、weekly target ×4、VO2max up）。Requirement: Achievement catalog。
  行為：依歷史回 unlocked 集合。驗證：單元測試（first 4×4 解鎖、<10 sessions 鎖定）。

## 2. UI (Requirement: Achievement catalog; Celebration on unlock)

- [ ] 2.1 `App/Views/StreakBanner.swift`（Today 用元件）+ `App/Views/AchievementsView.swift`（徽章格、鎖/解鎖）+ `App/Persistence/AchievementRecord.swift`（解鎖日期）。
  行為：成就頁顯示鎖/解鎖徽章；Today 顯示連續週數。驗證：sim 截圖 AchievementsView light+dark。
- [ ] 2.2 慶祝 overlay（confetti + `.sensoryFeedback`）於解鎖/達標。Requirement: Celebration on unlock。
  行為：解鎖時出現慶祝 + 觸覺。驗證：手動觸發解鎖路徑於 sim 觀察 overlay。
