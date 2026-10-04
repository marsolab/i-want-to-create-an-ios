import Observation
import StoreKit

struct MembershipMessage: Identifiable {
    let title: String
    let detail: String
    var id: String { title }
}

@MainActor
@Observable
final class MembershipStore {
    private(set) var products: [Product] = []
    private(set) var hasAccess = false
    private(set) var hasCheckedEntitlements = false
    private(set) var isBusy = false
    private(set) var isLoadingProducts = true
    private var eligibleIntroProductIDs: Set<String> = []
    var message: MembershipMessage?

    func hasThreeDayTrial(for plan: MembershipPlan) -> Bool {
        guard eligibleIntroProductIDs.contains(plan.productID),
            let offer = product(for: plan)?.subscription?.introductoryOffer
        else { return false }
        return offer.paymentMode == .freeTrial
            && offer.period.unit == .day
            && offer.period.value * offer.periodCount == 3
    }

    func purchaseTitle(for plan: MembershipPlan) -> String {
        if isLoadingProducts { return "Loading plans…" }
        return hasThreeDayTrial(for: plan) ? "Start 3-day free trial" : "Subscribe"
    }

    func billingDisclosure(for plan: MembershipPlan) -> String {
        let charge = "\(price(for: plan))/\(plan.period)"
        return hasThreeDayTrial(for: plan) ? "3 days free, then \(charge)." : "Billed \(charge)."
    }

    func price(for plan: MembershipPlan) -> String {
        product(for: plan)?.displayPrice ?? plan.previewPrice
    }

    func monthlyPrice(for plan: MembershipPlan) -> String? {
        guard plan == .yearly else { return price(for: plan) }
        guard let product = product(for: plan) else { return "$2.99" }
        // Some StoreKit testing runtimes truncate the numeric price while retaining
        // the correct displayPrice. Never show an equivalent derived from that value.
        guard product.price.formatted(product.priceFormatStyle) == product.displayPrice else { return nil }
        return (product.price / 12).formatted(product.priceFormatStyle)
    }

    var yearlyIsBestValue: Bool {
        guard let yearly = product(for: .yearly), let monthly = product(for: .monthly) else {
            return true
        }
        guard yearly.price.formatted(yearly.priceFormatStyle) == yearly.displayPrice,
            monthly.price.formatted(monthly.priceFormatStyle) == monthly.displayPrice
        else { return false }
        return yearly.price < monthly.price * 12
    }

    func prepare() async {
        await refreshAccess()
        await loadProducts()
    }

    func observeTransactions() async {
        for await result in Transaction.updates {
            guard !Task.isCancelled else { return }
            guard case .verified(let transaction) = result else { continue }
            guard MembershipPlan.allCases.contains(where: { $0.productID == transaction.productID }) else {
                continue
            }
            await refreshAccess()
            await transaction.finish()
        }
    }

    func refreshAccess() async {
        var active = false
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result,
                MembershipPlan.allCases.contains(where: { $0.productID == transaction.productID }),
                transaction.revocationDate == nil,
                let expiration = transaction.expirationDate,
                expiration > Date()
            else { continue }
            active = true
        }
        hasAccess = active
        hasCheckedEntitlements = true
        await refreshIntroEligibility()
    }

    func subscribe(to plan: MembershipPlan) async {
        guard !isBusy else { return }
        isBusy = true
        defer { isBusy = false }

        if product(for: plan) == nil { await loadProducts() }
        guard let product = product(for: plan) else {
            message = MembershipMessage(
                title: "Subscription unavailable",
                detail: "Subscriptions aren’t available right now. Please try again later. No payment has been taken."
            )
            return
        }

        let displayedTrial = hasThreeDayTrial(for: plan)
        await refreshIntroEligibility()
        guard displayedTrial == hasThreeDayTrial(for: plan) else {
            message = MembershipMessage(
                title: "Membership offer updated",
                detail: "Please review the updated price and trial availability before continuing."
            )
            return
        }
        // Never describe a different introductory offer as immediate full-price billing.
        guard !eligibleIntroProductIDs.contains(plan.productID) || hasThreeDayTrial(for: plan) else {
            message = MembershipMessage(
                title: "Membership offer unavailable",
                detail: "This membership offer isn’t available right now. Please try again later."
            )
            return
        }

        do {
            switch try await product.purchase() {
            case .success(let verification):
                guard case .verified(let transaction) = verification else {
                    message = MembershipMessage(
                        title: "Purchase could not be verified",
                        detail: "Please try restoring your purchase before subscribing again."
                    )
                    return
                }
                await refreshAccess()
                await transaction.finish()
            case .pending:
                message = MembershipMessage(
                    title: "Purchase pending",
                    detail: "Your subscription will be available once Apple confirms your purchase."
                )
            case .userCancelled:
                break
            @unknown default:
                break
            }
        } catch is CancellationError {
            return
        } catch {
            message = MembershipMessage(
                title: "Couldn’t complete purchase",
                detail: "Please try again. If you already subscribed, restore your purchase."
            )
        }
    }

    func restore() async {
        guard !isBusy else { return }
        isBusy = true
        defer { isBusy = false }
        do {
            try await AppStore.sync()
            await refreshAccess()
            if !hasAccess {
                message = MembershipMessage(
                    title: "No subscription found",
                    detail: "Make sure you’re using the Apple Account you subscribed with."
                )
            }
        } catch is CancellationError {
            return
        } catch {
            message = MembershipMessage(
                title: "Couldn’t restore purchases",
                detail: "Please check your connection and try again."
            )
        }
    }

    private func product(for plan: MembershipPlan) -> Product? {
        products.first { $0.id == plan.productID }
    }

    private func loadProducts() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }
        do {
            products = try await Product.products(for: MembershipPlan.allCases.map(\.productID))
                .filter { $0.type == .autoRenewable }
            await refreshIntroEligibility()
        } catch {
            products = []
            eligibleIntroProductIDs = []
            // Keep the design preview available when StoreKit products are not configured.
            // subscribe(to:) never grants access or reports success without a verified purchase.
        }
    }

    private func refreshIntroEligibility() async {
        var eligible: Set<String> = []
        for product in products {
            guard let subscription = product.subscription,
                subscription.introductoryOffer != nil,
                await subscription.isEligibleForIntroOffer
            else { continue }
            eligible.insert(product.id)
        }
        eligibleIntroProductIDs = eligible
    }
}
