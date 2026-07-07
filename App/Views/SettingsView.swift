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
    @Environment(ProStore.self) private var pro
    @State private var showsPaywall = false

    @AppStorage("remindersEnabled") private var remindersEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 18
    @AppStorage("reminderMinute") private var reminderMinute = 0
    /// Whether workouts from Apple Health (external apps) are auto-imported.
    @AppStorage("autoImportHealth") private var autoImportHealth = true

    /// Notification permission is denied in system Settings, so reminders can't fire.
    @State private var notificationsDenied = false
    /// The last reschedule attempt threw — surfaced inline instead of failing silently.
    @State private var reminderScheduleFailed = false

    /// Resting-HR-from-Health fetch state.
    @State private var fetchingRestingHR = false
    @State private var restingHRNote: String?
    @State private var restingHRFetchFailed = false

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

    /// Pulls the latest resting heart rate from Apple Health into the profile.
    @MainActor
    private func fetchRestingHR() async {
        fetchingRestingHR = true
        defer { fetchingRestingHR = false }
        if !health.authorized {
            await health.connect()
        }
        if let hr = await health.latestRestingHR() {
            profile.restingHR = hr
            restingHRFetchFailed = false
            restingHRNote = String(localized: "Set to \(hr) bpm from Apple Health.")
        } else {
            restingHRFetchFailed = true
            restingHRNote = String(localized: "No resting heart rate found in Apple Health.")
        }
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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    proSection

                    profileSection

                    heartRateSection

                    zonesSection

                    advancedSection

                    goalSection

                    remindersSection

                    healthSection

                    languageSection
                }
                .padding(Spacing.lg)
            }
            .background(Theme.background)
            .navigationTitle("Settings")
        }
        .tint(Theme.accent)
        .syncsProfileToWatch(profile, context: context)
    }

    // MARK: - Sections

    /// Apple's supported path for per-app language: the system Settings page.
    /// A custom in-app override (AppleLanguages) needs a relaunch and fights
    /// String Catalogs — the deep link is the reliable, review-safe way.
    private var languageSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Language")
            Card {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text("English · 繁體中文 · Español · 日本語 · 한국어 · Deutsch · Français · Português")
                        .font(.footnote)
                        .foregroundStyle(Theme.secondaryLabel)
                        .fixedSize(horizontal: false, vertical: true)
                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Label("Change app language", systemImage: "globe")
                    }
                    .buttonStyle(SecondaryButton())
                }
            }
        }
    }

    @ViewBuilder
    private var proSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Z2/4×4 Pro")
            if pro.isPro {
                Card {
                    HStack(spacing: Spacing.md) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.title3)
                            .foregroundStyle(Theme.accent)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Pro unlocked")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.label)
                            Text("Thanks for supporting an independent, private-by-design app.")
                                .font(.footnote)
                                .foregroundStyle(Theme.secondaryLabel)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 0)
                    }
                    .accessibilityElement(children: .combine)
                }
            } else {
                Card {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Readiness in full, overtraining guard, adaptive coaching, fitness trend, export.")
                            .font(.footnote)
                            .foregroundStyle(Theme.secondaryLabel)
                            .fixedSize(horizontal: false, vertical: true)
                        Button {
                            showsPaywall = true
                        } label: {
                            Text("Unlock Pro")
                        }
                        .buttonStyle(PrimaryButton())
                    }
                }
            }
        }
        .sheet(isPresented: $showsPaywall) {
            ProPaywallView()
        }
    }

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
                        ForEach(ActivityLevel.allCases, id: \.self) { Text($0.displayName).tag($0) }
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

                        Button {
                            Task { await fetchRestingHR() }
                        } label: {
                            if fetchingRestingHR {
                                ProgressView().frame(maxWidth: .infinity)
                            } else {
                                Label("Use Apple Health", systemImage: "heart.fill")
                            }
                        }
                        .buttonStyle(SecondaryButton())
                        .disabled(fetchingRestingHR)

                        if let note = restingHRNote {
                            Text(note)
                                .font(.caption)
                                .foregroundStyle(restingHRFetchFailed ? Theme.warning : Theme.secondaryLabel)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    case .custom:
                        Divider()
                        NavigationLink {
                            AppleZonesView(profile: profile, health: health)
                        } label: {
                            HStack {
                                Label("Sync Apple HR zones", systemImage: "applewatch")
                                    .foregroundStyle(Theme.label)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Theme.secondaryLabel)
                            }
                            .frame(minHeight: 44)
                            .contentShape(Rectangle())
                        }
                        Text("Set all five zones to match Apple Watch — import from Health or enter them by hand.")
                            .font(.caption)
                            .foregroundStyle(Theme.secondaryLabel)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Divider()
                    Toggle("Strict hard effort (Zone 5)", isOn: $profile.hardEffortStrict)
                    Text("Off targets the top band (≈Zone 4–5). On tightens the 4×4 hard interval to Zone 5 for a sharper VO2max stimulus.")
                        .font(.caption)
                        .foregroundStyle(Theme.secondaryLabel)
                        .fixedSize(horizontal: false, vertical: true)

                    Divider()
                    let calc = HRZoneCalculator(profile: profile.domain)
                    LabeledContent("Zone 2 preview") {
                        Text("\(calc.zone2.lower)–\(calc.zone2.upper) bpm")
                            .numericStyle(.body)
                            .foregroundStyle(Theme.secondaryLabel)
                    }
                    LabeledContent("Hard preview") {
                        Text("\(calc.fourByFourHard.lower)–\(calc.fourByFourHard.upper) bpm")
                            .numericStyle(.body)
                            .foregroundStyle(Theme.secondaryLabel)
                    }
                }
            }
        }
    }

    private var advancedSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Advanced · 4×4 timing")
            Card {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    AccessibleStepper(title: "Warmup minimum", value: $profile.warmupMinSec,
                                      range: 60...300, step: 30, valueText: "\(profile.warmupMinSec) s")
                    Divider()
                    AccessibleStepper(title: "Hard time cap", value: $profile.hardWallCapSec,
                                      range: 300...720, step: 30, valueText: "\(profile.hardWallCapSec) s")
                    Divider()
                    AccessibleStepper(title: "Recovery minimum", value: $profile.recoveryMinSec,
                                      range: 0...120, step: 10, valueText: "\(profile.recoveryMinSec) s")
                    Divider()
                    Text("Tunes how the watch's adaptive 4×4 starts and ends each segment.")
                        .font(.caption)
                        .foregroundStyle(Theme.secondaryLabel)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
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
                                valueText: {
                                    if profile.units == .imperial {
                                        let n = UnitConvert.kgToLb(profile.loseRateKgPerWeek)
                                            .formatted(.number.precision(.fractionLength(2)))
                                        return String(localized: "\(n) lb/week")
                                    } else {
                                        let n = profile.loseRateKgPerWeek
                                            .formatted(.number.precision(.fractionLength(2)))
                                        return String(localized: "\(n) kg/week")
                                    }
                                }()
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
                        Divider()
                        Toggle("Auto-import workouts", isOn: $autoImportHealth)
                        Text("When on, workouts recorded elsewhere (Apple Health, other apps) are added to your history. Turn off to keep only your watch and manual sessions.")
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
