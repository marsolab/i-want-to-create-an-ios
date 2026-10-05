import StoreKitTest
import XCTest

final class AffirmationMembershipUITests: XCTestCase {
    private var storeKitSession: SKTestSession!

    override func setUpWithError() throws {
        continueAfterFailure = false
        let url = try XCTUnwrap(
            Bundle(for: Self.self).url(forResource: "PrayerFocusWidgetsTesting", withExtension: "storekit"))
        storeKitSession = try SKTestSession(contentsOf: url)
        storeKitSession.resetToDefaultState()
        storeKitSession.clearTransactions()
        storeKitSession.disableDialogs = true
        storeKitSession.timeRate = .realTime
    }

    override func tearDown() async throws {
        await MainActor.run { XCUIApplication().terminate() }
        storeKitSession.clearTransactions()
    }

    @MainActor
    func testPurchaseResumesPendingWidgetDestination() {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing", "-reset-setup", "-open-affirmation"]
        app.launch()
        completePrayerFocusSetup(in: app)
        let subscribe = app.buttons["membership.subscribe"]
        XCTAssertTrue(subscribe.waitForExistence(timeout: 15))
        subscribe.tap()
        XCTAssertTrue(app.navigationBars["Daily affirmation"].waitForExistence(timeout: 15))
        XCTAssertTrue(app.staticTexts["An original reflection"].exists)
        app.buttons["Done"].tap()
        XCTAssertTrue(app.buttons["today.settings"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testActiveWidgetURLReplacesSettingsAfterItsDismissal() async throws {
        let app = prepareSetup()
        _ = try await storeKitSession.buyProduct(identifier: "com.marsolab.PrayerFocus.yearly")
        app.launch()
        let settings = app.buttons["today.settings"]
        XCTAssertTrue(settings.waitForExistence(timeout: 15))
        settings.tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))
        app.open(URL(string: "prayerfocus://daily-affirmation")!)
        XCTAssertTrue(app.navigationBars["Daily affirmation"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["An original reflection"].exists)
        XCTAssertFalse(app.navigationBars["Settings"].exists)
        app.buttons["Done"].tap()
        XCTAssertTrue(settings.waitForExistence(timeout: 5))
    }

    @MainActor
    func testExpirationDismissesAffirmationAndLocksWarmWidgetURL() async throws {
        let app = prepareSetup()
        storeKitSession.timeRate = .oneRenewalEveryThirtySeconds
        let transaction = try await storeKitSession.buyProduct(identifier: "com.marsolab.PrayerFocus.monthly")
        try storeKitSession.disableAutoRenewForTransaction(identifier: UInt(transaction.id))
        app.launch()
        XCTAssertTrue(app.buttons["today.settings"].waitForExistence(timeout: 15))
        app.open(URL(string: "prayerfocus://daily-affirmation")!)
        XCTAssertTrue(app.navigationBars["Daily affirmation"].waitForExistence(timeout: 10))
        // Observe actual recorded expiration rather than a forced receipt edit;
        // the app must dismiss member content and reopen its locked paywall.
        XCTAssertTrue(app.buttons["membership.subscribe"].waitForExistence(timeout: 45))
        XCTAssertFalse(app.staticTexts["An original reflection"].exists)
        XCUIDevice.shared.press(.home)
        app.open(URL(string: "prayerfocus://daily-affirmation")!)
        XCTAssertTrue(app.buttons["membership.subscribe"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.navigationBars["Daily affirmation"].exists)
    }

    @MainActor
    private func prepareSetup() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing", "-reset-setup"]
        app.launch()
        completePrayerFocusSetup(in: app)
        app.terminate()
        app.launchArguments = ["-ui-testing"]
        return app
    }

}
