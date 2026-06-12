import SwiftUI
import SwiftData
import SharedCore

/// The most recent logged workouts: date, type, minutes, a source icon
/// (manual / Health / Watch), and the note when one exists.
struct RecentWorkoutsSection: View {
    @Query(sort: \WorkoutLog.date, order: .reverse) private var logs: [WorkoutLog]

    /// How many rows the list shows at most.
    private static let limit = 10

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Recent workouts")
            Card {
                if logs.isEmpty {
                    ContentUnavailableView(
                        "No workouts yet",
                        systemImage: "figure.run",
                        description: Text("Log a workout from the Today tab to see it here.")
                    )
                } else {
                    VStack(spacing: Spacing.md) {
                        ForEach(Array(logs.prefix(Self.limit).enumerated()), id: \.element.persistentModelID) { index, log in
                            if index > 0 { Divider() }
                            row(log)
                        }
                    }
                }
            }
        }
    }

    private func row(_ log: WorkoutLog) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(spacing: Spacing.md) {
                Image(systemName: log.type.systemImage)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.accent)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text(log.type.displayName)
                        .font(.rounded(.subheadline, weight: .semibold))
                        .foregroundStyle(Theme.label)
                    Text(log.date, format: .dateTime.month(.abbreviated).day().hour().minute())
                        .font(.caption)
                        .foregroundStyle(Theme.secondaryLabel)
                }
                Spacer()
                Text("\(log.durationMin) min")
                    .numericStyle(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.label)
                Image(systemName: sourceIcon(log.source))
                    .font(.caption)
                    .foregroundStyle(Theme.secondaryLabel)
                    .accessibilityLabel(sourceLabel(log.source))
            }
            if let note = log.note, !note.isEmpty {
                Text(note)
                    .font(.caption)
                    .foregroundStyle(Theme.secondaryLabel)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.leading, 24 + Spacing.md)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func sourceIcon(_ source: WorkoutSource) -> String {
        switch source {
        case .manual: "square.and.pencil"
        case .health: "heart.fill"
        case .watch: "applewatch"
        }
    }

    private func sourceLabel(_ source: WorkoutSource) -> String {
        switch source {
        case .manual: String(localized: "Logged manually")
        case .health: String(localized: "From Apple Health")
        case .watch: String(localized: "From Apple Watch")
        }
    }
}

#Preview {
    ScrollView {
        RecentWorkoutsSection()
            .padding()
    }
    .modelContainer(for: [WorkoutLog.self], inMemory: true)
}
