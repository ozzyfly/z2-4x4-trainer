## 1. Today 空狀態

- [ ] 1.1 App/Views/TodayView.swift：WorkoutLog 查詢為空時改顯示歡迎卡（DesignSystem 的 Card + PrimaryButton）：說明今天課表（型別與分鐘）、CTA「開始引導訓練」（導向 GuidedPlayer）與「手動記錄」（開 ManualEntry sheet）；登錄第一筆後恢復一般內容。新字串走 String Catalog 鍵並回報 zh-Hant/es/ja 片段（不直接改 catalog 檔）。完成條件：新安裝（不帶 -seedProfile 的種子紀錄）顯示歡迎卡，記錄一筆後消失（驗證需求：Today welcomes first-time users）。

## 2. Onboarding 介紹頁

- [ ] 2.1 新增 App/Views/OnboardingIntroView.swift：App 一句話定位 + 三個重點（Zone 2 與 4×4 處方、Apple Health 輸入、資料只留在裝置）+「繼續」按鈕；App/Views/OnboardingView.swift 以單行接入作為第 0 步（intro 完成才進表單）。新字串走 catalog 片段。完成條件：新安裝先看到介紹頁，按繼續才到表單（驗證需求：Onboarding opens with an intro）。

## 3. 筆記輸入與最近紀錄

- [x] 3.1 App/Views/ManualEntryView.swift：加 note TextField（optional，存入既有 WorkoutLog.note）。注意：此檔由 health-writeback-robustness 變更的執行者一併修改以避免衝突；本變更只定義驗收。完成條件：存檔後 log.note 有值（驗證需求：Workout notes are usable）。
- [ ] 3.2 新增 App/Views/RecentWorkoutsSection.swift：最近 N=10 筆 WorkoutLog 列表（日期、類型、分鐘、來源圖示：手動/Health/Watch，note 存在時顯示）；以單行插入 App/Views/HistoryView.swift（圖表下方）。新字串走 catalog 片段。完成條件：列表顯示手動與匯入紀錄並區分來源、note 可見（驗證需求：Workout notes are usable）。

## 4. es/ja 定稿（必須最後執行）

- [ ] 4.1 本輪所有變更的新字串合併進 App/Localizable.xcstrings 與 SharedCore/Sources/SharedCore/Localizable.xcstrings 後，逐條審閱 es 與 ja 的 needs_review 條目（術語一致性：Zone 2、4×4、readiness、streak 的譯法統一），修正後將 state 改為 translated。完成條件：兩個 catalog 的 es/ja needs_review 條目數為 0（驗證需求：Spanish and Japanese are finalized）。

## 5. 驗證

- [ ] 5.1 xcodebuild iOS scheme build 綠；模擬器新安裝路徑：介紹頁 → 表單 → Today 歡迎卡 → 手動記錄（含 note）→ 歡迎卡消失、History 最近紀錄列表顯示 note；-AppleLanguages "(es)" 與 "(ja)" 各抽查 Today/Settings/History 三畫面譯文正常顯示（驗證需求：Reviewed UI renders、No needs-review entries remain）。
