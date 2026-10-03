import XCTest

@testable import PrayerFocus

@MainActor
final class PrayerFocusSessionTests: XCTestCase {
    func testFocusIsEnabledForAllFivePrayersByDefault() {
        let session = PrayerFocusSession()

        XCTAssertTrue(Prayer.allCases.allSatisfy(session.isFocusEnabled(for:)))
    }

    func testPrimaryActionStartsAndThenFinishesPrayer() {
        let session = PrayerFocusSession()

        session.performPrimaryAction()
        XCTAssertEqual(session.phase, .inProgress)

        session.performPrimaryAction()
        XCTAssertEqual(session.phase, .checkedIn)
    }

    func testAlreadyPrayedRecordsCheckInWithoutStart() {
        let session = PrayerFocusSession()

        session.markAlreadyPrayed()

        XCTAssertEqual(session.phase, .checkedIn)
    }

    func testUnlockDoesNotRecordCompletion() {
        let session = PrayerFocusSession()

        session.unlockWithoutCheckIn()

        XCTAssertEqual(session.phase, .unlocked)
        XCTAssertEqual(session.primaryActionTitle, "Start prayer")
    }

    func testNextPrayerResetsTransientState() {
        let session = PrayerFocusSession(currentPrayer: .dhuhr)
        session.markAlreadyPrayed()

        session.reset(for: .asr)

        XCTAssertEqual(session.currentPrayer, .asr)
        XCTAssertEqual(session.phase, .ready)
    }

    func testPrayerFocusCanBeDisabledIndependently() {
        let session = PrayerFocusSession()

        session.focusEnabled[.fajr] = false

        XCTAssertFalse(session.isFocusEnabled(for: .fajr))
        XCTAssertTrue(session.isFocusEnabled(for: .dhuhr))
        XCTAssertEqual(Prayer.allCases.count, 5)
    }
}
