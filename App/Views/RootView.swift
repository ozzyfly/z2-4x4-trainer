import SwiftUI
import SwiftData
import SharedCore

/// Shows onboarding until a profile exists, then the main tabs.
struct RootView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [ProfileRecord]
    @State private var health = HealthStore(
        provider: ProcessInfo.processInfo.arguments.contains("-mockHealth")
            ? PreviewHealthService() : HealthKitService()
    )

    var body: some View {
        Group {
            if let profile = profiles.first {
                MainTabView(profile: profile, health: health)
            } else {
                OnboardingView()
            }
        }
        .task {
            seedForUITestingIfRequested()
            // Populate Health-derived UI (readiness, VO2max trend) with canned data for UI smoke tests.
            if ProcessInfo.processInfo.arguments.contains("-mockHealth") {
                await health.connect()
            }
        }
    }

    /// Inserts a default profile when launched with `-seedProfile` (used by UI smoke tests).
    private func seedForUITestingIfRequested() {
        let args = ProcessInfo.processInfo.arguments
        if args.contains("-seedProfile"), profiles.isEmpty {
            context.insert(ProfileRecord(age: 30, sex: .male, weightKg: 80, heightCm: 180))
        }
        if args.contains("-seedWorkouts") {
            seedSampleWorkouts()
        }
        try? context.save()
    }

    /// Inserts a handful of sample workouts spread across the current week (UI smoke tests).
    private func seedSampleWorkouts() {
        let existing = (try? context.fetch(FetchDescriptor<WorkoutLog>())) ?? []
        guard existing.isEmpty else { return }

        let cal = Calendar.current
        let week = cal.dateInterval(of: .weekOfYear, for: .now)?.start ?? .now
        let samples: [(dayOffset: Int, type: SessionType, minutes: Int, kcal: Int)] = [
            (0, .zone2, 45, 380),
            (2, .norwegian4x4, 30, 320),
            (3, .zone2, 50, 410),
            (5, .norwegian4x4, 28, 300)
        ]
        for s in samples {
            let date = cal.date(byAdding: .day, value: s.dayOffset, to: week) ?? .now
            context.insert(WorkoutLog(
                date: date,
                type: s.type,
                durationMin: s.minutes,
                activeEnergyKcal: s.kcal
            ))
        }
    }
}

struct MainTabView: View {
    let profile: ProfileRecord
    let health: HealthStore
    /// Honors `-startTab <n>` for deterministic UI screenshots (0=Today…3=Settings).
    @State private var selection: Int = {
        let args = ProcessInfo.processInfo.arguments
        if let i = args.firstIndex(of: "-startTab"), i + 1 < args.count, let n = Int(args[i + 1]) {
            return n
        }
        return 0
    }()

    var body: some View {
        TabView(selection: $selection) {
            TodayView(profile: profile, health: health)
                .tabItem { Label("Today", systemImage: "flame.fill") }
                .tag(0)
            WeekView(profile: profile)
                .tabItem { Label("Week", systemImage: "calendar") }
                .tag(1)
            HistoryView(health: health)
                .tabItem { Label("History", systemImage: "chart.bar.fill") }
                .tag(2)
            AchievementsView(profile: profile, health: health)
                .tabItem { Label("Awards", systemImage: "trophy.fill") }
                .tag(3)
            SettingsView(profile: profile, health: health)
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(4)
        }
        .tint(Theme.accent)
        // Widgets deep-link here: z24x4://today opens the Today tab.
        .onOpenURL { url in
            if url.host == "today" { selection = 0 }
        }
    }
}
