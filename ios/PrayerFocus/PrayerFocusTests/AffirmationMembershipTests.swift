import StoreKitTest
import XCTest

@testable import PrayerFocus

final class AffirmationMembershipTests: XCTestCase {
    private var storeKitSession: SKTestSession!

    override func setUpWithError() throws {
        let url = try XCTUnwrap(
            Bundle(for: Self.self).url(forResource: "PrayerFocusWidgetsTesting", withExtension: "storekit"))
        storeKitSession = try SKTestSession(contentsOf: url)
        storeKitSession.resetToDefaultState()
        storeKitSession.clearTransactions()
        storeKitSession.disableDialogs = true
        storeKitSession.timeRate = .realTime
    }

    override func tearDownWithError() throws {
        storeKitSession.clearTransactions()
    }

    @MainActor
    func testVerifiedEntitlementPublishesSnapshotAndRefreshDefersDestination() async throws {
        let membership = MembershipStore()
        await membership.refreshAccess()
        XCTAssertFalse(membership.hasAccess)
        _ = try await storeKitSession.buyProduct(identifier: "com.marsolab.PrayerFocus.monthly")
        await membership.refreshAccess()
        XCTAssertTrue(membership.hasAccess)
        let snapshot = try XCTUnwrap(WidgetMembershipStore().read())
        XCTAssertEqual(snapshot.productID, "com.marsolab.PrayerFocus.monthly")
        XCTAssertTrue(snapshot.allowsAccess(at: Date()))
        XCTAssertEqual(WidgetMembershipSnapshot.productIDs, Set(MembershipPlan.allCases.map(\.productID)))

        let destination = AffirmationDestination()
        destination.request()
        membership.beginAccessRefresh()
        XCTAssertTrue(membership.isRefreshingAccess)
        XCTAssertFalse(
            destination.consumeIfAllowed(
                hasAccess: membership.hasAccess,
                hasCheckedEntitlements: membership.hasCheckedEntitlements && !membership.isRefreshingAccess
            ))
        await membership.refreshAccess()
        XCTAssertTrue(
            destination.consumeIfAllowed(
                hasAccess: membership.hasAccess,
                hasCheckedEntitlements: membership.hasCheckedEntitlements && !membership.isRefreshingAccess
            ))
        try storeKitSession.expireSubscription(productIdentifier: "com.marsolab.PrayerFocus.monthly")
        await membership.refreshAccess()
        XCTAssertFalse(membership.hasAccess)
        XCTAssertNil(WidgetMembershipStore().read())
    }

    @MainActor
    func testRecordedExpirationClearsAccessWithoutAStoreKitRefresh() async throws {
        storeKitSession.timeRate = .oneRenewalEveryTenSeconds
        let transaction = try await storeKitSession.buyProduct(identifier: "com.marsolab.PrayerFocus.monthly")
        try storeKitSession.disableAutoRenewForTransaction(identifier: UInt(transaction.id))
        let membership = MembershipStore()
        await membership.refreshAccess()
        XCTAssertTrue(membership.hasAccess)
        let snapshot = try XCTUnwrap(membership.verifiedMembership)
        let delay = snapshot.expirationDate.timeIntervalSinceNow + 0.25
        XCTAssertLessThan(delay, 12)
        try await Task.sleep(for: .seconds(max(0, delay)))
        XCTAssertFalse(membership.hasAccess)
        XCTAssertNil(membership.verifiedMembership)
        XCTAssertNil(WidgetMembershipStore().read())
    }
}
