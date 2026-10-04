import XCTest

@testable import PrayerFocus

final class DailyAffirmationTests: XCTestCase {
    private let utc = TimeZone(secondsFromGMT: 0)!

    func testCatalogHasThirtyUniqueCompleteOriginalReflections() {
        let all = DailyAffirmationCatalog.all
        XCTAssertEqual(all.count, 30)
        XCTAssertEqual(Set(all.map(\.id)).count, 30)
        XCTAssertEqual(Set(all.map(\.text)).count, 30)
        XCTAssertTrue(all.allSatisfy { !$0.theme.isEmpty && !$0.text.isEmpty })
    }

    func testSelectionIsStableWithinDayAndWrapsAfterThirtyDays() {
        let start = date(2026, 1, 1)
        let calendar = DailyAffirmationCatalog.calendar(timeZone: utc)
        let morning = start.addingTimeInterval(8 * 3600)
        let evening = start.addingTimeInterval(23 * 3600)
        XCTAssertEqual(affirmation(morning), DailyAffirmationCatalog.all[0])
        XCTAssertEqual(affirmation(morning), affirmation(evening))
        XCTAssertEqual(affirmation(date(2026, 1, 2)), DailyAffirmationCatalog.all[1])
        XCTAssertEqual(affirmation(calendar.date(byAdding: .day, value: 30, to: start)!), affirmation(start))
    }

    func testDateBeforeAnchorUsesPositiveCycleIndex() {
        XCTAssertEqual(affirmation(date(2025, 12, 31)), DailyAffirmationCatalog.all[29])
    }

    func testLeapDayAdvancesOneItemPerCalendarDay() {
        let before = affirmation(date(2028, 2, 28)).id
        let leap = affirmation(date(2028, 2, 29)).id
        let after = affirmation(date(2028, 3, 1)).id
        XCTAssertEqual(leap, (before + 1) % 30)
        XCTAssertEqual(after, (leap + 1) % 30)
    }

    func testDSTUsesCalendarDaysAcrossShortAndLongDays() {
        let zone = TimeZone(identifier: "America/New_York")!
        let calendar = DailyAffirmationCatalog.calendar(timeZone: zone)
        for (month, day, hours) in [(3, 8, 23), (11, 1, 25)] {
            let start = calendar.date(from: DateComponents(year: 2026, month: month, day: day))!
            let next = calendar.date(byAdding: .day, value: 1, to: start)!
            XCTAssertEqual(next.timeIntervalSince(start), Double(hours * 3600))
            let first = DailyAffirmationCatalog.affirmation(on: start, timeZone: zone)
            let second = DailyAffirmationCatalog.affirmation(on: next, timeZone: zone)
            XCTAssertEqual(second.id, (first.id + 1) % 30)
        }
    }

    func testSelectionFollowsLocalDayWhenTimeZoneChanges() {
        let instant = date(2026, 1, 2)
        let dubai = TimeZone(identifier: "Asia/Dubai")!
        let losAngeles = TimeZone(identifier: "America/Los_Angeles")!
        XCTAssertEqual(DailyAffirmationCatalog.affirmation(on: instant, timeZone: dubai).id, 1)
        XCTAssertEqual(DailyAffirmationCatalog.affirmation(on: instant, timeZone: losAngeles).id, 0)
    }

    private func affirmation(_ date: Date) -> DailyAffirmation {
        DailyAffirmationCatalog.affirmation(on: date, timeZone: utc)
    }

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        DailyAffirmationCatalog.calendar(timeZone: utc)
            .date(from: DateComponents(year: year, month: month, day: day))!
    }
}
