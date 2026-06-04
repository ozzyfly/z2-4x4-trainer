import Foundation

/// Transport payload for a completed workout sent from the Watch to the iPhone over
/// WatchConnectivity. Encodes to a property-list dictionary suitable for `WCSession` userInfo.
public struct WorkoutTransfer: Codable, Sendable, Equatable {
    public let healthUUID: String
    public let date: Date
    public let typeRaw: String
    public let durationMin: Int
    public let energyKcal: Int?

    public init(healthUUID: String, date: Date, type: SessionType,
                durationMin: Int, energyKcal: Int? = nil) {
        self.healthUUID = healthUUID
        self.date = date
        self.typeRaw = type.rawValue
        self.durationMin = durationMin
        self.energyKcal = energyKcal
    }

    public var type: SessionType { SessionType(rawValue: typeRaw) ?? .zone2 }

    // MARK: - WCSession userInfo bridging (plist-safe types only)

    private enum Key {
        static let uuid = "healthUUID"
        static let date = "date"
        static let type = "typeRaw"
        static let duration = "durationMin"
        static let energy = "energyKcal"
    }

    public func toUserInfo() -> [String: Any] {
        var dict: [String: Any] = [
            Key.uuid: healthUUID,
            Key.date: date.timeIntervalSince1970,
            Key.type: typeRaw,
            Key.duration: durationMin,
        ]
        if let energyKcal { dict[Key.energy] = energyKcal }
        return dict
    }

    public init?(userInfo: [String: Any]) {
        guard let healthUUID = userInfo[Key.uuid] as? String,
              let ts = userInfo[Key.date] as? Double,
              let typeRaw = userInfo[Key.type] as? String,
              let durationMin = userInfo[Key.duration] as? Int else { return nil }
        self.healthUUID = healthUUID
        self.date = Date(timeIntervalSince1970: ts)
        self.typeRaw = typeRaw
        self.durationMin = durationMin
        self.energyKcal = userInfo[Key.energy] as? Int
    }
}

/// Decides whether an incoming transfer is new, so the phone never stores a workout twice.
public enum WorkoutSyncDedupe {
    public static func shouldInsert(_ transfer: WorkoutTransfer,
                                    existingHealthUUIDs: Set<String>) -> Bool {
        !existingHealthUUIDs.contains(transfer.healthUUID)
    }
}
