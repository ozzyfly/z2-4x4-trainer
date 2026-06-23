## 1. 本地化每週單位標籤（對應需求：Per-week unit labels are localized）

- [x] 1.1 實作需求 Per-week unit labels are localized：將 App/Views/SettingsView.swift 與 App/Views/OnboardingView.swift 的減重速率標籤改為 String(localized:)，數字以 locale-aware 格式化（loseRate.formatted(.number.precision(.fractionLength(2)))），單位鍵為 "%@ kg/week" 與 "%@ lb/week" 交由 catalog 擷取。行為：es／ja／zh-Hant 下單位翻譯、小數點符合 locale。驗證：iOS build SUCCEEDED 且 App/Localizable.xcstrings 含 "%@ kg/week"、"%@ lb/week" 兩鍵。
- [x] 1.2 將 App/Views/WeekView.swift 的 hard-sessions 與 energy 標籤改為 String(localized:)，鍵為 "%lld/week" 與 "%lld kcal/week"。行為：Week 畫面單位在非英語系翻譯。驗證：catalog 含該兩鍵；iOS build SUCCEEDED。
- [x] 1.3 在 App/Localizable.xcstrings 為四個新鍵補上 es／ja／zh-Hant 翻譯（period 譯為 /semana、/週），全部 state=translated。行為：三語單位字串完整、0 needs_review。驗證：以 Python 檢查四鍵的 es/ja/zh-Hant 皆 state=translated。

## 2. 驗證與回歸

- [x] 2.1 確認 iOS 測試全綠且無回歸。驗證：xcodebuild -project Z24x4Trainer.xcodeproj -scheme Z24x4Trainer -destination 'platform=iOS Simulator,name=iPhone 17' build test 輸出 BUILD SUCCEEDED 與 TEST SUCCEEDED。
