import SwiftUI
import SwiftData
import SharedCore

/// The most recent logged workouts: date, type, minutes, a source icon
/// (manual / Health / Watch), and the note when one exists.
struct RecentWorkoutsSection: View {
    @Query(sort: \WorkoutLog.date, order: .reverse) private var logs: [WorkoutLog]
    @Environment(\.modelContext) private var context

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
                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        ForEach(groups) { group in
                            VStack(alignment: .leading, spacing: Spacing.md) {
                                Text(group.header)
                                    .font(.caption2.weight(.semibold))
                                    .textCase(.uppercase)
                                    .tracking(1.2)
                                    .foregroundStyle(Theme.secondaryLabel)
                                    .accessibilityAddTraits(.isHeader)
                                ForEach(Array(group.logs.enumerated()), id: \.element.persistentModelID) { idx, log in
                                    if idx > 0 { Divider() }
                                    NavigationLink {
                                        WorkoutLogDetailView(log: log)
                                    } label: {
                                        row(log)
                                    }
                                    .buttonStyle(.plain)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            delete(log)
                                        } label: {
                                            Label("Delete workout", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    /// Recent logs grouped into Today / Yesterday / This week / Earlier buckets.
    private struct LogGroup: Identifiable {
        let id: String
        let header: LocalizedStringKey
        var logs: [WorkoutLog]
    }

    private var groups: [LogGroup] {
        var result: [LogGroup] = []
        var currentKey: String?
        for log in logs.prefix(Self.limit) {
            let key = bucketKey(log.date)
            if key != currentKey {
                result.append(LogGroup(id: key, header: bucketHeader(key), logs: [log]))
                currentKey = key
            } else {
                result[result.count - 1].logs.append(log)
            }
        }
        return result
    }

    private func bucketKey(_ date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return "today" }
        if cal.isDateInYesterday(date) { return "yesterday" }
        if cal.isDate(date, equalTo: .now, toGranularity: .weekOfYear) { return "thisweek" }
        return "earlier"
    }

    private func bucketHeader(_ key: String) -> LocalizedStringKey {
        switch key {
        case "today": return "Today"
        case "yesterday": return "Yesterday"
        case "thisweek": return "This week"
        default: return "Earlier"
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
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Theme.separator)
                    .accessibilityHidden(true)
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

    /// Deletes a log and tombstones its Health UUID so it isn't re-imported.
    private func delete(_ log: WorkoutLog) {
        if let uuid = log.healthUUID, !uuid.isEmpty {
            context.insert(DeletedWorkout(healthUUID: uuid))
        }
        context.delete(log)
        try? context.save()
        WidgetSnapshotWriter.update(context: context)
    }

    private func sourceIcon(_ source: WorkoutSource) -> String {
        switch source {
        case .manual: "square.and.pencil"
        case .health: "heart.fill"
        case .watch: "applewatch"
        case .guided: "play.circle.fill"
        }
    }

    private func sourceLabel(_ source: WorkoutSource) -> String {
        switch source {
        case .manual: String(localized: "Logged manually")
        case .health: String(localized: "From Apple Health")
        case .watch: String(localized: "From Apple Watch")
        case .guided: String(localized: "From a guided session")
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
