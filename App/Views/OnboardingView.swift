import SwiftUI
import SwiftData
import SharedCore

/// First-run form that captures the profile + goal and creates the `ProfileRecord`.
struct OnboardingView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Display units come from the device locale; storage is always metric.
    private let units = UnitPreference.defaultValue(for: Locale.current)

    @State private var age = 30
    @State private var sex: BiologicalSex = .male
    @State private var weightKg = 75.0
    @State private var heightCm = 175.0
    // Imperial-entry fields (used only when `units == .imperial`), converted
    // to metric in `save()`. Defaults mirror the metric defaults above.
    @State private var weightLb = 165.0
    @State private var heightFeet = 5
    @State private var heightInches = 9
    @State private var activity: ActivityLevel = .moderate
    @State private var goalIsLose = false
    @State private var loseRate = 0.5
    @State private var didSave = false
    @State private var showsIntro = true

    var body: some View {
        NavigationStack {
            if showsIntro {
                OnboardingIntroView {
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                        showsIntro = false
                    }
                }
            } else {
                form
            }
        }
        .tint(Theme.accent)
        .sensoryFeedback(.success, trigger: didSave)
    }

    private var form: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    header

                    aboutSection

                    activitySection

                    goalSection

                    Button(action: save) {
                        Label("Get started", systemImage: "arrow.right.circle.fill")
                    }
                    .buttonStyle(PrimaryButton())
                    .disabled(!isValid)
                }
                .padding(Spacing.lg)
            }
            .background(Theme.background)
            .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Image(systemName: "bolt.heart.fill")
                .font(.title)
                .foregroundStyle(Theme.accent)
                .frame(width: 52, height: 52)
                .background(Theme.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
            Text("Z2 / 4×4 Trainer")
                .font(.rounded(.largeTitle, weight: .bold))
                .foregroundStyle(Theme.label)
            Text("Build your aerobic base and lift your fitness with workouts tuned to you — Zone 2 easy days and Norwegian 4×4 intervals.")
                .font(.subheadline)
                .foregroundStyle(Theme.secondaryLabel)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("About you")
            Text("We use these to calculate your personal heart-rate zones and weekly targets.")
                .font(.caption)
                .foregroundStyle(Theme.secondaryLabel)
                .fixedSize(horizontal: false, vertical: true)
            Card {
                VStack(spacing: Spacing.md) {
                    AccessibleStepper(title: "Age", value: $age, range: 12...100,
                                      valueText: "\(age)")
                    Divider()
                    Picker("Sex", selection: $sex) {
                        ForEach(BiologicalSex.allCases, id: \.self) {
                            Text($0.rawValue.capitalized).tag($0)
                        }
                    }
                    Divider()
                    if units == .imperial {
                        LabeledContent("Weight (lb)") {
                            TextField("lb", value: $weightLb, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .accessibilityLabel("Weight in pounds")
                        }
                        Divider()
                        LabeledContent("Height (ft + in)") {
                            HStack(spacing: Spacing.sm) {
                                TextField("ft", value: $heightFeet, format: .number)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 44)
                                    .accessibilityLabel("Height, feet")
                                Text("ft")
                                    .foregroundStyle(Theme.secondaryLabel)
                                TextField("in", value: $heightInches, format: .number)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 44)
                                    .accessibilityLabel("Height, inches")
                                Text("in")
                                    .foregroundStyle(Theme.secondaryLabel)
                            }
                        }
                    } else {
                        LabeledContent("Weight (kg)") {
                            TextField("kg", value: $weightKg, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .accessibilityLabel("Weight in kilograms")
                        }
                        Divider()
                        LabeledContent("Height (cm)") {
                            TextField("cm", value: $heightCm, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .accessibilityLabel("Height in centimetres")
                        }
                    }
                }
            }
        }
    }

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Daily activity")
            Card {
                Picker("Activity", selection: $activity) {
                    ForEach(ActivityLevel.allCases, id: \.self) {
                        Text($0.rawValue).tag($0)
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
                    Toggle("Lose weight", isOn: $goalIsLose.animation(reduceMotion ? nil : .easeInOut(duration: 0.25)))
                    if goalIsLose {
                        VStack(spacing: Spacing.md) {
                            Divider()
                            AccessibleStepper(
                                title: "Rate", value: $loseRate, range: 0.25...1.0, step: 0.25,
                                valueText: units == .imperial
                                    ? String(format: "%.2f lb/week", UnitConvert.kgToLb(loseRate))
                                    : String(format: "%.2f kg/week", loseRate)
                            )
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
        }
    }

    /// Block profile creation until body metrics are positive (in either unit system).
    private var isValid: Bool {
        switch units {
        case .metric: weightKg > 0 && heightCm > 0
        case .imperial: weightLb > 0 && heightFeet >= 0 && heightInches >= 0
            && (heightFeet * 12 + heightInches) > 0
        }
    }

    private func save() {
        let storedWeightKg = units == .imperial ? UnitConvert.lbToKg(weightLb) : weightKg
        let storedHeightCm = units == .imperial
            ? UnitConvert.feetInchesToCm(feet: heightFeet, inches: heightInches) : heightCm
        let record = ProfileRecord(
            age: age, sex: sex, weightKg: storedWeightKg, heightCm: storedHeightCm,
            activity: activity, goalIsLose: goalIsLose, loseRateKgPerWeek: loseRate,
            units: units
        )
        context.insert(record)
        didSave = true
    }
}
