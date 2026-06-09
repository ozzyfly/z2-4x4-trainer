import Foundation

/// A small, codec-stable snapshot of the current training state, published by the
/// app to a shared App Group container so widgets can render without launching it.
public struct WidgetSnapshot: Codable, Sendable, Equatable {
    /// Today's planned session type.
    public let todayType: SessionType
    /// Today's planned duration in minutes (0 on a rest day).
    public let todayMinutes: Int
    /// This week's completed training minutes.
    public let weekDoneMinutes: Int
    /// This week's target training minutes.
    public let weekTargetMinutes: Int
    /// This week's completed hard (4×4) sessions.
    public let hardDone: Int
    /// This week's target hard (4×4) sessions.
    public let hardTarget: Int
    /// When this snapshot was produced.
    public let generatedAt: Date

    public init(
        todayType: SessionType,
        todayMinutes: Int,
        weekDoneMinutes: Int,
        weekTargetMinutes: Int,
        hardDone: Int,
        hardTarget: Int,
        generatedAt: Date
    ) {
        self.todayType = todayType
        self.todayMinutes = todayMinutes
        self.weekDoneMinutes = weekDoneMinutes
        self.weekTargetMinutes = weekTargetMinutes
        self.hardDone = hardDone
        self.hardTarget = hardTarget
        self.generatedAt = generatedAt
    }

    /// Fraction of the weekly minutes target completed, clamped to 0...1.
    public var weekFraction: Double {
        guard weekTargetMinutes > 0 else { return 0 }
        return min(Double(weekDoneMinutes) / Double(weekTargetMinutes), 1)
    }

    /// Placeholder shown before any snapshot exists or when the container is unavailable.
    public static let placeholder = WidgetSnapshot(
        todayType: .zone2,
        todayMinutes: 40,
        weekDoneMinutes: 90,
        weekTargetMinutes: 180,
        hardDone: 1,
        hardTarget: 2,
        generatedAt: Date(timeIntervalSince1970: 0)
    )
}

/// Reads and writes `WidgetSnapshot` in the shared App Group container.
/// All operations fail soft: if the container is unavailable (entitlement not
/// configured), reads return nil and writes are a no-op — never a crash.
public enum WidgetSnapshotStore {
    public static let appGroupID = "group.ca.logolo.z24x4"
    private static let filename = "widget-snapshot.json"

    private static var fileURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appendingPathComponent(filename)
    }

    public static func write(_ snapshot: WidgetSnapshot) {
        guard let fileURL, let data = try? JSONEncoder().encode(snapshot) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    public static func read() -> WidgetSnapshot? {
        guard let fileURL, let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    }
}
