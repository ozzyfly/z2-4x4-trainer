import SwiftUI
import SwiftData
import SharedCore

/// Logs a completed workout by hand (works without Apple Health or a Watch).
struct ManualEntryView: View {
    let defaultType: SessionType
    private let health: HealthProviding

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var type: SessionType
    @State private var date = Date.now
    @State private var durationMin = 40
    @State private var energy = ""
    @State private var note = ""
    @State private var didSave = false
    @State private var showsHealthNotice = false

    init(defaultType: SessionType = .zone2, health: HealthProviding? = nil) {
        self.defaultType = defaultType
        self.health = health ?? (ProcessInfo.processInfo.arguments.contains("-mockHealth")
            ? PreviewHealthService() : HealthKitService())
        _type = State(initialValue: defaultType)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                detailsSection

                Button("Log workout") { save() }
                    .buttonStyle(PrimaryButton())
                    .disabled(didSave)

                if showsHealthNotice {
                    Label {
                        Text("Saved locally — couldn't add to Apple Health.")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Theme.warning)
                            .fixedSize(horizontal: false, vertical: true)
                    } icon: {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(Theme.warning)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityLabel("Saved locally — couldn't add to Apple Health.")
                }
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
                    Stepper(String(localized: "Duration: \(durationMin) min"), value: $durationMin, in: 5...240, step: 5)
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
                    Divider()
                    LabeledContent("Note") {
                        TextField("How did it go?", text: $note, axis: .vertical)
                            .multilineTextAlignment(.trailing)
                            .lineLimit(1...3)
                            .accessibilityLabel("Workout note")
                            .accessibilityHint("Optional")
                    }
                }
            }
        }
    }

    private func save() {
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let log = WorkoutLog(
            date: date,
            type: type,
            durationMin: durationMin,
            activeEnergyKcal: Int(energy),
            note: trimmedNote.isEmpty ? nil : trimmedNote
        )
        context.insert(log)
        WidgetSnapshotWriter.update(context: context)
        didSave = true

        Task {
            let wroteBack = await Self.writeBackToHealth(log, using: health)
            if !wroteBack {
                // Non-blocking: the entry is already saved locally; surface the
                // miss briefly, then close as usual.
                showsHealthNotice = true
                try? await Task.sleep(for: .seconds(1.6))
            }
            dismiss()
        }
    }

    /// Writes `log` back to Apple Health when share authorization is granted,
    /// stamping the returned workout UUID onto the log so later Health imports
    /// dedupe against it. Returns whether the write succeeded; the local log is
    /// always kept either way.
    @MainActor
    static func writeBackToHealth(_ log: WorkoutLog, using health: HealthProviding) async -> Bool {
        guard await health.workoutWriteAuthorized() else { return false }
        do {
            let uuid = try await health.saveWorkout(
                type: log.type,
                start: log.date,
                durationMin: log.durationMin,
                energyKcal: log.activeEnergyKcal
            )
            log.healthUUID = uuid
            return true
        } catch {
            return false
        }
    }
}
