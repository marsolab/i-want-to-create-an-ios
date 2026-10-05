import XCTest

@testable import PrayerFocus

final class FocusPolicyTests: XCTestCase {
    private let now = ISO8601DateFormatter().date(from: "2026-10-05T12:00:00Z")!
    private var membership: WidgetMembershipSnapshot {
        .init(
            productID: "com.marsolab.PrayerFocus.monthly", expirationDate: now.addingTimeInterval(7 * 86_400),
            verifiedAt: now.addingTimeInterval(-60))
    }
    private var configuration: FocusScheduleConfiguration {
        .init(
            city: "Dubai", method: "Dubai", hanafiAsr: false, adjustments: [:],
            enabledPrayers: Set(Prayer.allCases.map(\.rawValue)))
    }
    private var state: SharedFocusState {
        .init(
            configuration: configuration, selection: Data(),
            windows: [
                .init(
                    id: "first", prayer: "dhuhr", start: now.addingTimeInterval(-1800),
                    end: now.addingTimeInterval(1800)),
                .init(
                    id: "next", prayer: "asr", start: now.addingTimeInterval(1800), end: now.addingTimeInterval(5400)),
            ],
            generatedAt: now.addingTimeInterval(-1800), validUntil: now.addingTimeInterval(5400))
    }
    private func active(_ value: SharedFocusState?, at instant: Date? = nil) -> FocusWindow? {
        FocusPolicy.activeWindow(state: value, membership: membership, authorized: true, at: instant ?? now)
    }

    func testReleaseAndRepeatedBoundaryNeverReapplySamePrayer() {
        var value = state
        XCTAssertEqual(active(value)?.id, "first")
        value.releasedEventIDs.insert("first")
        for _ in 0..<3 { XCTAssertNil(active(value)) }
        XCTAssertEqual(active(value, at: now.addingTimeInterval(1800))?.id, "next")
    }

    func testDisabledNextPrayerClearsPreviousAtBoundary() {
        var value = state
        value.configuration = .init(
            city: "Dubai", method: "Dubai", hanafiAsr: false, adjustments: [:], enabledPrayers: ["dhuhr"])
        XCTAssertNotNil(active(value))
        XCTAssertNil(active(value, at: now.addingTimeInterval(1800)))
    }

    func testPauseAndExpiryRestoreExpectedPolicy() {
        var value = state
        value.pauseUntil = now.addingTimeInterval(600)
        XCTAssertNil(active(value))
        XCTAssertNotNil(active(value, at: now.addingTimeInterval(600)))
        value.pauseUntil = nil
        XCTAssertNotNil(active(value))
    }

    func testMissingExpiredMalformedMembershipAndPermissionLossFailOpen() {
        XCTAssertNil(FocusPolicy.activeWindow(state: state, membership: nil, authorized: true, at: now))
        XCTAssertNil(FocusPolicy.activeWindow(state: state, membership: membership, authorized: false, at: now))
        for snapshot in [
            WidgetMembershipSnapshot(
                productID: "unknown", expirationDate: membership.expirationDate, verifiedAt: membership.verifiedAt),
            WidgetMembershipSnapshot(
                productID: membership.productID, expirationDate: now, verifiedAt: membership.verifiedAt),
            WidgetMembershipSnapshot(
                productID: membership.productID, expirationDate: membership.expirationDate,
                verifiedAt: now.addingTimeInterval(1)),
        ] {
            XCTAssertNil(FocusPolicy.activeWindow(state: state, membership: snapshot, authorized: true, at: now))
        }
    }

    func testStaleFutureMalformedAndTooShortSchedulesFailOpen() {
        XCTAssertNil(active(nil))
        var value = state
        value.validUntil = now
        XCTAssertNil(active(value))
        value = state
        value.generatedAt = now.addingTimeInterval(1)
        XCTAssertNil(active(value))
        value = state
        value.version = 2
        XCTAssertNil(active(value))
        value = state
        value.windows = [value.windows[0], value.windows[0]]
        XCTAssertNil(active(value))
        value = state
        value.windows = [
            .init(id: "short", prayer: "dhuhr", start: now.addingTimeInterval(-60), end: now.addingTimeInterval(60))
        ]
        XCTAssertNil(active(value))
        value = state
        value.validUntil = now.addingTimeInterval(10 * 86_400)
        XCTAssertNil(active(value))
    }

    func testRollingWindowsAreBoundedAndStopAtMembershipExpiry() {
        let windows = FocusPolicy.windows(configuration: configuration, membership: membership, at: now)
        XCTAssertFalse(windows.isEmpty)
        XCTAssertLessThan(windows.count, 20)
        XCTAssertEqual(Set(windows.map(\.id)).count, windows.count)
        XCTAssertTrue(windows.allSatisfy { $0.end > now && $0.end <= membership.expirationDate })
        let short = WidgetMembershipSnapshot(
            productID: membership.productID, expirationDate: now.addingTimeInterval(600),
            verifiedAt: membership.verifiedAt)
        XCTAssertTrue(
            FocusPolicy.windows(configuration: configuration, membership: short, at: now).allSatisfy {
                $0.end <= short.expirationDate
            })
    }

    func testInvalidScheduleDoesNotKeepPreviousWindows() {
        let invalid = FocusScheduleConfiguration(
            city: "Unknown", method: "Dubai", hanafiAsr: false, adjustments: [:], enabledPrayers: ["dhuhr"])
        XCTAssertTrue(FocusPolicy.windows(configuration: invalid, membership: membership, at: now).isEmpty)
    }

    func testSharedStateTransactionsDoNotLoseConcurrentReleases() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = FocusStateStore(directory: directory)
        XCTAssertTrue(store.transaction { $0 = state })
        await withTaskGroup(of: Void.self) { group in
            for index in 0..<30 {
                group.addTask { _ = store.transaction { $0?.releasedEventIDs.insert("\(index)") } }
            }
        }
        XCTAssertTrue(store.transaction { XCTAssertEqual($0?.releasedEventIDs.count, 30) })
        let url = directory.appendingPathComponent("focus-state-v1.json")
        try Data("malformed".utf8).write(to: url)
        XCTAssertTrue(store.transaction { XCTAssertNil($0) })
    }
}
