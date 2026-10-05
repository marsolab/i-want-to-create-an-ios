import FamilyControls
import XCTest

@testable import PrayerFocus

@MainActor
final class FocusConfigurationTests: XCTestCase {
    func testIncompleteSetupCannotAdvanceToMembership() {
        let configuration = FocusConfiguration()
        configuration.completeSetup()
        XCTAssertFalse(configuration.hasCompletedSetup)
        configuration.city = "Dubai"
        configuration.completeSetup()
        XCTAssertFalse(configuration.hasCompletedSetup)
        configuration.calculationMethod = "Muslim World League"
        configuration.completeSetup()
        XCTAssertTrue(configuration.hasCompletedSetup)
    }

    func testSetupChoicesAndCompletionSurviveRelaunch() throws {
        let suite = "FocusConfigurationTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let configuration = FocusConfiguration(defaults: defaults)
        configuration.city = "Dubai"
        configuration.calculationMethod = "Muslim World League"
        configuration.notificationsEnabled = false
        configuration.completeSetup()

        let restored = FocusConfiguration(defaults: defaults)
        XCTAssertEqual(restored.city, "Dubai")
        XCTAssertEqual(restored.calculationMethod, "Muslim World League")
        XCTAssertFalse(restored.notificationsEnabled)
        XCTAssertTrue(restored.hasCompletedSetup)
    }

    func testPrayerChoicesAndAppSelectionSurviveRelaunch() throws {
        let suite = "FocusConfigurationTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let session = PrayerFocusSession(defaults: defaults)
        session.focusEnabled[.fajr] = false
        let restored = PrayerFocusSession(defaults: defaults)
        XCTAssertFalse(restored.isFocusEnabled(for: .fajr))
        XCTAssertTrue(restored.isFocusEnabled(for: .dhuhr))

        let screenTime = ScreenTimeService(defaults: defaults)
        screenTime.selection = FamilyActivitySelection(includeEntireCategory: true)
        XCTAssertTrue(ScreenTimeService(defaults: defaults).selection.includeEntireCategory)
        screenTime.selection = FamilyActivitySelection()
        XCTAssertFalse(ScreenTimeService(defaults: defaults).selection.includeEntireCategory)
    }
}
