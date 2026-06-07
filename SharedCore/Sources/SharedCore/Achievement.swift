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
            title: "First 4×4",
            detail: "Completed your first Norwegian 4×4 session.",
            systemImage: "bolt.heart.fill"
        ),
        Achievement(
            id: "ten-sessions",
            title: "10 Sessions",
            detail: "Logged 10 workouts.",
            systemImage: "checklist"
        ),
        Achievement(
            id: "three-week-streak",
            title: "3-Week Streak",
            detail: "Trained at least once a week for 3 weeks running.",
            systemImage: "flame.fill"
        ),
        Achievement(
            id: "weekly-target-4x",
            title: "Consistent Month",
            detail: "Hit your weekly training target 4 weeks.",
            systemImage: "calendar.badge.checkmark"
        ),
        Achievement(
            id: "vo2max-up",
            title: "Fitter",
            detail: "Your VO2max is up since you started.",
            systemImage: "lungs.fill"
        ),
    ]
}
