import XCTest

@testable import PrayerFocus

@MainActor
final class PrayerScheduleTests: XCTestCase {
    private func date(_ raw: String) -> Date { ISO8601DateFormatter().date(from: raw)! }
    private func configuration(defaults: UserDefaults? = nil) -> FocusConfiguration {
        let result = FocusConfiguration(defaults: defaults)
        result.city = "Dubai"
        result.calculationMethod = "Dubai"
        result.completeSetup()
        return result
    }

    func testSupportedMethodsAndSeasonalDatesHaveFiveOrderedPrayers() throws {
        for city in PrayerLocation.supported {
            for method in FocusConfiguration.methods.dropFirst() {
                for raw in [
                    "2026-03-29T12:00:00Z", "2026-06-21T12:00:00Z", "2026-10-25T12:00:00Z", "2026-12-21T12:00:00Z",
                ] {
                    let schedule = try XCTUnwrap(
                        PrayerScheduleCalculator.calculate(city: city.name, method: method, on: date(raw)),
                        "\(city.name), \(method), \(raw)")
                    XCTAssertEqual(schedule.entries.map(\.prayer), Prayer.allCases)
                    XCTAssertTrue(zip(schedule.entries, schedule.entries.dropFirst()).allSatisfy { $0.date < $1.date })
                    XCTAssertEqual(schedule.timeZoneID, city.timeZoneID)
                }
            }
        }
    }

    func testDayKeyUsesSelectedCityInsteadOfDeviceOrUTCDay() throws {
        let instant = date("2026-10-05T22:30:00Z")
        let dubai = try XCTUnwrap(PrayerScheduleCalculator.calculate(city: "Dubai", method: "Dubai", on: instant))
        let newYork = try XCTUnwrap(PrayerScheduleCalculator.calculate(city: "New York", method: "ISNA", on: instant))
        XCTAssertEqual(dubai.entries.first?.dayKey, "2026-10-06")
        XCTAssertEqual(newYork.entries.first?.dayKey, "2026-10-05")
    }

    func testHanafiOnlyChangesAsrAndManualAdjustmentMovesChosenPrayer() throws {
        let instant = date("2026-10-05T12:00:00Z")
        let standard = try XCTUnwrap(PrayerScheduleCalculator.calculate(city: "Dubai", method: "Dubai", on: instant))
        let hanafi = try XCTUnwrap(
            PrayerScheduleCalculator.calculate(
                city: "Dubai", method: "Dubai", hanafiAsr: true, adjustments: ["isha": 30], on: instant))
        for index in [0, 1, 3] { XCTAssertEqual(standard.entries[index].date, hanafi.entries[index].date) }
        XCTAssertGreaterThan(hanafi.entries[2].date, standard.entries[2].date)
        XCTAssertEqual(hanafi.entries[4].date.timeIntervalSince(standard.entries[4].date), 1800, accuracy: 1)
    }

    func testInvalidSelectionsAndOverlappingAdjustmentsRejectSchedule() {
        XCTAssertNil(PrayerScheduleCalculator.calculate(city: "Select city", method: "Dubai"))
        XCTAssertNil(PrayerScheduleCalculator.calculate(city: "Dubai", method: "Select method"))
        XCTAssertNil(PrayerScheduleCalculator.calculate(city: "Dubai", method: "Dubai", highLatitudeRule: "Unknown"))
        XCTAssertNil(
            PrayerScheduleCalculator.calculate(
                city: "Dubai", method: "Dubai", on: Date(timeIntervalSince1970: .infinity)))
        XCTAssertNil(
            PrayerScheduleCalculator.calculate(
                city: "Dubai", method: "Dubai", adjustments: ["maghrib": 120, "isha": -120],
                on: date("2026-10-05T12:00:00Z")))
    }

    func testSessionDoesNotInferEarlierCheckInsAndPersistsOnlyUserActions() throws {
        let suite = "PrayerScheduleTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let config = configuration(defaults: defaults)
        let schedule = try XCTUnwrap(
            PrayerScheduleCalculator.calculate(city: "Dubai", method: "Dubai", on: date("2026-10-05T12:00:00Z")))
        let instant = schedule.entries[2].date.addingTimeInterval(60)
        let session = PrayerFocusSession(defaults: defaults)
        session.refresh(configuration: config, at: instant)
        XCTAssertEqual(session.currentPrayer, .asr)
        XCTAssertNil(session.recordedPhase(for: .fajr))
        XCTAssertNil(session.recordedPhase(for: .dhuhr))
        session.markAlreadyPrayed()
        let restored = PrayerFocusSession(defaults: defaults)
        restored.refresh(configuration: config, at: instant)
        XCTAssertEqual(restored.phase, .checkedIn)
        XCTAssertNil(restored.recordedPhase(for: .dhuhr))
        restored.refresh(configuration: config, at: schedule.entries[3].date)
        XCTAssertEqual(restored.phase, .ready)
        XCTAssertEqual(restored.recordedPhase(for: .asr), .checkedIn)
    }

    func testIshaRemainsCurrentAcrossMidnightUntilFajrWithoutCompletingTodaysIsha() {
        let session = PrayerFocusSession()
        let config = configuration()
        session.refresh(configuration: config, at: date("2026-10-05T22:30:00Z"))
        XCTAssertEqual(session.currentPrayer, .isha)
        XCTAssertEqual(session.currentEntry?.dayKey, "2026-10-05")
        XCTAssertEqual(session.schedule?.entries.last?.dayKey, "2026-10-06")
        session.markAlreadyPrayed()
        XCTAssertNil(session.recordedPhase(for: .isha))
    }

    func testUnlockIsReleasedAcrossRelaunchEvenAfterStartingPrayerAgain() throws {
        let suite = "PrayerScheduleTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let session = PrayerFocusSession(defaults: defaults)
        let config = configuration()
        session.refresh(configuration: config, at: date("2026-10-05T12:00:00Z"))
        let id = try XCTUnwrap(session.currentEventID)
        var released: [String] = []
        session.onRelease = { released.append($0) }
        session.unlockWithoutCheckIn()
        session.performPrimaryAction()
        XCTAssertEqual(released, [id])
        XCTAssertEqual(session.phase, .inProgress)
        XCTAssertTrue(PrayerFocusSession(defaults: defaults).releasedEventIDs.contains(id))
    }

    func testNotificationsContainOnlyFutureUniqueEntriesInSevenDayHorizon() {
        let now = date("2026-10-05T12:00:00Z")
        let entries = PrayerNotificationPlan.entries(configuration: configuration(), from: now)
        XCTAssertFalse(entries.isEmpty)
        XCTAssertLessThanOrEqual(entries.count, 35)
        XCTAssertEqual(Set(entries.map(\.id)).count, entries.count)
        XCTAssertTrue(entries.allSatisfy { $0.date > now && $0.date < now.addingTimeInterval(7 * 86_400) })
    }

    func testPrayerConventionsAndAdjustmentsPersistAndEraseClearsSetup() throws {
        let suite = "PrayerScheduleTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let config = configuration(defaults: defaults)
        config.hanafiAsr = true
        config.highLatitudeRule = "Twilight angle"
        config.adjustments = ["isha": 30]
        let restored = FocusConfiguration(defaults: defaults)
        XCTAssertTrue(restored.hanafiAsr)
        XCTAssertEqual(restored.highLatitudeRule, "Twilight angle")
        XCTAssertEqual(restored.adjustments, ["isha": 30])
        restored.eraseLocalSetup()
        XCTAssertFalse(FocusConfiguration(defaults: defaults).hasCompletedSetup)
        XCTAssertFalse(restored.canCompleteSetup)
    }
}
