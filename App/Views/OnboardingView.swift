import SwiftUI
import SwiftData
import SharedCore

/// First-run form that captures the profile + goal and creates the `ProfileRecord`.
struct OnboardingView: View {
    @Environment(\.modelContext) private var context

    @State private var age = 30
    @State private var sex: BiologicalSex = .male
    @State private var weightKg = 75.0
    @State private var heightCm = 175.0
    @State private var activity: ActivityLevel = .moderate
    @State private var goalIsLose = false
    @State private var loseRate = 0.5

    var body: some View {
        NavigationStack {
            Form {
                Section("About you") {
                    Stepper("Age: \(age)", value: $age, in: 12...100)
                    Picker("Sex", selection: $sex) {
                        ForEach(BiologicalSex.allCases, id: \.self) {
                            Text($0.rawValue.capitalized).tag($0)
                        }
                    }
                    LabeledContent("Weight (kg)") {
                        TextField("kg", value: $weightKg, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("Height (cm)") {
                        TextField("cm", value: $heightCm, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section("Daily activity") {
                    Picker("Activity", selection: $activity) {
                        ForEach(ActivityLevel.allCases, id: \.self) {
                            Text($0.rawValue).tag($0)
                        }
                    }
                }

                Section("Goal") {
                    Toggle("Lose weight", isOn: $goalIsLose)
                    if goalIsLose {
                        Stepper("Rate: \(loseRate, specifier: "%.2f") kg/week",
                                value: $loseRate, in: 0.25...1.0, step: 0.25)
                    }
                }

                Section {
                    Button("Get started", action: save)
                        .frame(maxWidth: .infinity)
                        .bold()
                }
            }
            .navigationTitle("Welcome")
        }
    }

    private func save() {
        let record = ProfileRecord(
            age: age, sex: sex, weightKg: weightKg, heightCm: heightCm,
            activity: activity, goalIsLose: goalIsLose, loseRateKgPerWeek: loseRate
        )
        context.insert(record)
    }
}
