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

    init(defaultType: SessionType = .zone2) {
        self.defaultType = defaultType
        _type = State(initialValue: defaultType)
    }

    var body: some View {
        Form {
            Picker("Type", selection: $type) {
                Text(SessionType.zone2.displayName).tag(SessionType.zone2)
                Text(SessionType.norwegian4x4.displayName).tag(SessionType.norwegian4x4)
            }
            DatePicker("When", selection: $date)
            Stepper("Duration: \(durationMin) min", value: $durationMin, in: 5...240, step: 5)
            LabeledContent("Active energy (kcal)") {
                TextField("optional", text: $energy)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
            }
            Section {
                Button("Save") { save() }
                    .frame(maxWidth: .infinity)
                    .bold()
            }
        }
        .navigationTitle("Log workout")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func save() {
        let log = WorkoutLog(
            date: date,
            type: type,
            durationMin: durationMin,
            activeEnergyKcal: Int(energy)
        )
        context.insert(log)
        dismiss()
    }
}
