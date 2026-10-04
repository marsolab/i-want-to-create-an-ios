import XCTest

@testable import PrayerFocus

@MainActor
final class MembershipRefreshTests: XCTestCase {
    func testConcurrentRefreshCallersWaitForTheFreshEntitlementResult() async throws {
        let suite = "MembershipRefreshTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let entered = RefreshBarrier()
        let release = RefreshBarrier()
        var loads = 0
        let membership = MembershipStore(widgetMembershipStore: WidgetMembershipStore(defaults: defaults)) { now in
            loads += 1
            if loads == 1 {
                entered.open()
                await release.wait()
                return nil
            }
            return WidgetMembershipSnapshot(
                productID: "com.marsolab.PrayerFocus.yearly",
                expirationDate: now.addingTimeInterval(3600), verifiedAt: now
            )
        }
        var firstCallerAccess: Bool?
        var secondCallerAccess: Bool?
        let first = Task {
            await membership.refreshAccess()
            firstCallerAccess = membership.hasAccess
        }
        await entered.wait()
        membership.beginAccessRefresh()
        let second = Task {
            await membership.refreshAccess()
            secondCallerAccess = membership.hasAccess
        }
        await Task.yield()
        release.open()
        await first.value
        await second.value
        XCTAssertTrue(firstCallerAccess == true)
        XCTAssertTrue(secondCallerAccess == true)
        XCTAssertGreaterThanOrEqual(loads, 2)
        XCTAssertFalse(membership.isRefreshingAccess)
        XCTAssertTrue(membership.hasCheckedEntitlements)
        XCTAssertEqual(WidgetMembershipStore(defaults: defaults).read(), membership.verifiedMembership)
    }

    func testExpirationClearsAppAndWidgetStateWithoutAnotherRefresh() async throws {
        let suite = "MembershipExpirationTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = WidgetMembershipStore(defaults: defaults)
        let membership = MembershipStore(widgetMembershipStore: store) { now in
            WidgetMembershipSnapshot(
                productID: "com.marsolab.PrayerFocus.monthly",
                expirationDate: now.addingTimeInterval(0.1), verifiedAt: now
            )
        }
        await membership.refreshAccess()
        XCTAssertTrue(membership.hasAccess)
        XCTAssertNotNil(store.read())
        let destination = AffirmationDestination()
        destination.request()
        membership.beginAccessRefresh()
        XCTAssertFalse(
            destination.consumeIfAllowed(
                hasAccess: membership.hasAccess,
                hasCheckedEntitlements: membership.hasCheckedEntitlements && !membership.isRefreshingAccess
            ))
        try await Task.sleep(for: .milliseconds(250))
        XCTAssertFalse(membership.hasAccess)
        XCTAssertNil(membership.verifiedMembership)
        XCTAssertNil(store.read())
        XCTAssertTrue(destination.hasPendingRequest)
    }
}

@MainActor
private final class RefreshBarrier {
    private var isOpen = false
    private var waiters: [CheckedContinuation<Void, Never>] = []

    func wait() async {
        guard !isOpen else { return }
        await withCheckedContinuation { waiters.append($0) }
    }

    func open() {
        isOpen = true
        for waiter in waiters { waiter.resume() }
        waiters.removeAll()
    }
}
