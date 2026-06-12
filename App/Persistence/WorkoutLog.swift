import Foundation
import SwiftData
import SharedCore

/// Where a `WorkoutLog` came from. `healthUUID` can't say this on its own:
/// manual entries also gain a UUID once written back to Apple Health.
enum WorkoutSource: String {
    case manual
    case health
    case watch
}

/// A completed workout, entered manually or (later) imported from Apple Health.
@Model
final class WorkoutLog {
    var date: Date
    var typeRaw: String
    var durationMin: Int
    var activeEnergyKcal: Int?
    var note: String?
    /// Apple Health workout UUID when imported from HealthKit; nil for manual entries.
    var healthUUID: String?
    /// How the log was created. Defaults to manual for pre-existing records.
    var sourceRaw: String = WorkoutSource.manual.rawValue

    init(
        date: Date = .now,
        type: SessionType,
        durationMin: Int,
        activeEnergyKcal: Int? = nil,
        note: String? = nil,
        healthUUID: String? = nil,
        source: WorkoutSource = .manual
    ) {
        self.date = date
        self.typeRaw = type.rawValue
        self.durationMin = durationMin
        self.activeEnergyKcal = activeEnergyKcal
        self.note = note
        self.healthUUID = healthUUID
        self.sourceRaw = source.rawValue
    }

    var type: SessionType {
        get { SessionType(rawValue: typeRaw) ?? .zone2 }
        set { typeRaw = newValue.rawValue }
    }

    var source: WorkoutSource {
        get { WorkoutSource(rawValue: sourceRaw) ?? .manual }
        set { sourceRaw = newValue.rawValue }
    }
}
