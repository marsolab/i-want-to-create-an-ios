import Foundation

struct AffirmationEntry: Equatable, Sendable {
    let date: Date
    let affirmation: DailyAffirmation?
}

enum AffirmationTimeline {
    static func entries(
        from now: Date,
        timeZone: TimeZone = .current,
        membership: WidgetMembershipSnapshot?
    ) -> [AffirmationEntry] {
        let calendar = DailyAffirmationCatalog.calendar(timeZone: timeZone)
        let startOfDay = calendar.startOfDay(for: now)
        var dates = [now]
        for day in 1...7 {
            if let boundary = calendar.date(byAdding: .day, value: day, to: startOfDay) {
                dates.append(boundary)
            }
        }

        // Reject future-dated or already-expired snapshots for the entire timeline.
        let active = membership.flatMap { $0.allowsAccess(at: now) ? $0 : nil }
        if let active {
            dates.append(active.expirationDate)
        }

        return Set(dates).sorted().map { date in
            AffirmationEntry(
                date: date,
                affirmation: active?.allowsAccess(at: date) == true
                    ? DailyAffirmationCatalog.affirmation(on: date, timeZone: timeZone) : nil
            )
        }
    }

    static func reloadDate(from now: Date, timeZone: TimeZone = .current) -> Date {
        let calendar = DailyAffirmationCatalog.calendar(timeZone: timeZone)
        return calendar.date(byAdding: .day, value: 7, to: calendar.startOfDay(for: now))!
    }
}
