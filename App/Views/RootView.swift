import SwiftUI
import SwiftData

/// Shows onboarding until a profile exists, then the main tabs.
struct RootView: View {
    @Query private var profiles: [ProfileRecord]

    var body: some View {
        if let profile = profiles.first {
            MainTabView(profile: profile)
        } else {
            OnboardingView()
        }
    }
}

struct MainTabView: View {
    let profile: ProfileRecord

    var body: some View {
        TabView {
            TodayView(profile: profile)
                .tabItem { Label("Today", systemImage: "flame.fill") }
            WeekView(profile: profile)
                .tabItem { Label("Week", systemImage: "calendar") }
            SettingsView(profile: profile)
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
    }
}
