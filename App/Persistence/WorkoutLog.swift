import Foundation
import SwiftData
import SharedCore

/// A completed workout, entered manually or (later) imported from Apple Health.
@Model
final class WorkoutLog {
    var date: Date
    var typeRaw: String
    var durationMin: Int
    var activeEnergyKcal: Int?
    var note: String?

    init(
        date: Date = .now,
        type: SessionType,
        durationMin: Int,
        activeEnergyKcal: Int? = nil,
        note: String? = nil
    ) {
        self.date = date
        self.typeRaw = type.rawValue
        self.durationMin = durationMin
        self.activeEnergyKcal = activeEnergyKcal
        self.note = note
    }

    var type: SessionType {
        get { SessionType(rawValue: typeRaw) ?? .zone2 }
        set { typeRaw = newValue.rawValue }
    }
}
