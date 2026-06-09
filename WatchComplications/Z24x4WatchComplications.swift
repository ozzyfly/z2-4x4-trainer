import WidgetKit
import SwiftUI
import SharedCore

// MARK: - Bundle

@main
struct Z24x4ComplicationBundle: WidgetBundle {
    var body: some Widget {
        NextSessionComplication()
    }
}

// MARK: - Timeline

struct NextEntry: TimelineEntry {
    let date: Date
    let session: PlannedSession
}

struct ComplicationProvider: TimelineProvider {
    /// Next non-rest planned session, computed directly from SharedCore (no App
    /// Group needed on the watch). Uses the default goal until a synced profile exists.
    private func nextSession() -> PlannedSession {
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

// MARK: - Complication

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

private extension SessionType {
    var title: String {
        switch self {
        case .zone2: return "Zone 2"
        case .norwegian4x4: return "4×4"
        case .rest: return "Rest"
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
