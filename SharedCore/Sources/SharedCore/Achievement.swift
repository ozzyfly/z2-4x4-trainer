import Foundation

/// A single unlockable achievement. Pure metadata; evaluation lives in `AchievementEvaluator`.
public struct Achievement: Identifiable, Sendable, Equatable {
    public let id: String
    public let title: String
    public let detail: String
    /// SF Symbol name for display.
    public let systemImage: String

    public init(id: String, title: String, detail: String, systemImage: String) {
        self.id = id
        self.title = title
        self.detail = detail
        self.systemImage = systemImage
    }

    /// The fixed catalog of achievements the app evaluates.
    public static let catalog: [Achievement] = [
        Achievement(
            id: "first-4x4",
            title: String(localized: "First 4×4", bundle: .module),
            detail: String(localized: "Completed your first Norwegian 4×4 session.", bundle: .module),
            systemImage: "bolt.heart.fill"
        ),
        Achievement(
            id: "ten-sessions",
            title: String(localized: "10 Sessions", bundle: .module),
            detail: String(localized: "Logged 10 workouts.", bundle: .module),
            systemImage: "checklist"
        ),
        Achievement(
            id: "three-week-streak",
            title: String(localized: "3-Week Streak", bundle: .module),
            detail: String(localized: "Trained at least once a week for 3 weeks running.", bundle: .module),
            systemImage: "flame.fill"
        ),
        Achievement(
            id: "weekly-target-4x",
            title: String(localized: "Consistent Month", bundle: .module),
            detail: String(localized: "Hit your weekly training target 4 weeks.", bundle: .module),
            systemImage: "calendar.badge.checkmark"
        ),
        Achievement(
            id: "vo2max-up",
            title: String(localized: "Fitter", bundle: .module),
            detail: String(localized: "Your VO2max is up since you started.", bundle: .module),
            systemImage: "lungs.fill"
        ),
    ]
}
