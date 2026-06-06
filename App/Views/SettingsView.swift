import SwiftUI
import SwiftData
import SharedCore

/// Edit the profile: max-HR override, goal, weight, activity. Writes straight to the record.
struct SettingsView: View {
    @Bindable var profile: ProfileRecord
    let health: HealthStore
    @Environment(\.modelContext) private var context

    init(profile: ProfileRecord, health: HealthStore) {
        self.profile = profile
        self.health = health
    }

    private var hasOverride: Binding<Bool> {
        Binding(
            get: { profile.maxHROverride != nil },
            set: { profile.maxHROverride = $0 ? (220 - profile.age) : nil }
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    profileSection

                    heartRateSection

                    goalSection

                    healthSection
                }
                .padding(Spacing.lg)
            }
            .background(Theme.background)
            .navigationTitle("Settings")
        }
        .tint(Theme.accent)
    }

    // MARK: - Sections

    private var profileSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Profile")
            Card {
                VStack(spacing: Spacing.md) {
                    Stepper("Age: \(profile.age)", value: $profile.age, in: 12...100)
                    Divider()
                    LabeledContent("Weight (kg)") {
                        TextField("kg", value: $profile.weightKg, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    Divider()
                    Picker("Activity", selection: $profile.activity) {
                        ForEach(ActivityLevel.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }
                }
            }
        }
    }

    private var heartRateSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Heart rate")
            Card {
                VStack(spacing: Spacing.md) {
                    Toggle("Override max HR", isOn: hasOverride)
                    Divider()
                    if profile.maxHROverride != nil {
                        Stepper("Max HR: \(profile.maxHROverride ?? 0)",
                                value: Binding(
                                    get: { profile.maxHROverride ?? (220 - profile.age) },
                                    set: { profile.maxHROverride = $0 }
                                ), in: 120...220)
                    } else {
                        LabeledContent("Estimated max HR") {
                            Text("\(220 - profile.age) bpm")
                                .numericStyle(.body)
                                .foregroundStyle(Theme.secondaryLabel)
                        }
                    }
                }
            }
        }
    }

    private var goalSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Goal")
            Card {
                VStack(spacing: Spacing.md) {
                    Toggle("Lose weight", isOn: $profile.goalIsLose)
                    if profile.goalIsLose {
                        Divider()
                        Stepper("Rate: \(profile.loseRateKgPerWeek, specifier: "%.2f") kg/week",
                                value: $profile.loseRateKgPerWeek, in: 0.25...1.0, step: 0.25)
                    }
                }
            }
        }
    }

    private var healthSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Apple Health")
            Card {
                if health.authorized {
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Connected")
                            .font(.headline)
                            .foregroundStyle(Theme.label)
                        Spacer()
                    }
                } else {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Sync workouts and active energy from Apple Health.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.secondaryLabel)
                            .fixedSize(horizontal: false, vertical: true)
                        Button {
                            Task {
                                await health.connect()
                                await health.refresh(context: context)
                            }
                        } label: {
                            Label("Connect Apple Health", systemImage: "heart.fill")
                        }
                        .buttonStyle(PrimaryButton())
                    }
                }
            }
        }
    }
}
