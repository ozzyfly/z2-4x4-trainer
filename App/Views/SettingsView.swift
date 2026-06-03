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
            Form {
                Section("Profile") {
                    Stepper("Age: \(profile.age)", value: $profile.age, in: 12...100)
                    LabeledContent("Weight (kg)") {
                        TextField("kg", value: $profile.weightKg, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    Picker("Activity", selection: $profile.activity) {
                        ForEach(ActivityLevel.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }
                }

                Section("Heart rate") {
                    Toggle("Override max HR", isOn: hasOverride)
                    if profile.maxHROverride != nil {
                        Stepper("Max HR: \(profile.maxHROverride ?? 0)",
                                value: Binding(
                                    get: { profile.maxHROverride ?? (220 - profile.age) },
                                    set: { profile.maxHROverride = $0 }
                                ), in: 120...220)
                    } else {
                        LabeledContent("Estimated max HR", value: "\(220 - profile.age) bpm")
                    }
                }

                Section("Goal") {
                    Toggle("Lose weight", isOn: $profile.goalIsLose)
                    if profile.goalIsLose {
                        Stepper("Rate: \(profile.loseRateKgPerWeek, specifier: "%.2f") kg/week",
                                value: $profile.loseRateKgPerWeek, in: 0.25...1.0, step: 0.25)
                    }
                }

                Section("Apple Health") {
                    if health.authorized {
                        Label("Connected", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else {
                        Button {
                            Task {
                                await health.connect()
                                await health.refresh(context: context)
                            }
                        } label: {
                            Label("Connect Apple Health", systemImage: "heart.fill")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
