import StoreKit
import StoreKitTest
import XCTest

@testable import PrayerFocus

@MainActor
final class MembershipStoreTests: XCTestCase {
    private func testSession() async throws -> SKTestSession {
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "PrayerFocus", withExtension: "storekit"))
        let session = try SKTestSession(contentsOf: url)
        session.resetToDefaultState()
        session.clearTransactions()
        session.disableDialogs = true
        session.timeRate = .realTime
        try await AppStore.sync()
        return session
    }

    func testBothPlansOfferThreeDaysThenTheSelectedFullPrice() async throws {
        let session = try await testSession()
        defer { session.clearTransactions() }
        let store = MembershipStore()
        let updates = Task { await store.observeTransactions() }
        defer { updates.cancel() }
        await store.prepare()
        XCTAssertEqual(store.products.count, 2)
        for product in store.products {
            let subscription = try XCTUnwrap(product.subscription)
            let offer = try XCTUnwrap(subscription.introductoryOffer)
            XCTAssertEqual(offer.paymentMode, .freeTrial)
            XCTAssertEqual(offer.period.unit, .day)
            XCTAssertEqual(offer.period.value * offer.periodCount, 3)
            let isEligible = await subscription.isEligibleForIntroOffer
            XCTAssertTrue(isEligible)
        }
        XCTAssertFalse(store.hasAccess)
        XCTAssertTrue(store.hasThreeDayTrial(for: .monthly))
        XCTAssertTrue(store.hasThreeDayTrial(for: .yearly))
        XCTAssertEqual(store.billingDisclosure(for: .monthly), "3 days free, then $3.99/month.")
        XCTAssertEqual(store.billingDisclosure(for: .yearly), "3 days free, then $35.88/year.")
        if let equivalent = store.monthlyPrice(for: .yearly) {
            XCTAssertEqual(equivalent, "$2.99")
        }
    }

    func testVerifiedTrialUnlocksAndCannotBeUsedAgainAfterExpiration() async throws {
        let session = try await testSession()
        defer { session.clearTransactions() }
        let store = MembershipStore()
        let updates = Task { await store.observeTransactions() }
        defer { updates.cancel() }
        await store.prepare()
        await store.subscribe(to: .monthly)
        XCTAssertTrue(store.hasAccess)
        let transaction = try XCTUnwrap(session.allTransactions().first)
        let expiration = try XCTUnwrap(transaction.expirationDate)
        XCTAssertEqual(expiration.timeIntervalSince(transaction.purchaseDate), 3 * 24 * 60 * 60, accuracy: 10)

        try session.expireSubscription(productIdentifier: MembershipPlan.monthly.productID)
        // Refresh the receipt after changing expiration outside StoreKit's purchase flow.
        try await AppStore.sync()
        let deadline = ContinuousClock.now + .seconds(5)
        repeat {
            await store.refreshAccess()
            if !store.hasAccess { break }
            try await Task.sleep(for: .milliseconds(50))
        } while ContinuousClock.now < deadline
        let remainingEntitlement = await currentTransaction(for: .monthly)
        XCTAssertFalse(
            store.hasAccess,
            "Expired trial is still entitled: \(String(describing: remainingEntitlement)), test transactions: \(session.allTransactions())"
        )
        XCTAssertFalse(store.hasThreeDayTrial(for: .monthly))
        XCTAssertFalse(store.hasThreeDayTrial(for: .yearly))
        XCTAssertEqual(store.purchaseTitle(for: .yearly), "Subscribe")
        XCTAssertEqual(store.billingDisclosure(for: .yearly), "Billed $35.88/year.")
    }

    func testPendingPurchaseKeepsMembershipLocked() async throws {
        let session = try await testSession()
        defer { session.clearTransactions() }
        let store = MembershipStore(purchaseProduct: { _ in .pending })
        let updates = Task { await store.observeTransactions() }
        defer { updates.cancel() }
        await store.prepare()
        await store.subscribe(to: .yearly)
        XCTAssertFalse(store.hasAccess)
        XCTAssertEqual(store.message?.title, "Purchase pending")
    }

    func testCancelledPurchaseKeepsMembershipLocked() async throws {
        let session = try await testSession()
        defer { session.clearTransactions() }
        let store = MembershipStore(purchaseProduct: { _ in .userCancelled })
        let updates = Task { await store.observeTransactions() }
        defer { updates.cancel() }
        await store.prepare()
        XCTAssertEqual(store.products.count, 2)
        await store.subscribe(to: .monthly)
        XCTAssertFalse(store.hasAccess)
        XCTAssertTrue(session.allTransactions().isEmpty)
    }

    func testRestoreUnlocksAnActiveTrial() async throws {
        let session = try await testSession()
        defer { session.clearTransactions() }
        let store = MembershipStore()
        let updates = Task { await store.observeTransactions() }
        defer { updates.cancel() }
        await store.prepare()
        try await session.buyProduct(identifier: MembershipPlan.yearly.productID)
        await store.restore()
        XCTAssertTrue(store.hasAccess)
    }

    func testUnavailableProductsDoNotPromiseTrialOrUnlock() async throws {
        let session = try await testSession()
        defer { session.clearTransactions() }
        try await session.setSimulatedError(.generic(.unknown), forAPI: .loadProducts)
        let store = MembershipStore()
        let updates = Task { await store.observeTransactions() }
        defer { updates.cancel() }
        await store.prepare()
        XCTAssertTrue(store.products.isEmpty)
        XCTAssertFalse(store.hasThreeDayTrial(for: .yearly))
        await store.subscribe(to: .yearly)
        XCTAssertFalse(store.hasAccess)
        XCTAssertEqual(store.message?.title, "Subscription unavailable")
    }

    func testTrialRenewsAtFullPriceForMonthlyAndYearly() async throws {
        for plan in MembershipPlan.allCases {
            let session = try await testSession()
            defer { session.clearTransactions() }
            let store = MembershipStore()
            let updates = Task { await store.observeTransactions() }
            defer { updates.cancel() }
            await store.prepare()
            let trial = try await session.buyProduct(identifier: plan.productID)
            XCTAssertEqual(trial.offer?.paymentMode, .freeTrial)
            XCTAssertEqual(trial.price, 0)

            try session.forceRenewalOfSubscription(productIdentifier: plan.productID)
            try await AppStore.sync()
            var renewal: Transaction?
            let deadline = ContinuousClock.now + .seconds(5)
            repeat {
                let current = await currentTransaction(for: plan)
                if current?.id != trial.id {
                    renewal = current
                    break
                }
                try await Task.sleep(for: .milliseconds(50))
            } while ContinuousClock.now < deadline
            let paid = try XCTUnwrap(renewal)
            let product = try XCTUnwrap(store.products.first { $0.id == plan.productID })
            let paidPrice = try XCTUnwrap(paid.price)
            XCTAssertEqual(paidPrice.formatted(product.priceFormatStyle), store.price(for: plan))
            XCTAssertNil(paid.offer)
            let expiration = try XCTUnwrap(paid.expirationDate)
            let minimumPaidDays = plan == .monthly ? 28 : 365
            XCTAssertGreaterThanOrEqual(
                expiration.timeIntervalSince(paid.purchaseDate), Double(minimumPaidDays * 24 * 60 * 60)
            )
        }
    }

    private func currentTransaction(for plan: MembershipPlan) async -> Transaction? {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, transaction.productID == plan.productID {
                return transaction
            }
        }
        return nil
    }
}
