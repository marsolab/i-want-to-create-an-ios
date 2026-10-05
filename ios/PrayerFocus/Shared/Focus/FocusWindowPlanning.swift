import Foundation

extension FocusPolicy {
    static func windows(configuration: FocusScheduleConfiguration, membership: WidgetMembershipSnapshot?, at now: Date)
        -> [FocusWindow]
    {
        guard let membership, membership.allowsAccess(at: now),
            let location = PrayerLocation.supported.first(where: { $0.name == configuration.city }),
            let zone = TimeZone(identifier: location.timeZoneID)
        else { return [] }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = zone
        let days = (-1...3).map { offset -> [PrayerScheduleEntry] in
            guard let date = calendar.date(byAdding: .day, value: offset, to: now) else { return [] }
            return PrayerScheduleCalculator.calculate(
                city: configuration.city, method: configuration.method, hanafiAsr: configuration.hanafiAsr,
                highLatitudeRule: configuration.highLatitudeRule, adjustments: configuration.adjustments, on: date)?
                .entries ?? []
        }
        guard days.allSatisfy({ $0.count == 5 }) else { return [] }
        let entries = days.flatMap { $0 }
        // Include the previous Isha until today's Fajr, and every boundary even when
        // the next prayer has focus disabled. Fewer than 20 monitors are registered.
        return zip(entries, entries.dropFirst()).compactMap { entry, next in
            let end = min(next.date, membership.expirationDate)
            guard end > now, entry.date < calendar.date(byAdding: .day, value: 3, to: calendar.startOfDay(for: now))!,
                end.timeIntervalSince(entry.date) >= 15 * 60
            else { return nil }
            return FocusWindow(id: entry.id, prayer: entry.prayer.rawValue, start: entry.date, end: end)
        }
    }
}
