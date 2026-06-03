import SwiftUI
import SwiftData
import SharedCore

/// Shows onboarding until a profile exists, then the main tabs.
struct RootView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [ProfileRecord]
    @State private var health = HealthStore(provider: HealthKitService())

    var body: some View {
        Group {
            if let profile = profiles.first {
                MainTabView(profile: profile, health: health)
            } else {
                OnboardingView()
            }
        }
        .task { seedForUITestingIfRequested() }
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

    var body: some View {
        TabView {
            TodayView(profile: profile, health: health)
                .tabItem { Label("Today", systemImage: "flame.fill") }
            WeekView(profile: profile)
                .tabItem { Label("Week", systemImage: "calendar") }
            HistoryView(health: health)
                .tabItem { Label("History", systemImage: "chart.bar.fill") }
            SettingsView(profile: profile, health: health)
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
    }
}
