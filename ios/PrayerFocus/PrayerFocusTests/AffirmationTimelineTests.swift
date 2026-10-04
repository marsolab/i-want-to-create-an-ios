import XCTest

@testable import PrayerFocus

final class AffirmationTimelineTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_767_268_800)  // January 1, 2026, 12:00 UTC.
    private let utc = TimeZone(secondsFromGMT: 0)!

    func testMissingAndExpiredMembershipAlwaysProduceLockedEntries() {
        for membership in [nil, snapshot(expiration: now), snapshot(expiration: now.addingTimeInterval(-1))] {
            let entries = AffirmationTimeline.entries(from: now, timeZone: utc, membership: membership)
            XCTAssertEqual(entries.count, 8)
            XCTAssertTrue(entries.allSatisfy { $0.affirmation == nil })
        }
    }

    func testExpirationIsInsertedAndNoLaterEntryExposesContent() {
        let expiration = now.addingTimeInterval(3 * 3600)
        let entries = AffirmationTimeline.entries(
            from: now, timeZone: utc, membership: snapshot(expiration: expiration))
        XCTAssertEqual(entries.count, 9)
        XCTAssertEqual(entries.first?.date, now)
        XCTAssertNotNil(entries.first?.affirmation)
        XCTAssertTrue(entries.contains { $0.date == expiration && $0.affirmation == nil })
        XCTAssertTrue(entries.filter { $0.date >= expiration }.allSatisfy { $0.affirmation == nil })
        XCTAssertEqual(entries.map(\.date), entries.map(\.date).sorted())
    }

    func testMidnightExpirationDoesNotDuplicateBoundary() {
        let calendar = DailyAffirmationCatalog.calendar(timeZone: utc)
        let midnight = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now))!
        let entries = AffirmationTimeline.entries(from: now, timeZone: utc, membership: snapshot(expiration: midnight))
        XCTAssertEqual(entries.count, 8)
        XCTAssertEqual(entries.filter { $0.date == midnight }.count, 1)
        XCTAssertNil(entries.first { $0.date == midnight }?.affirmation)
    }

    func testFutureBoundariesRespectDSTAndUseTheCatalog() {
        let zone = TimeZone(identifier: "America/New_York")!
        let calendar = DailyAffirmationCatalog.calendar(timeZone: zone)
        let start = calendar.date(from: DateComponents(year: 2026, month: 3, day: 7, hour: 12))!
        let membership = WidgetMembershipSnapshot(
            productID: "com.marsolab.PrayerFocus.monthly",
            expirationDate: start.addingTimeInterval(20 * 86400),
            verifiedAt: start.addingTimeInterval(-60)
        )
        let entries = AffirmationTimeline.entries(from: start, timeZone: zone, membership: membership)
        XCTAssertEqual(entries.count, 9)
        XCTAssertEqual(entries[2].date.timeIntervalSince(entries[1].date), 23 * 3600)
        for entry in entries.prefix(8) {
            XCTAssertEqual(entry.affirmation, DailyAffirmationCatalog.affirmation(on: entry.date, timeZone: zone))
        }
        XCTAssertEqual(entries.last?.date, membership.expirationDate)
        XCTAssertNil(entries.last?.affirmation)
        XCTAssertEqual(AffirmationTimeline.reloadDate(from: start, timeZone: zone), entries[7].date)
    }

    func testInvalidProductAndInvalidDatesDoNotGrantAccess() {
        let expiration = now.addingTimeInterval(3600)
        let unknownProduct = WidgetMembershipSnapshot(
            productID: "unrecognized", expirationDate: expiration, verifiedAt: now)
        let futureVerification = WidgetMembershipSnapshot(
            productID: "com.marsolab.PrayerFocus.yearly", expirationDate: expiration,
            verifiedAt: now.addingTimeInterval(1)
        )
        let backwardsInterval = WidgetMembershipSnapshot(
            productID: "com.marsolab.PrayerFocus.yearly", expirationDate: now, verifiedAt: expiration
        )
        let invalidDate = WidgetMembershipSnapshot(
            productID: "com.marsolab.PrayerFocus.yearly",
            expirationDate: Date(timeIntervalSince1970: .infinity), verifiedAt: now
        )
        for membership in [unknownProduct, futureVerification, backwardsInterval, invalidDate] {
            XCTAssertFalse(membership.allowsAccess(at: now))
            XCTAssertTrue(
                AffirmationTimeline.entries(from: now, timeZone: utc, membership: membership)
                    .allSatisfy { $0.affirmation == nil }
            )
        }
    }

    func testMembershipStoreRoundTripCorruptionAndRevocation() throws {
        let suite = "PrayerFocusTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = WidgetMembershipStore(defaults: defaults)
        XCTAssertNil(store.read())
        let membership = snapshot(expiration: now.addingTimeInterval(3600))
        XCTAssertTrue(store.write(membership))
        XCTAssertEqual(store.read(), membership)
        XCTAssertFalse(store.write(membership))
        XCTAssertTrue(store.write(nil))
        XCTAssertNil(store.read())
        defaults.set(Data("broken JSON".utf8), forKey: WidgetMembershipStore.snapshotKey)
        XCTAssertNil(store.read())
        XCTAssertTrue(store.write(membership))
        XCTAssertEqual(store.read(), membership)
    }

    func testUnavailableAppGroupCannotPersistAccess() {
        let store = WidgetMembershipStore(defaults: nil)
        XCTAssertFalse(store.write(snapshot(expiration: now.addingTimeInterval(3600))))
        XCTAssertNil(store.read())
    }

    private func snapshot(expiration: Date) -> WidgetMembershipSnapshot {
        WidgetMembershipSnapshot(
            productID: "com.marsolab.PrayerFocus.yearly",
            expirationDate: expiration,
            verifiedAt: now.addingTimeInterval(-60)
        )
    }
}
