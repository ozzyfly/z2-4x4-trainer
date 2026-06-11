import SwiftUI
import SwiftData
import SharedCore
import UIKit

/// Edit the profile: max-HR override, goal, weight, activity. Writes straight to the record.
struct SettingsView: View {
    @Bindable var profile: ProfileRecord
    let health: HealthStore
    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @AppStorage("remindersEnabled") private var remindersEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 18
    @AppStorage("reminderMinute") private var reminderMinute = 0

    /// Notification permission is denied in system Settings, so reminders can't fire.
    @State private var notificationsDenied = false
    /// The last reschedule attempt threw — surfaced inline instead of failing silently.
    @State private var reminderScheduleFailed = false

    init(profile: ProfileRecord, health: HealthStore) {
        self.profile = profile
        self.health = health
    }

    /// Bridges the stored hour/minute to a `Date` for the `DatePicker`.
    private var reminderTime: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(
                    from: DateComponents(hour: reminderHour, minute: reminderMinute)
                ) ?? Date()
            },
            set: { newValue in
                let c = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                reminderHour = c.hour ?? 18
                reminderMinute = c.minute ?? 0
            }
        )
    }

    private func scheduleReminders() async {
        do {
            let outcome = try await ReminderScheduler.reschedule(
                plan: TrainingPlan.weekly(for: profile.domain.goal),
                hour: reminderHour,
                minute: reminderMinute
            )
            reminderScheduleFailed = false
            notificationsDenied = (outcome == .notAuthorized)
        } catch {
            reminderScheduleFailed = true
        }
    }

    private func refreshNotificationStatus() async {
        notificationsDenied = await ReminderScheduler.authorizationStatus() == .denied
    }

    /// Weight in the preferred display units; storage stays metric (kg).
    private var displayWeight: Binding<Double> {
        Binding(
            get: {
                profile.units == .imperial ? UnitConvert.kgToLb(profile.weightKg) : profile.weightKg
            },
            set: { newValue in
                profile.weightKg = profile.units == .imperial
                    ? UnitConvert.lbToKg(newValue) : newValue
            }
        )
    }

    private var hasOverride: Binding<Bool> {
        Binding(
            get: { profile.maxHROverride != nil },
            set: { profile.maxHROverride = $0 ? (220 - profile.age) : nil }
        )
    }

    /// Resting HR for the Karvonen control: nil means "not set", surfaced as a Bool toggle.
    private var hasRestingHR: Binding<Bool> {
        Binding(
            get: { profile.restingHR != nil },
            set: { profile.restingHR = $0 ? (profile.restingHR ?? 60) : nil }
        )
    }

    private var restingHRValue: Binding<Int> {
        Binding(
            get: { profile.restingHR ?? 60 },
            set: { profile.restingHR = $0 }
        )
    }

    /// Age-max-derived defaults seed the custom bands the first time the user edits them.
    private var defaultCustomZones: [HRRange] {
        let calc = HRZoneCalculator(maxHR: profile.maxHROverride ?? (220 - profile.age))
        return HRZone.allCases.map { calc.range(for: $0) }
    }

    /// Read-or-seed the custom bands, then read/write a single zone's bound.
    private func customBound(zone: HRZone, isLower: Bool) -> Binding<Int> {
        Binding(
            get: {
                let zones = profile.customZones ?? defaultCustomZones
                let range = zones.indices.contains(zone.rawValue - 1)
                    ? zones[zone.rawValue - 1]
                    : defaultCustomZones[zone.rawValue - 1]
                return isLower ? range.lower : range.upper
            },
            set: { newValue in
                var zones = profile.customZones ?? defaultCustomZones
                if zones.count < HRZone.allCases.count { zones = defaultCustomZones }
                let i = zone.rawValue - 1
                let current = zones[i]
                zones[i] = isLower
                    ? HRRange(lower: newValue, upper: max(newValue, current.upper))
                    : HRRange(lower: min(current.lower, newValue), upper: newValue)
                profile.customZones = zones
            }
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    profileSection

                    heartRateSection

                    zonesSection

                    goalSection

                    remindersSection

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
                    AccessibleStepper(title: "Age", value: $profile.age, range: 12...100,
                                      valueText: "\(profile.age)")
                    Divider()
                    Picker("Units", selection: $profile.units) {
                        Text("Metric").tag(UnitPreference.metric)
                        Text("Imperial").tag(UnitPreference.imperial)
                    }
                    Divider()
                    LabeledContent(profile.units == .imperial ? "Weight (lb)" : "Weight (kg)") {
                        TextField(profile.units == .imperial ? "lb" : "kg",
                                  value: displayWeight,
                                  format: .number.precision(.fractionLength(0...1)))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .id(profile.units) // re-seed the field text when units flip
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
                        AccessibleStepper(
                            title: "Max HR",
                            value: Binding(
                                get: { profile.maxHROverride ?? (220 - profile.age) },
                                set: { profile.maxHROverride = $0 }
                            ),
                            range: 120...220,
                            valueText: "\(profile.maxHROverride ?? 0) bpm"
                        )
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

    private var zonesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Zones")
            Card {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Picker("Method", selection: $profile.zoneMethod) {
                        Text("Age-based").tag(ZoneMethod.ageMax)
                        Text("Heart-rate reserve").tag(ZoneMethod.karvonen)
                        Text("Custom").tag(ZoneMethod.custom)
                    }

                    switch profile.zoneMethod {
                    case .ageMax:
                        EmptyView()
                    case .karvonen:
                        Divider()
                        Toggle("Set resting HR", isOn: hasRestingHR)
                        if profile.restingHR != nil {
                            AccessibleStepper(title: "Resting HR", value: restingHRValue,
                                              range: 30...100,
                                              valueText: "\(restingHRValue.wrappedValue) bpm")
                        } else {
                            Label {
                                Text("Resting HR is required for heart-rate-reserve zones. Without it, zones fall back to age-based.")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Theme.warning)
                                    .fixedSize(horizontal: false, vertical: true)
                            } icon: {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(Theme.warning)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    case .custom:
                        Divider()
                        customBandEditor(title: "Zone 2", zone: .zone2)
                        Divider()
                        customBandEditor(title: "Zone 4 (4×4)", zone: .zone4)
                        Text("Other zones use age-based defaults until edited.")
                            .font(.caption)
                            .foregroundStyle(Theme.secondaryLabel)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Divider()
                    LabeledContent("Zone 2 preview") {
                        let z2 = HRZoneCalculator(profile: profile.domain).zone2
                        Text("\(z2.lower)–\(z2.upper) bpm")
                            .numericStyle(.body)
                            .foregroundStyle(Theme.secondaryLabel)
                    }
                }
            }
        }
    }

    private func customBandEditor(title: String, zone: HRZone) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.label)
            AccessibleStepper(title: "\(title) lower",
                              value: customBound(zone: zone, isLower: true), range: 60...220,
                              valueText: "\(customBound(zone: zone, isLower: true).wrappedValue) bpm")
            AccessibleStepper(title: "\(title) upper",
                              value: customBound(zone: zone, isLower: false), range: 60...220,
                              valueText: "\(customBound(zone: zone, isLower: false).wrappedValue) bpm")
        }
    }

    private var goalSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Goal")
            Card {
                VStack(spacing: Spacing.md) {
                    Toggle("Lose weight", isOn: $profile.goalIsLose.animation(reduceMotion ? nil : .easeInOut(duration: 0.25)))
                    if profile.goalIsLose {
                        VStack(spacing: Spacing.md) {
                            Divider()
                            AccessibleStepper(
                                title: "Rate", value: $profile.loseRateKgPerWeek,
                                range: 0.25...1.0, step: 0.25,
                                valueText: profile.units == .imperial
                                    ? String(format: "%.2f lb/week",
                                             UnitConvert.kgToLb(profile.loseRateKgPerWeek))
                                    : String(format: "%.2f kg/week", profile.loseRateKgPerWeek)
                            )
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
        }
    }

    private var remindersSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Reminders")
            Card {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Toggle("Training reminders", isOn: $remindersEnabled)
                        .disabled(notificationsDenied)
                    if notificationsDenied {
                        Divider()
                        Label {
                            Text("Notifications are turned off for this app, so reminders can't be delivered.")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.warning)
                                .fixedSize(horizontal: false, vertical: true)
                        } icon: {
                            Image(systemName: "bell.slash.fill")
                                .foregroundStyle(Theme.warning)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
                            Link("Open Settings", destination: url)
                                .font(.subheadline.weight(.semibold))
                        }
                    }
                    if reminderScheduleFailed {
                        Label {
                            Text("Couldn't schedule reminders. Try again.")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.warning)
                                .fixedSize(horizontal: false, vertical: true)
                        } icon: {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(Theme.warning)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    if remindersEnabled && !notificationsDenied {
                        Divider()
                        DatePicker(
                            "Time",
                            selection: reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                    }
                }
            }
        }
        .task { await refreshNotificationStatus() }
        .onChange(of: remindersEnabled) { _, isOn in
            Task {
                if isOn {
                    if await ReminderScheduler.requestAuthorization() {
                        await scheduleReminders()
                    } else {
                        remindersEnabled = false
                        await refreshNotificationStatus()
                    }
                } else {
                    reminderScheduleFailed = false
                    await ReminderScheduler.cancelAll()
                }
            }
        }
        .onChange(of: reminderHour) { _, _ in
            if remindersEnabled { Task { await scheduleReminders() } }
        }
        .onChange(of: reminderMinute) { _, _ in
            if remindersEnabled { Task { await scheduleReminders() } }
        }
        .onChange(of: profile.goalIsLose) { _, _ in
            if remindersEnabled { Task { await scheduleReminders() } }
        }
    }

    private var healthSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Apple Health")
            Card {
                if health.authorized {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Theme.success)
                            Text("Connected")
                                .font(.headline)
                                .foregroundStyle(Theme.label)
                            Spacer()
                        }
                        Text("Syncing: Workouts · Active energy · Heart rate · VO2 max · Body weight")
                            .font(.caption)
                            .foregroundStyle(Theme.secondaryLabel)
                            .fixedSize(horizontal: false, vertical: true)
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
