import WidgetKit
import SwiftUI
import SharedCore
import UIKit

// MARK: - Brand palette
//
// The widget extension doesn't link the app target, so the app's `Theme` hex
// pairs are mirrored here. Keep in sync with App/DesignSystem/Theme.swift.
private extension Color {
    private static func dynamic(light: UInt32, dark: UInt32) -> Color {
        Color(uiColor: UIColor { traits in
            let rgb = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(
                red: CGFloat((rgb >> 16) & 0xFF) / 255,
                green: CGFloat((rgb >> 8) & 0xFF) / 255,
                blue: CGFloat(rgb & 0xFF) / 255,
                alpha: 1
            )
        })
    }

    /// Hermès-style refined orange (Theme.accent).
    static let brandAccent = dynamic(light: 0xDD5A12, dark: 0xF2772E)
    /// Positive / ready (Theme.success).
    static let statusGo = dynamic(light: 0x1B7F3B, dark: 0x4ADE80)
    /// Neutral informational (Theme.info).
    static let statusSteady = dynamic(light: 0x1565C0, dark: 0x60A5FA)
    /// Caution / recover (Theme.warning).
    static let statusEasy = dynamic(light: 0xB45309, dark: 0xFBBF24)
}

// MARK: - Bundle

@main
struct Z24x4WidgetBundle: WidgetBundle {
    var body: some Widget {
        TodayWidget()
        StreakWidget()
        ReadinessWidget()
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
        case .zone2: return String(localized: "Zone 2")
        case .norwegian4x4: return String(localized: "4×4")
        case .rest: return String(localized: "Rest")
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
        s.todayType == .rest
            ? String(localized: "Rest day")
            : String(localized: "\(s.todayType.widgetTitle) · \(s.todayMinutes) min")
    }

    private var small: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Today", systemImage: s.todayType.widgetGlyph)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(s.todayType.widgetTitle)
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
                Text(s.todayType.widgetTitle).font(.title3.weight(.semibold))
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

// MARK: - Streak widget

struct StreakWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Z24x4Streak", provider: Provider()) { entry in
            StreakWidgetView(entry: entry)
                .widgetURL(URL(string: "z24x4://today"))
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Streak")
        .description("Your current weekly training streak.")
        .supportedFamilies([.systemSmall, .accessoryCircular, .accessoryInline])
    }
}

struct StreakWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: SnapshotEntry
    private var weeks: Int? { entry.snapshot.streakWeeks }

    var body: some View {
        switch family {
        case .accessoryCircular: circular
        case .accessoryInline: inline
        default: small
        }
    }

    private var small: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Streak", systemImage: (weeks ?? 0) > 0 ? "flame.fill" : "flame")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            Spacer(minLength: 0)
            if let weeks, weeks > 0 {
                Text("\(weeks)")
                    .font(.system(size: 40, weight: .semibold))
                    .monospacedDigit()
                    .foregroundStyle(Color.brandAccent)
                Text(weeks == 1 ? String(localized: "week") : String(localized: "weeks"))
                    .font(.subheadline).foregroundStyle(.secondary)
            } else {
                Text("—")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                Text("No streak yet")
                    .font(.subheadline).foregroundStyle(.secondary)
            }
        }
    }

    private var circular: some View {
        VStack(spacing: 1) {
            Image(systemName: (weeks ?? 0) > 0 ? "flame.fill" : "flame")
                .font(.title3)
            Text(weeks.map { "\($0)" } ?? "—")
                .font(.caption2.weight(.semibold)).monospacedDigit()
        }
    }

    private var inline: some View {
        Label {
            if let weeks, weeks > 0 {
                Text("\(weeks)-week streak")
            } else {
                Text("No streak yet")
            }
        } icon: {
            Image(systemName: "flame.fill")
        }
    }
}

// MARK: - Readiness widget

struct ReadinessWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Z24x4Readiness", provider: Provider()) { entry in
            ReadinessWidgetView(entry: entry)
                .widgetURL(URL(string: "z24x4://today"))
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Readiness")
        .description("Today's readiness score and recommendation.")
        .supportedFamilies([.systemSmall, .accessoryCircular, .accessoryRectangular])
    }
}

struct ReadinessWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: SnapshotEntry
    private var value: Int? { entry.snapshot.readinessValue }
    private var label: ReadinessLabel? { entry.snapshot.readinessLabel }

    var body: some View {
        switch family {
        case .accessoryCircular: circular
        case .accessoryRectangular: rectangular
        default: small
        }
    }

    private var small: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Readiness", systemImage: label?.widgetGlyph ?? "bolt.heart")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            Spacer(minLength: 0)
            if let value, let label {
                Text("\(value)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(label.widgetTint)
                Text(label.widgetTitle)
                    .font(.subheadline).foregroundStyle(.secondary)
            } else {
                Text("—")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                Text("No score yet")
                    .font(.subheadline).foregroundStyle(.secondary)
            }
        }
    }

    private var circular: some View {
        Gauge(value: Double(value ?? 0), in: 0...100) {
            Image(systemName: label?.widgetGlyph ?? "bolt.heart")
        } currentValueLabel: {
            Text(value.map { "\($0)" } ?? "—")
        }
        .gaugeStyle(.accessoryCircularCapacity)
    }

    private var rectangular: some View {
        VStack(alignment: .leading, spacing: 2) {
            Label("Readiness", systemImage: label?.widgetGlyph ?? "bolt.heart")
                .font(.headline)
            if let value, let label {
                Text("\(value) · \(label.widgetTitle)")
                    .font(.caption2).foregroundStyle(.secondary)
            } else {
                Text("No score yet")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
    }
}

private extension ReadinessLabel {
    var widgetTitle: String {
        switch self {
        case .goHard: return String(localized: "Go hard")
        case .steady: return String(localized: "Steady")
        case .easy:   return String(localized: "Take it easy")
        }
    }
    var widgetGlyph: String {
        switch self {
        case .goHard: return "bolt.fill"
        case .steady: return "equal.circle.fill"
        case .easy:   return "moon.fill"
        }
    }
    var widgetTint: Color {
        switch self {
        case .goHard: return .statusGo
        case .steady: return .statusSteady
        case .easy:   return .statusEasy
        }
    }
}
