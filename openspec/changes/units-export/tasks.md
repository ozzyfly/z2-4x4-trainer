## 1. SharedCore 純函式（TDD，Mac 上 swift test）

- [ ] 1.1 新增 SharedCore/Sources/SharedCore/UnitPreference.swift：public enum UnitPreference: String, Codable, Sendable { case metric, imperial }，static func defaultValue(for locale: Locale) -> UnitPreference（locale.measurementSystem == .us 時 imperial，否則 metric）。先寫測試：en_US → imperial、zh_TW/de_DE → metric。swift test 全綠（驗證需求：Unit preference with metric storage）。
- [ ] 1.2 新增 SharedCore/Sources/SharedCore/UnitConvert.swift 純函式：kgToLb/lbToKg、cmToFeetInches(_:) -> (feet: Int, inches: Int)（四捨五入到整吋）、feetInchesToCm。先寫測試：75kg↔165.35lb（±0.01 kg round-trip）、180cm→5ft 11in、5ft 11in→180±1cm、0 與負值行為。swift test 全綠（驗證需求：Imperial body-metric entry）。
- [ ] 1.3 新增 SharedCore/Sources/SharedCore/WorkoutExport.swift：輸入列 struct（date、type、durationMin、energyKcal、note、source）；csv() -> String（表頭 + ISO8601 日期 + RFC-4180：欄位含逗號/引號/換行時加引號、內部引號加倍）；json() -> Data（同列陣列）。先寫測試：含逗號/引號/換行 note 的跳脫、空清單只有表頭/空陣列、固定日期的 ISO8601 輸出。測試集中在新檔 SharedCore/Tests/SharedCoreTests/UnitsExportTests.swift（驗證需求：Workout history export）。

## 2. 單位偏好落地

- [ ] 2.1 App/Persistence/ProfileRecord.swift 新增 unitsRaw: String = "metric"（預設值確保 SwiftData 既有資料遷移安全）＋ computed var units: UnitPreference；onboarding 建檔時以 UnitPreference.defaultValue(for: Locale.current) 初始化。完成條件：iOS 編譯通過、舊資料開啟不 crash（驗證需求：Unit preference with metric storage）。
- [ ] 2.2 App/Views/SettingsView.swift：新增單位 picker（公制/英制）；體重欄與每週減重速率欄依偏好顯示 kg 或 lb（輸入即時換算回公制儲存）。新字串走 String Catalog 鍵並回報 zh-Hant/es/ja 片段（不直接改 catalog 檔）。完成條件：模擬器切換偏好後兩欄位單位即時改變、75kg 顯示 165lb（驗證需求：Unit preference with metric storage）。
- [ ] 2.3 App/Views/OnboardingView.swift：英制時體重欄單位 lb、身高改 ft+in 兩欄；儲存前換算公制；非正值仍停用「開始」按鈕。新字串同走 catalog 片段。完成條件：英制輸入 165lb/5ft11in 後儲存的 profile 約 75kg/180cm；0 或空值時按鈕停用（驗證需求：Imperial body-metric entry）。
- [ ] 2.4 App/Views/HistoryView.swift：體重圖表的軸與數列依偏好換算顯示（lb 時 y 軸與點值換算）。完成條件：切換偏好後圖表單位改變、資料筆數不變（驗證需求：Unit preference with metric storage）。

## 3. 匯出

- [ ] 3.1 App/Views/HistoryView.swift 工具列新增匯出 Menu：兩個 ShareLink，分別以 Transferable 包 csv()（.commaSeparatedText，檔名 workouts.csv）與 json()（.json，檔名 workouts.json），來源為 @Query 的 WorkoutLog 全列。新字串同走 catalog 片段。完成條件：模擬器點匯出出現分享面板，產出檔各含每筆紀錄一列/一元素；空歷史時 CSV 只有表頭（驗證需求：Workout history export）。

## 4. 驗證

- [ ] 4.1 cd SharedCore && swift test 全綠；xcodebuild iOS scheme build 綠；模擬器 -mockHealth -seedProfile 啟動：Settings 單位切換 75kg↔165lb round-trip、History 匯出 CSV/JSON 分享面板出現、onboarding 英制輸入路徑（新安裝）正常。
