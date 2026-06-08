import SwiftUI
import SwiftData
import SharedCore

/// Logs a completed workout by hand (works without Apple Health or a Watch).
struct ManualEntryView: View {
    let defaultType: SessionType

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var type: SessionType
    @State private var date = Date.now
    @State private var durationMin = 40
    @State private var energy = ""
    @State private var didSave = false

    init(defaultType: SessionType = .zone2) {
        self.defaultType = defaultType
        _type = State(initialValue: defaultType)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                detailsSection

                Button("Log workout") { save() }
                    .buttonStyle(PrimaryButton())
            }
            .padding(Spacing.lg)
        }
        .background(Theme.background)
        .navigationTitle("Log workout")
        .navigationBarTitleDisplayMode(.inline)
        .tint(Theme.accent)
        .sensoryFeedback(.success, trigger: didSave)
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Workout")
            Card {
                VStack(spacing: Spacing.md) {
                    Picker("Type", selection: $type) {
                        Text(SessionType.zone2.displayName).tag(SessionType.zone2)
                        Text(SessionType.norwegian4x4.displayName).tag(SessionType.norwegian4x4)
                    }
                    Divider()
                    DatePicker("When", selection: $date, in: ...Date.now)
                        .accessibilityLabel("Workout date and time")
                        .accessibilityHint("Select when you completed this workout")
                    Divider()
                    Stepper("Duration: \(durationMin) min", value: $durationMin, in: 5...240, step: 5)
                    Divider()
                    LabeledContent("Active energy (kcal)") {
                        TextField("Leave blank if not tracked", text: $energy)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .accessibilityLabel("Active energy in kilocalories")
                            .accessibilityHint("Optional")
                            .onChange(of: energy) { _, new in
                                // Keep only digits so a stray paste can't be saved as garbage.
                                let digits = new.filter(\.isNumber)
                                if digits != new { energy = digits }
                            }
                    }
                }
            }
        }
    }

    private func save() {
        let log = WorkoutLog(
            date: date,
            type: type,
            durationMin: durationMin,
            activeEnergyKcal: Int(energy)
        )
        context.insert(log)
        didSave = true
        dismiss()
    }
}
