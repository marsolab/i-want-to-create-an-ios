import XCTest

@MainActor
func completePrayerFocusSetup(in app: XCUIApplication) {
    XCTAssertTrue(app.buttons["setup.continue"].waitForExistence(timeout: 15))
    app.buttons["setup.city"].tap()
    app.buttons["Dubai"].tap()
    app.buttons["setup.calculationMethod"].tap()
    app.buttons["Muslim World League"].tap()
    app.buttons["setup.continue"].tap()
    XCTAssertTrue(app.buttons["membership.subscribe"].waitForExistence(timeout: 10))
}
