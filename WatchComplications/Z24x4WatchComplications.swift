import WidgetKit
import SwiftUI
import SharedCore

// MARK: - Bundle

@main
struct Z24x4ComplicationBundle: WidgetBundle {
    var body: some Widget {
        NextSessionComplication()
        ReadinessComplication()
        StreakComplication()
    }
}

// MARK: - Next-session timeline

struct NextEntry: TimelineEntry {
    let date: Date
    let session: PlannedSession
}

struct ComplicationProvider: TimelineProvider {
    /// Next non-rest planned session. Prefers the snapshot synced from the phone
    /// (real plan, real goal); falls back to a locally computed default-goal plan
    /// when nothing has been synced yet.
    private func nextSession() -> PlannedSession {
        if let snapshot = WidgetSnapshotStore.read(), snapshot.todayType != .rest {
            return PlannedSession(day: 0, type: snapshot.todayType, durationMin: snapshot.todayMinutes)
        }
        let plan = TrainingPlan.weekly(for: .maintainHealth)
        let cal = Calendar.current
        for offset in 0..<7 {
            guard let date = cal.date(byAdding: .day, value: offset, to: .now) else { continue }
            let session = plan.session(on: date)
            if session.type != .rest { return session }
        }
        return plan.session(on: .now)
    }

    func placeholder(in context: Context) -> NextEntry {
        NextEntry(date: .now, session: nextSession())
    }

    func getSnapshot(in context: Context, completion: @escaping (NextEntry) -> Void) {
        completion(NextEntry(date: .now, session: nextSession()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NextEntry>) -> Void) {
        let entry = NextEntry(date: .now, session: nextSession())
        // Recompute at the next day boundary.
        let next = Calendar.current.nextDate(after: .now, matching: DateComponents(hour: 0), matchingPolicy: .nextTime) ?? .now
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

// MARK: - Snapshot timeline (readiness + streak)

struct SnapshotEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}

struct SnapshotProvider: TimelineProvider {
    private func current() -> WidgetSnapshot { WidgetSnapshotStore.read() ?? .placeholder }

    func placeholder(in context: Context) -> SnapshotEntry {
        SnapshotEntry(date: .now, snapshot: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (SnapshotEntry) -> Void) {
        completion(SnapshotEntry(date: .now, snapshot: current()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SnapshotEntry>) -> Void) {
        let entry = SnapshotEntry(date: .now, snapshot: current())
        // The watch app reloads on each received context; refresh hourly as a fallback.
        let next = Calendar.current.date(byAdding: .hour, value: 1, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

// MARK: - Complications

struct NextSessionComplication: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Z24x4NextSession", provider: ComplicationProvider()) { entry in
            ComplicationView(session: entry.session)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Next session")
        .description("Your next Zone 2 or 4×4 session.")
        .supportedFamilies([.accessoryCircular, .accessoryCorner])
    }
}

struct ReadinessComplication: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Z24x4Readiness", provider: SnapshotProvider()) { entry in
            ReadinessComplicationView(snapshot: entry.snapshot)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Readiness")
        .description("Today's readiness score synced from your iPhone.")
        .supportedFamilies([.accessoryCircular, .accessoryCorner, .accessoryInline])
    }
}

struct StreakComplication: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Z24x4Streak", provider: SnapshotProvider()) { entry in
            StreakComplicationView(snapshot: entry.snapshot)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Streak")
        .description("Your current weekly training streak.")
        .supportedFamilies([.accessoryCircular, .accessoryCorner, .accessoryInline])
    }
}

private extension SessionType {
    var title: String {
        switch self {
        case .zone2: return String(localized: "Zone 2")
        case .norwegian4x4: return String(localized: "4×4")
        case .rest: return String(localized: "Rest")
        }
    }
    var glyph: String {
        switch self {
        case .zone2: return "figure.run"
        case .norwegian4x4: return "bolt.heart.fill"
        case .rest: return "moon.zzz.fill"
        }
    }
}

private extension ReadinessLabel {
    var title: String {
        switch self {
        case .goHard: return String(localized: "Go hard")
        case .steady: return String(localized: "Steady")
        case .easy:   return String(localized: "Take it easy")
        }
    }
    var glyph: String {
        switch self {
        case .goHard: return "bolt.fill"
        case .steady: return "equal.circle.fill"
        case .easy:   return "moon.fill"
        }
    }
}

// MARK: - Views

struct ComplicationView: View {
    @Environment(\.widgetFamily) private var family
    let session: PlannedSession

    var body: some View {
        switch family {
        case .accessoryCorner:
            Image(systemName: session.type.glyph)
                .font(.title3)
                .widgetLabel("\(session.type.title) · \(session.durationMin)m")
        default:
            VStack(spacing: 1) {
                Image(systemName: session.type.glyph).font(.title3)
                Text("\(session.durationMin)m").font(.caption2)
            }
        }
    }
}

struct ReadinessComplicationView: View {
    @Environment(\.widgetFamily) private var family
    let snapshot: WidgetSnapshot
    private var value: Int? { snapshot.readinessValue }
    private var label: ReadinessLabel? { snapshot.readinessLabel }

    var body: some View {
        switch family {
        case .accessoryCorner:
            Image(systemName: label?.glyph ?? "bolt.heart")
                .font(.title3)
                .widgetLabel(value.map { String(localized: "Readiness \($0)") } ?? String(localized: "Readiness —"))
        case .accessoryInline:
            Label {
                Text(value.map { String(localized: "Readiness \($0)") } ?? String(localized: "Readiness —"))
            } icon: {
                Image(systemName: label?.glyph ?? "bolt.heart")
            }
        default:
            Gauge(value: Double(value ?? 0), in: 0...100) {
                Image(systemName: label?.glyph ?? "bolt.heart")
            } currentValueLabel: {
                Text(value.map { "\($0)" } ?? "—")
            }
            .gaugeStyle(.accessoryCircularCapacity)
        }
    }
}

struct StreakComplicationView: View {
    @Environment(\.widgetFamily) private var family
    let snapshot: WidgetSnapshot
    /// Weeks when there is an active streak; nil renders the neutral placeholder.
    private var weeks: Int? { snapshot.streakWeeks.flatMap { $0 > 0 ? $0 : nil } }
    private var glyph: String { weeks != nil ? "flame.fill" : "flame" }

    var body: some View {
        switch family {
        case .accessoryCorner:
            Image(systemName: glyph)
                .font(.title3)
                .widgetLabel(weeks.map { String(localized: "\($0)-week streak") } ?? String(localized: "No streak yet"))
        case .accessoryInline:
            Label {
                Text(weeks.map { String(localized: "\($0) wk streak") } ?? String(localized: "No streak yet"))
            } icon: {
                Image(systemName: glyph)
            }
        default:
            VStack(spacing: 1) {
                Image(systemName: glyph).font(.title3)
                Text(weeks.map { "\($0)" } ?? "—")
                    .font(.caption2.weight(.semibold)).monospacedDigit()
            }
        }
    }
}
