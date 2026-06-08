## 1. 採用 motion helper

- [x] 1.1 滿足需求「Motion and haptics」：在 `App/DesignSystem/Components.swift` 的 `TargetBar` 注入 `@Environment(\.accessibilityReduceMotion)`，將 `onAppear`/`onChange` 的 `withAnimation(.spring…)` 改為 `withMotion(.spring(response:0.6, dampingFraction:0.85), reduceMotion:…)`；Reduce Motion 開啟時 `animatedFraction` 即時設定、不動畫。
- [x] 1.2 在 `App/DesignSystem/Buttons.swift` 的 `PrimaryButton` 與 `SecondaryButton`，使按壓 `scaleEffect`/`opacity` 動畫於 Reduce Motion 開啟時不套用（以條件 animation 或不帶 animation）；關閉時維持原 `.easeOut(0.15)`。
- [x] 1.3 在 `App/Views/SettingsView.swift` 與 `App/Views/OnboardingView.swift`，將減重目標 toggle 的 `.animation`/條件欄位 `.transition` 改為尊重 Reduce Motion（`.motionAware` 或 Reduce Motion 開啟時不套 transition）；關閉時維持原動效。
- [x] 1.4 在 `App/Views/Celebration.swift` 將 `reduceMotion` 傳入 `ConfettiBurst`，其 `onAppear` 於 Reduce Motion 開啟時直接設最終狀態、不 `withAnimation`。

## 2. 驗證

- [x] 2.1 以 `xcodebuild` 編譯 iOS target（`Z24x4Trainer` scheme，iPhone 17 Pro simulator）成功；`SharedCore` 測試仍綠（`swift test` 58/58）；確認未改 Reduce Motion 關閉時的動畫外觀、未動 `Motion.swift`/watch/SharedCore。以模擬器開啟 Reduce Motion 確認 TargetBar、按鈕、目標 toggle、Celebration 皆無動畫即時到位。
