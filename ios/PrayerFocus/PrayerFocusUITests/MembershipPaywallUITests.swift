import XCTest

final class MembershipPaywallUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testPaidOfferAndPlanSwitch() {
        let app = XCUIApplication()
        app.launch()
        let yearly = app.buttons["membership.plan.yearly"]
        XCTAssertTrue(yearly.waitForExistence(timeout: 15))
        XCTAssertTrue(app.staticTexts["$2.99/month"].exists)
        XCTAssertTrue(app.staticTexts["Billed $35.88 yearly."].exists)
        XCTAssertFalse(app.buttons["Continue with free"].exists)

        app.buttons["membership.plan.monthly"].tap()
        XCTAssertTrue(app.staticTexts["Billed $3.99 monthly."].waitForExistence(timeout: 5))
        let monthlyCapture = XCTAttachment(screenshot: app.screenshot())
        monthlyCapture.name = "Membership monthly"
        monthlyCapture.lifetime = .keepAlways
        add(monthlyCapture)
        yearly.tap()
        XCTAssertTrue(app.staticTexts["Billed $35.88 yearly."].waitForExistence(timeout: 5))
        let yearlyCapture = XCTAttachment(screenshot: app.screenshot())
        yearlyCapture.name = "Membership yearly"
        yearlyCapture.lifetime = .keepAlways
        add(yearlyCapture)
    }

    @MainActor
    func testPaywallCannotBeDismissedWithoutSubscription() {
        let app = XCUIApplication()
        app.launch()
        let subscribe = app.buttons["membership.subscribe"]
        XCTAssertTrue(subscribe.waitForExistence(timeout: 15))
        XCTAssertFalse(app.buttons["membership.close"].exists)

        let topOfSheet = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.14))
        let bottomOfScreen = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.85))
        topOfSheet.press(forDuration: 0.1, thenDragTo: bottomOfScreen)

        XCTAssertTrue(subscribe.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Billed $35.88 yearly."].exists)
        XCTAssertFalse(app.buttons["Start prayer"].exists)
        let capture = XCTAttachment(screenshot: app.screenshot())
        capture.name = "Membership sheet after dismiss gesture"
        capture.lifetime = .keepAlways
        add(capture)
    }

    @MainActor
    func testPrivacyCanBeOpenedAndDismissed() {
        let app = XCUIApplication()
        app.launch()
        let privacy = app.buttons["Privacy"]
        XCTAssertTrue(privacy.waitForExistence(timeout: 15))
        privacy.tap()
        XCTAssertTrue(app.navigationBars["Privacy"].waitForExistence(timeout: 5))
        app.buttons["Done"].tap()
        XCTAssertTrue(app.buttons["membership.subscribe"].waitForExistence(timeout: 5))
    }
}
