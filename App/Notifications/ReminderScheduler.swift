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

    /// Removes existing reminders, then schedules one repeating reminder per
    /// non-rest plan day at the given time. No-op if authorization isn't granted.
    static func reschedule(plan: TrainingPlan, hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()

        Task {
            let settings = await center.notificationSettings()
            guard settings.authorizationStatus == .authorized
                || settings.authorizationStatus == .provisional else {
                // Permission not granted: ensure nothing is left scheduled.
                cancelAll()
                return
            }

            cancelAll()

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

                Task { try? await center.add(request) }
            }
        }
    }

    /// Removes every pending reminder request owned by this app.
    static func cancelAll() {
        let center = UNUserNotificationCenter.current()
        Task {
            let pending = await center.pendingNotificationRequests()
            let ids = pending
                .map(\.identifier)
                .filter { $0.hasPrefix(idPrefix) }
            center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }

    private static func label(for type: SessionType) -> String {
        switch type {
        case .zone2: return "Zone 2"
        case .norwegian4x4: return "Norwegian 4×4"
        case .rest: return "Rest"
        }
    }
}
