import Foundation
import Observation

@MainActor
@Observable
final class AffirmationDestination {
    private(set) var hasPendingRequest = false

    @discardableResult
    func receive(_ url: URL) -> Bool {
        guard url.scheme?.lowercased() == "prayerfocus",
            url.host?.lowercased() == "daily-affirmation",
            url.path.isEmpty || url.path == "/",
            url.query == nil, url.fragment == nil,
            url.user == nil, url.password == nil, url.port == nil
        else { return false }
        request()
        return true
    }

    func request() {
        hasPendingRequest = true
    }

    @discardableResult
    func consumeIfAllowed(hasAccess: Bool, hasCheckedEntitlements: Bool) -> Bool {
        guard hasPendingRequest, hasAccess, hasCheckedEntitlements else { return false }
        hasPendingRequest = false
        return true
    }
}

enum AffirmationPresentation: String, Identifiable {
    case daily
    case settings
    var id: String { rawValue }
}
