import Foundation
import UserNotifications
import SharedCore

/// Schedules opt-in local notifications for plan training days.
///
/// Notifications are repeating weekly `UNCalendarNotificationTrigger`s, one per
/// non-rest day in the weekly plan, all fired at the same chosen time. Requests
/// are namespaced under a stable id prefix so the app can find and clear only
/// its own pending notifications.
@MainActor
enum ReminderScheduler {
    /// Result of a reschedule attempt, so callers can surface failures instead
    /// of silently doing nothing.
    enum Outcome: Equatable {
        /// All reminders were scheduled (`count` repeating requests).
        case scheduled(count: Int)
        /// Notification authorization is denied or not yet granted; nothing was scheduled.
        case notAuthorized
    }

    /// Stable id prefix for all reminder requests owned by this app.
    private static let idPrefix = "z24x4.reminder."

    /// Requests alert + sound authorization. Returns whether it was granted.
    static func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .sound])
        } catch {
            return false
        }
    }

    /// Current notification authorization status, for UI that needs to warn
    /// when reminders can't be delivered.
    static func authorizationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    /// Removes existing reminders, then schedules one repeating reminder per
    /// non-rest plan day at the given time. Reports the outcome: returns
    /// `.notAuthorized` when permission is missing (after clearing leftovers),
    /// and throws if the notification center rejects a request.
    @discardableResult
    static func reschedule(plan: TrainingPlan, hour: Int, minute: Int) async throws -> Outcome {
        let center = UNUserNotificationCenter.current()

        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized
            || settings.authorizationStatus == .provisional else {
            // Permission not granted: ensure nothing is left scheduled.
            await cancelAll()
            return .notAuthorized
        }

        await cancelAll()

        var count = 0
        for session in plan.sessions where session.type != .rest {
            var components = DateComponents()
            // Plan day 1 = Monday … 7 = Sunday →
            // DateComponents.weekday 1 = Sunday … 7 = Saturday.
            components.weekday = (session.day % 7) + 1
            components.hour = hour
            components.minute = minute

            let content = UNMutableNotificationContent()
            content.title = "Time to train 💪"
            content.body = "Today's session: \(label(for: session.type))"
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: components,
                repeats: true
            )

            let request = UNNotificationRequest(
                identifier: "\(idPrefix)\(session.day)",
                content: content,
                trigger: trigger
            )

            try await center.add(request)
            count += 1
        }
        return .scheduled(count: count)
    }

    /// Removes every pending reminder request owned by this app.
    static func cancelAll() async {
        let center = UNUserNotificationCenter.current()
        let pending = await center.pendingNotificationRequests()
        let ids = pending
            .map(\.identifier)
            .filter { $0.hasPrefix(idPrefix) }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    private static func label(for type: SessionType) -> String {
        switch type {
        case .zone2: return "Zone 2"
        case .norwegian4x4: return "Norwegian 4×4"
        case .rest: return "Rest"
        }
    }
}
