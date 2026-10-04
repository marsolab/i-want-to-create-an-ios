import XCTest

@testable import PrayerFocus

@MainActor
final class AffirmationDestinationTests: XCTestCase {
    func testRequestSurvivesCheckingAndPaywallThenIsConsumedOnce() throws {
        let destination = AffirmationDestination()
        let url = try XCTUnwrap(URL(string: "prayerfocus://daily-affirmation"))
        XCTAssertTrue(destination.receive(url))
        XCTAssertFalse(destination.consumeIfAllowed(hasAccess: true, hasCheckedEntitlements: false))
        XCTAssertTrue(destination.hasPendingRequest)
        XCTAssertFalse(destination.consumeIfAllowed(hasAccess: false, hasCheckedEntitlements: true))
        XCTAssertTrue(destination.hasPendingRequest)
        XCTAssertTrue(destination.consumeIfAllowed(hasAccess: true, hasCheckedEntitlements: true))
        XCTAssertFalse(destination.hasPendingRequest)
        XCTAssertFalse(destination.consumeIfAllowed(hasAccess: true, hasCheckedEntitlements: true))
    }

    func testUnknownURLsCannotOpenOrEraseThePendingDestination() throws {
        let destination = AffirmationDestination()
        let invalid = [
            "https://daily-affirmation", "prayerfocus://other", "prayerfocus://daily-affirmation/other",
            "prayerfocus://daily-affirmation?access=true", "prayerfocus://daily-affirmation#preview",
            "prayerfocus://user@daily-affirmation", "prayerfocus://daily-affirmation:80",
        ]
        for raw in invalid {
            XCTAssertFalse(destination.receive(try XCTUnwrap(URL(string: raw))))
            XCTAssertFalse(destination.hasPendingRequest)
        }
        destination.request()
        XCTAssertFalse(destination.receive(try XCTUnwrap(URL(string: "prayerfocus://other"))))
        XCTAssertTrue(destination.hasPendingRequest)
    }
}
