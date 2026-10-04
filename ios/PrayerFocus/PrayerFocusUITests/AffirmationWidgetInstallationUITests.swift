import XCTest

final class AffirmationWidgetInstallationUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDown() async throws {
        await MainActor.run { XCUIApplication().terminate() }
    }

    @MainActor
    func testHomeScreenWidgetCanBeAddedAndOpensMembership() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.buttons["membership.subscribe"].waitForExistence(timeout: 15))
        XCUIDevice.shared.press(.home)
        XCUIDevice.shared.press(.home)

        let home = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        home.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.55)).press(forDuration: 3)
        let edit = home.buttons["Edit"]
        let editAppeared = edit.waitForExistence(timeout: 5)
        if !editAppeared {
            let diagnostic = XCTAttachment(screenshot: home.screenshot())
            diagnostic.name = "Home Screen edit diagnostic"
            diagnostic.lifetime = .keepAlways
            add(diagnostic)
        }
        XCTAssertTrue(editAppeared, home.debugDescription)
        edit.tap()
        let addMenu = home.buttons["Add Widget"]
        XCTAssertTrue(addMenu.waitForExistence(timeout: 5))
        addMenu.tap()
        let search = home.searchFields.firstMatch
        XCTAssertTrue(search.waitForExistence(timeout: 10), home.debugDescription)
        search.tap()
        search.typeText("Prayer Focus")
        let result = home.collectionViews["add-sheet-collection-view"].cells["Prayer Focus"]
        XCTAssertTrue(result.waitForExistence(timeout: 15), home.debugDescription)
        result.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        let addWidget = home.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Add Widget")).firstMatch
        let galleryReady = addWidget.waitForExistence(timeout: 30)
        let gallery = XCTAttachment(screenshot: home.screenshot())
        gallery.name = "Native widget gallery"
        gallery.lifetime = .keepAlways
        add(gallery)
        XCTAssertTrue(galleryReady, home.debugDescription)
        addWidget.tap()
        let done = home.buttons["Done"]
        XCTAssertTrue(done.waitForExistence(timeout: 5))
        done.tap()

        let reflection = home.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS %@", "Open Prayer Focus to continue.")).firstMatch
        XCTAssertTrue(reflection.waitForExistence(timeout: 20))
        let installed = XCTAttachment(screenshot: home.screenshot())
        installed.name = "Installed Home Screen affirmation widget"
        installed.lifetime = .keepAlways
        add(installed)
        reflection.tap()
        XCTAssertTrue(app.buttons["membership.subscribe"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.navigationBars["Daily affirmation"].exists)
    }
}
