import SwiftUI
import SwiftData
import SharedCore

/// Full five-zone editor for aligning the app's heart-rate zones with the ones
/// Apple Watch uses during workouts. Two paths:
///
///  1. **Import from Health** — seeds all five bands from your resting HR and
///     observed-max HR using the heart-rate-reserve (Karvonen) method Apple uses
///     by default. A close estimate, since HealthKit doesn't expose the Fitness
///     app's configured boundaries.
///  2. **Manual entry** — type the exact numbers shown in the Fitness app
///     (Watch → Workout → zones) for a guaranteed exact match.
///
/// Either path switches the profile to the `.custom` zone method, so the watch
/// 4×4 (warmup/recovery = Zone 2, hard = Zone 4–5, cooldown = Zone 1) follows
/// these bands.
struct AppleZonesView: View {
    @Bindable var profile: ProfileRecord
    let health: HealthStore

    @Environment(\.modelContext) private var context
    @State private var importing = false
    @State private var importNote: String?
    @State private var importFailed = false

    /// Age-max-derived defaults seed the bands the first time a stepper is touched.
    private var defaultCustomZones: [HRRange] {
        let calc = HRZoneCalculator(maxHR: profile.maxHROverride ?? (220 - profile.age))
        return HRZone.allCases.map { calc.range(for: $0) }
    }

    /// Read-or-seed the custom bands, then read/write one zone's bound. Any edit
    /// also switches the active method to custom so the change actually takes effect.
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
                profile.zoneMethod = .custom
            }
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                intro
                importSection
                zonesSection
                orderWarning
                hardPreview
            }
            .padding(Spacing.lg)
        }
        .background(Theme.background)
        .navigationTitle("Apple HR Zones")
        .navigationBarTitleDisplayMode(.inline)
        .tint(Theme.accent)
        .syncsProfileToWatch(profile, context: context)
    }

    // MARK: - Sections

    private var intro: some View {
        Card {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Match Apple Watch zones")
                    .font(.serif(.title3, weight: .semibold))
                    .foregroundStyle(Theme.label)
                Text("Apple Watch derives workout zones from your heart-rate reserve, so its numbers differ from age-based ones. Import to estimate them from Health, or type the exact values from the Fitness app for a perfect match.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.secondaryLabel)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var importSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("From Health")
            Card {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Button {
                        Task { await importFromHealth() }
                    } label: {
                        if importing {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Label("Import from Health", systemImage: "heart.fill")
                        }
                    }
                    .buttonStyle(PrimaryButton())
                    .disabled(importing)

                    if let note = importNote {
                        Label {
                            Text(note)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(importFailed ? Theme.warning : Theme.secondaryLabel)
                                .fixedSize(horizontal: false, vertical: true)
                        } icon: {
                            Image(systemName: importFailed ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                                .foregroundStyle(importFailed ? Theme.warning : Theme.success)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Text("HealthKit can't read the Fitness app's exact zone boundaries, so an import is a close estimate. Fine-tune below to match exactly.")
                        .font(.caption)
                        .foregroundStyle(Theme.secondaryLabel)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var zonesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Zones")
            Card {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    ForEach(HRZone.allCases, id: \.self) { zone in
                        bandEditor(zone)
                        if zone != HRZone.allCases.last {
                            Divider()
                        }
                    }
                }
            }
        }
    }

    private func bandEditor(_ zone: HRZone) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: zone.glyph)
                    .foregroundStyle(zone.color)
                    .accessibilityHidden(true)
                Text(zone.displayName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.label)
            }
            AccessibleStepper(title: "\(zone.displayName) lower",
                              value: customBound(zone: zone, isLower: true), range: 60...220,
                              valueText: "\(customBound(zone: zone, isLower: true).wrappedValue) bpm")
            AccessibleStepper(title: "\(zone.displayName) upper",
                              value: customBound(zone: zone, isLower: false), range: 60...220,
                              valueText: "\(customBound(zone: zone, isLower: false).wrappedValue) bpm")
        }
    }

    /// Warns when the entered bands aren't a clean ascending ladder, with a one-tap fix.
    @ViewBuilder
    private var orderWarning: some View {
        if let zones = profile.customZones, !zones.isAscendingZoneLadder {
            Card {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Label {
                        Text("These zones overlap or are out of order, which can misclassify your heart rate.")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.warning)
                            .fixedSize(horizontal: false, vertical: true)
                    } icon: {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(Theme.warning)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Button("Sort zones in order") {
                        profile.customZones = zones.sortedAscendingLadder()
                        profile.zoneMethod = .custom
                    }
                    .buttonStyle(SecondaryButton())
                }
            }
        }
    }

    /// Shows how the editable bands map onto the workout segments.
    private var hardPreview: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("4×4 mapping")
            Card {
                let calc = HRZoneCalculator(profile: profile.domain)
                VStack(spacing: Spacing.md) {
                    LabeledContent("Warmup · Recovery (Zone 2)") {
                        Text("\(calc.zone2.lower)–\(calc.zone2.upper) bpm")
                            .numericStyle(.body)
                            .foregroundStyle(Theme.secondaryLabel)
                    }
                    Divider()
                    LabeledContent("Hard (Zone 4–5)") {
                        Text("\(calc.fourByFourHard.lower)–\(calc.fourByFourHard.upper) bpm")
                            .numericStyle(.body)
                            .foregroundStyle(Theme.secondaryLabel)
                    }
                    Divider()
                    LabeledContent("Cooldown (Zone 1)") {
                        let z1 = calc.range(for: .zone1)
                        Text("\(z1.lower)–\(z1.upper) bpm")
                            .numericStyle(.body)
                            .foregroundStyle(Theme.secondaryLabel)
                    }
                }
            }
        }
    }

    // MARK: - Actions

    @MainActor
    private func importFromHealth() async {
        importing = true
        defer { importing = false }
        if !health.authorized {
            await health.connect()
        }
        guard let seed = await health.appleZoneSeed(
            age: profile.age,
            maxHROverride: profile.maxHROverride
        ) else {
            importFailed = true
            importNote = String(localized: "No resting heart rate in Health yet. Enter your zones manually below.")
            return
        }
        profile.customZones = seed.zones
        profile.zoneMethod = .custom
        importFailed = false
        importNote = String(localized: "Seeded from Health — resting \(seed.restingHR), max \(seed.maxHR) bpm. Adjust to match the Fitness app exactly.")
    }
}

#Preview {
    NavigationStack {
        AppleZonesView(
            profile: ProfileRecord(age: 30, sex: .male, weightKg: 80, heightCm: 180),
            health: HealthStore(provider: PreviewHealthService())
        )
    }
}
