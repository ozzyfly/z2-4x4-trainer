import Foundation
import SwiftData

/// A tombstone for a deleted workout, keyed by its Apple Health UUID. Kept so a
/// workout the user deleted isn't silently re-imported from Apple Health (or
/// re-synced from the watch) on the next refresh.
@Model
final class DeletedWorkout {
    @Attribute(.unique) var healthUUID: String
    var deletedAt: Date

    init(healthUUID: String, deletedAt: Date = .now) {
        self.healthUUID = healthUUID
        self.deletedAt = deletedAt
    }
}
