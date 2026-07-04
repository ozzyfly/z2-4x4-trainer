import Foundation

/// Transport payload for a completed workout sent from the Watch to the iPhone over
/// WatchConnectivity. Encodes to a property-list dictionary suitable for `WCSession` userInfo.
public struct WorkoutTransfer: Codable, Sendable, Equatable {
    public let healthUUID: String
    public let date: Date
    public let typeRaw: String
    public let durationMin: Int
    public let energyKcal: Int?
    /// 4×4 session quality (0…100), or nil for unstructured/legacy sessions.
    public let qualityScore: Int?
    /// 4×4 detail: peak HR, average hard-effort HR, fully-completed reps (nil otherwise).
    public let peakHR: Int?
    public let avgHardHR: Int?
    public let repsCompleted: Int?
    /// Zone 2 detail: average in-zone HR and total session seconds (nil otherwise).
    public let avgHR: Int?
    public let totalSec: Int?

    public init(healthUUID: String, date: Date, type: SessionType,
                durationMin: Int, energyKcal: Int? = nil, qualityScore: Int? = nil,
                peakHR: Int? = nil, avgHardHR: Int? = nil, repsCompleted: Int? = nil,
                avgHR: Int? = nil, totalSec: Int? = nil) {
        self.healthUUID = healthUUID
        self.date = date
        self.typeRaw = type.rawValue
        self.durationMin = durationMin
        self.energyKcal = energyKcal
        self.qualityScore = qualityScore
        self.peakHR = peakHR
        self.avgHardHR = avgHardHR
        self.repsCompleted = repsCompleted
        self.avgHR = avgHR
        self.totalSec = totalSec
    }

    public var type: SessionType { SessionType(rawValue: typeRaw) ?? .zone2 }

    // MARK: - WCSession userInfo bridging (plist-safe types only)

    private enum Key {
        static let uuid = "healthUUID"
        static let date = "date"
        static let type = "typeRaw"
        static let duration = "durationMin"
        static let energy = "energyKcal"
        static let quality = "qualityScore"
        static let peak = "peakHR"
        static let avgHard = "avgHardHR"
        static let reps = "repsCompleted"
        static let avg = "avgHR"
        static let total = "totalSec"
    }

    public func toUserInfo() -> [String: Any] {
        var dict: [String: Any] = [
            Key.uuid: healthUUID,
            Key.date: date.timeIntervalSince1970,
            Key.type: typeRaw,
            Key.duration: durationMin,
        ]
        if let energyKcal { dict[Key.energy] = energyKcal }
        if let qualityScore { dict[Key.quality] = qualityScore }
        if let peakHR { dict[Key.peak] = peakHR }
        if let avgHardHR { dict[Key.avgHard] = avgHardHR }
        if let repsCompleted { dict[Key.reps] = repsCompleted }
        if let avgHR { dict[Key.avg] = avgHR }
        if let totalSec { dict[Key.total] = totalSec }
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
        self.qualityScore = userInfo[Key.quality] as? Int
        self.peakHR = userInfo[Key.peak] as? Int
        self.avgHardHR = userInfo[Key.avgHard] as? Int
        self.repsCompleted = userInfo[Key.reps] as? Int
        self.avgHR = userInfo[Key.avg] as? Int
        self.totalSec = userInfo[Key.total] as? Int
    }
}

/// Keys we stamp onto the `HKWorkout` we save, so a workout imported back from
/// Apple Health can recover which kind of session it was (4×4 vs Zone 2).
public enum WorkoutMetadata {
    public static let sessionTypeKey = "Z24SessionType"
}

/// Decides whether an incoming transfer is new, so the phone never stores a workout twice.
public enum WorkoutSyncDedupe {
    public static func shouldInsert(_ transfer: WorkoutTransfer,
                                    existingHealthUUIDs: Set<String>) -> Bool {
        !existingHealthUUIDs.contains(transfer.healthUUID)
    }
}
