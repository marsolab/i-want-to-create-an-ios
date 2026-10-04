import Observation
import StoreKit
import WidgetKit

struct MembershipMessage: Identifiable {
    let title: String
    let detail: String
    var id: String { title }
}

@MainActor
@Observable
final class MembershipStore {
    private(set) var products: [Product] = []
    private(set) var verifiedMembership: WidgetMembershipSnapshot?
    private(set) var hasCheckedEntitlements = false
    private(set) var isRefreshingAccess = false
    private(set) var isBusy = false
    var message: MembershipMessage?
    @ObservationIgnored private var accessRefreshTask: Task<Void, Never>?
    @ObservationIgnored private var needsAnotherAccessRefresh = false
    @ObservationIgnored private var expirationTask: Task<Void, Never>?
    @ObservationIgnored private let widgetMembershipStore: WidgetMembershipStore
    @ObservationIgnored private let verifiedMembershipLoader: @MainActor (Date) async -> WidgetMembershipSnapshot?

    init(
        widgetMembershipStore: WidgetMembershipStore = WidgetMembershipStore(),
        verifiedMembershipLoader: @escaping @MainActor (Date) async -> WidgetMembershipSnapshot? =
            MembershipStore.loadVerifiedStoreKitMembership
    ) {
        self.widgetMembershipStore = widgetMembershipStore
        self.verifiedMembershipLoader = verifiedMembershipLoader
    }

    var hasAccess: Bool {
        verifiedMembership?.allowsAccess(at: Date()) == true
    }

    deinit {
        expirationTask?.cancel()
    }

    /// Called synchronously before dispatching an activation or URL refresh.
    func beginAccessRefresh() {
        needsAnotherAccessRefresh = true
        isRefreshingAccess = true
    }

    func price(for plan: MembershipPlan) -> String {
        product(for: plan)?.displayPrice ?? plan.previewPrice
    }

    func monthlyPrice(for plan: MembershipPlan) -> String {
        guard plan == .yearly else { return price(for: plan) }
        guard let product = product(for: plan) else { return "$2.99" }
        return (product.price / 12).formatted(product.priceFormatStyle)
    }

    var yearlyIsBestValue: Bool {
        guard let yearly = product(for: .yearly), let monthly = product(for: .monthly) else {
            return true
        }
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
        beginAccessRefresh()
        if let task = accessRefreshTask {
            await task.value
            return
        }
        let task = Task { [weak self] in
            guard let self else { return }
            await self.performAccessRefresh()
        }
        accessRefreshTask = task
        await task.value
    }

    private func performAccessRefresh() async {
        repeat {
            needsAnotherAccessRefresh = false
            let candidate = await verifiedMembershipLoader(Date())
            // Requests arriving during enumeration need one fresh pass. All
            // callers await this same task, including purchase and restore.
            if needsAnotherAccessRefresh { continue }
            let snapshot = candidate.flatMap { $0.allowsAccess(at: Date()) ? $0 : nil }
            verifiedMembership = snapshot
            hasCheckedEntitlements = true
            scheduleExpiration()
            if widgetMembershipStore.write(snapshot) {
                WidgetCenter.shared.reloadTimelines(ofKind: WidgetMembershipStore.widgetKind)
            }
        } while needsAnotherAccessRefresh
        accessRefreshTask = nil
        isRefreshingAccess = false
    }

    private static func loadVerifiedStoreKitMembership(at now: Date) async -> WidgetMembershipSnapshot? {
        var snapshot: WidgetMembershipSnapshot?
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result,
                MembershipPlan.allCases.contains(where: { $0.productID == transaction.productID }),
                transaction.revocationDate == nil,
                let expiration = transaction.expirationDate,
                expiration > now
            else { continue }
            if snapshot == nil || expiration > snapshot!.expirationDate {
                snapshot = WidgetMembershipSnapshot(
                    productID: transaction.productID,
                    expirationDate: expiration,
                    verifiedAt: now
                )
            }
        }
        return snapshot
    }

    private func scheduleExpiration() {
        expirationTask?.cancel()
        guard let expiration = verifiedMembership?.expirationDate else { return }
        expirationTask = Task { [weak self] in
            do {
                try await Task.sleep(for: .seconds(max(0, expiration.timeIntervalSinceNow)))
            } catch { return }
            guard let self, self.verifiedMembership?.expirationDate == expiration else { return }
            self.verifiedMembership = nil
            if self.widgetMembershipStore.write(nil) {
                WidgetCenter.shared.reloadTimelines(ofKind: WidgetMembershipStore.widgetKind)
            }
        }
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
        do {
            products = try await Product.products(for: MembershipPlan.allCases.map(\.productID))
                .filter { $0.type == .autoRenewable }
        } catch {
            // Keep the design preview available when StoreKit products are not configured.
            // subscribe(to:) never grants access or reports success without a verified purchase.
        }
    }
}
