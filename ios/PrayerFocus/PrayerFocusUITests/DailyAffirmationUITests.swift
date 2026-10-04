import XCTest

final class DailyAffirmationUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testSettingsOpensDailyAffirmationAndWidgetGuide() {
        let app = XCUIApplication()
        app.launchArguments = ["-preview-today"]
        app.launch()
        let settings = app.buttons["today.settings"]
        XCTAssertTrue(settings.waitForExistence(timeout: 10))
        settings.tap()
        app.buttons["settings.dailyAffirmations"].tap()
        XCTAssertTrue(app.navigationBars["Daily affirmation"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["An original reflection"].exists)
        capture(app, name: "Daily affirmation from Settings")
    }

    @MainActor
    func testLongestReflectionAndAllThreePreviewFamilies() {
        let app = XCUIApplication()
        app.launchArguments = ["-preview-affirmation"]
        app.launch()
        XCTAssertTrue(
            app.staticTexts["I can feel grateful and acknowledge what is hard."].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["An original reflection"].exists)
        XCTAssertTrue(app.otherElements["affirmation.preview.small"].exists)
        capture(app, name: "Daily affirmation and small widget")
        app.swipeUp()
        XCTAssertTrue(app.otherElements["affirmation.preview.medium"].exists)
        XCTAssertTrue(app.otherElements["affirmation.preview.lockScreen"].exists)
        capture(app, name: "Medium and Lock Screen widgets")
        app.swipeUp()
        XCTAssertTrue(app.staticTexts["Add your widget"].exists)
    }

    @MainActor
    func testWidgetDestinationCannotBypassMembership() {
        let app = XCUIApplication()
        app.launchArguments = ["-open-affirmation"]
        app.launch()
        XCTAssertTrue(app.buttons["membership.subscribe"].waitForExistence(timeout: 15))
        XCTAssertFalse(app.staticTexts["An original reflection"].exists)
        XCTAssertFalse(app.navigationBars["Daily affirmation"].exists)
    }

    @MainActor
    private func capture(_ app: XCUIApplication, name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
