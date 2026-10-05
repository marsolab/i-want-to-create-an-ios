import ManagedSettings

final class PrayerFocusShieldAction: ShieldActionDelegate {
    override func handle(
        action: ShieldAction, for application: ApplicationToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        respond(to: action, completion: completionHandler)
    }
    override func handle(
        action: ShieldAction, for category: ActivityCategoryToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        respond(to: action, completion: completionHandler)
    }
    override func handle(
        action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        respond(to: action, completion: completionHandler)
    }
    private func respond(to action: ShieldAction, completion: (ShieldActionResponse) -> Void) {
        if #available(iOS 26.5, *), action == .primaryButtonPressed {
            completion(.openParentalControlsApp)
        } else {
            completion(.close)
        }
    }
}
