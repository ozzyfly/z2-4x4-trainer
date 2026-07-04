import Foundation
import SwiftData

/// Legacy unlocked-achievement record. The Awards feature has been removed, but this
/// model is retained (and kept in the SwiftData schema) so existing installs migrate
/// cleanly rather than dropping an entity. Nothing writes to it anymore.
@Model
final class AchievementRecord {
    /// The achievement catalog id it recorded.
    var id: String
    /// When the achievement was first unlocked.
    var unlockedDate: Date

    init(id: String, unlockedDate: Date = .now) {
        self.id = id
        self.unlockedDate = unlockedDate
    }
}
