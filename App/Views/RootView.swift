import SwiftUI
import SwiftData
import SharedCore

/// Shows onboarding until a profile exists, then the main tabs.
struct RootView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [ProfileRecord]

    var body: some View {
        Group {
            if let profile = profiles.first {
                MainTabView(profile: profile)
            } else {
                OnboardingView()
            }
        }
        .task { seedForUITestingIfRequested() }
    }

    /// Inserts a default profile when launched with `-seedProfile` (used by UI smoke tests).
    private func seedForUITestingIfRequested() {
        guard ProcessInfo.processInfo.arguments.contains("-seedProfile"),
              profiles.isEmpty else { return }
        context.insert(ProfileRecord(age: 30, sex: .male, weightKg: 80, heightCm: 180))
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
