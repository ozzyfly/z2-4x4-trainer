import WidgetKit
import SwiftUI
import SharedCore

// MARK: - Bundle

@main
struct Z24x4WidgetBundle: WidgetBundle {
    var body: some Widget {
        TodayWidget()
    }
}

// MARK: - Timeline

struct SnapshotEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}

struct Provider: TimelineProvider {
    private func current() -> WidgetSnapshot { WidgetSnapshotStore.read() ?? .placeholder }

    func placeholder(in context: Context) -> SnapshotEntry {
        SnapshotEntry(date: .now, snapshot: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (SnapshotEntry) -> Void) {
        completion(SnapshotEntry(date: .now, snapshot: current()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SnapshotEntry>) -> Void) {
        let entry = SnapshotEntry(date: .now, snapshot: current())
        // The app reloads on changes; refresh hourly as a fallback.
        let next = Calendar.current.date(byAdding: .hour, value: 1, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

// MARK: - Widget

struct TodayWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Z24x4Today", provider: Provider()) { entry in
            Z24x4WidgetView(entry: entry)
                .widgetURL(URL(string: "z24x4://today"))
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Today & Week")
        .description("Today's session and this week's progress.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryCircular])
    }
}

// MARK: - Session display helpers (local to the extension target)

private extension SessionType {
    var widgetTitle: String {
        switch self {
        case .zone2: return "Zone 2"
        case .norwegian4x4: return "4×4"
        case .rest: return "Rest"
        }
    }
    var widgetGlyph: String {
        switch self {
        case .zone2: return "figure.run"
        case .norwegian4x4: return "bolt.heart.fill"
        case .rest: return "moon.zzz.fill"
        }
    }
}

// MARK: - Views

struct Z24x4WidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: SnapshotEntry
    private var s: WidgetSnapshot { entry.snapshot }

    var body: some View {
        switch family {
        case .systemMedium: medium
        case .accessoryRectangular: lockRectangular
        case .accessoryCircular: lockCircular
        default: small
        }
    }

    private var todayLine: String {
        s.todayType == .rest ? "Rest day" : "\(s.todayType.widgetTitle) · \(s.todayMinutes) min"
    }

    private var small: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Today", systemImage: s.todayType.widgetGlyph)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(s.todayType == .rest ? "Rest" : s.todayType.widgetTitle)
                .font(.headline)
            if s.todayType != .rest {
                Text("\(s.todayMinutes) min").font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            ProgressView(value: s.weekFraction)
                .tint(.accentColor)
            Text("\(s.weekDoneMinutes)/\(s.weekTargetMinutes) min")
                .font(.caption2).foregroundStyle(.secondary)
        }
    }

    private var medium: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Label("Today", systemImage: s.todayType.widgetGlyph)
                    .font(.caption2.weight(.semibold)).foregroundStyle(.secondary)
                Text(s.todayType == .rest ? "Rest" : s.todayType.widgetTitle).font(.title3.weight(.semibold))
                if s.todayType != .rest {
                    Text("\(s.todayMinutes) min").font(.subheadline).foregroundStyle(.secondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                Text("This week").font(.caption2.weight(.semibold)).foregroundStyle(.secondary)
                Text("\(s.weekDoneMinutes)/\(s.weekTargetMinutes)")
                    .font(.title3.weight(.bold)).monospacedDigit()
                Text("minutes").font(.caption2).foregroundStyle(.secondary)
                ProgressView(value: s.weekFraction).tint(.accentColor).frame(width: 96)
            }
        }
    }

    private var lockRectangular: some View {
        VStack(alignment: .leading, spacing: 2) {
            Label(todayLine, systemImage: s.todayType.widgetGlyph)
                .font(.headline)
            Text("Week \(s.weekDoneMinutes)/\(s.weekTargetMinutes) min")
                .font(.caption2).foregroundStyle(.secondary)
        }
    }

    private var lockCircular: some View {
        Gauge(value: s.weekFraction) {
            Image(systemName: s.todayType.widgetGlyph)
        } currentValueLabel: {
            Text("\(Int(s.weekFraction * 100))")
        }
        .gaugeStyle(.accessoryCircularCapacity)
    }
}
