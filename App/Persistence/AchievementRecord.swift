import Foundation
import SwiftData

/// Records that an `Achievement` (by its catalog `id`) has been unlocked, and when.
/// Persisting the unlock lets the UI distinguish *newly* unlocked badges from
/// previously celebrated ones across launches.
@Model
final class AchievementRecord {
    /// The `Achievement.id` from `Achievement.catalog`.
    var id: String
    /// When the achievement was first unlocked.
    var unlockedDate: Date

    init(id: String, unlockedDate: Date = .now) {
        self.id = id
        self.unlockedDate = unlockedDate
    }
}
