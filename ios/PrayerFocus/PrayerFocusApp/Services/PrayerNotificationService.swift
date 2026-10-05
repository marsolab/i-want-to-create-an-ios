import Foundation
import UserNotifications

@MainActor
enum PrayerNotificationPlan {
    static func entries(configuration: FocusConfiguration, from now: Date) -> [PrayerScheduleEntry] {
        guard let location = PrayerLocation.supported.first(where: { $0.name == configuration.city }),
            let zone = TimeZone(identifier: location.timeZoneID)
        else { return [] }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = zone
        return (0..<7).flatMap { offset -> [PrayerScheduleEntry] in
            guard let day = calendar.date(byAdding: .day, value: offset, to: now) else { return [] }
            return PrayerScheduleCalculator.calculate(
                city: configuration.city, method: configuration.calculationMethod,
                hanafiAsr: configuration.hanafiAsr, highLatitudeRule: configuration.highLatitudeRule,
                adjustments: configuration.adjustments, on: day
            )?.entries.filter { $0.date > now } ?? []
        }
    }
}

@MainActor
final class PrayerNotificationService {
    private let center = UNUserNotificationCenter.current()
    private let prefix = "salahside.prayer."
    private var updateTask: Task<Void, Never>?

    func update(configuration: FocusConfiguration, membership: WidgetMembershipSnapshot?) async {
        let now = Date()
        let entries =
            membership?.allowsAccess(at: now) == true
                && configuration.hasCompletedSetup && configuration.canCompleteSetup
                && configuration.notificationsEnabled
            ? PrayerNotificationPlan.entries(configuration: configuration, from: now)
                .filter { $0.date < membership!.expirationDate } : []
        // Serialize replacement so an older asynchronous update cannot reinstall reminders
        // after a newer preference change or loss of membership access.
        let previous = updateTask
        let task = Task { @MainActor in
            await previous?.value
            await replaceRequests(with: entries)
        }
        updateTask = task
        await task.value
    }

    private func replaceRequests(with entries: [PrayerScheduleEntry]) async {
        let pending = await center.pendingNotificationRequests()
        center.removePendingNotificationRequests(
            withIdentifiers: pending.map(\.identifier).filter { $0.hasPrefix(prefix) })
        guard !entries.isEmpty else { return }
        let settings = await center.notificationSettings()
        if settings.authorizationStatus == .notDetermined {
            guard (try? await center.requestAuthorization(options: [.alert, .sound])) == true else { return }
        } else if settings.authorizationStatus != .authorized && settings.authorizationStatus != .provisional {
            return
        }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        for entry in entries where entry.date > Date() {
            let content = UNMutableNotificationContent()
            content.title = "Time for \(entry.prayer.displayName)"
            content.body = "Make space for salah."
            content.sound = .default
            var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: entry.date)
            components.calendar = calendar
            components.timeZone = calendar.timeZone
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            try? await center.add(
                UNNotificationRequest(identifier: prefix + entry.id, content: content, trigger: trigger))
        }
    }
}
