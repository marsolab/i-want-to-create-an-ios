import Foundation

struct WidgetMembershipSnapshot: Codable, Equatable, Sendable {
    let productID: String
    let expirationDate: Date
    let verifiedAt: Date

    static let productIDs: Set<String> = [
        "com.marsolab.PrayerFocus.yearly",
        "com.marsolab.PrayerFocus.monthly",
    ]

    var isWellFormed: Bool {
        Self.productIDs.contains(productID)
            && expirationDate.timeIntervalSince1970.isFinite
            && verifiedAt.timeIntervalSince1970.isFinite
            && verifiedAt < expirationDate
    }

    func allowsAccess(at date: Date) -> Bool {
        isWellFormed && verifiedAt <= date && date < expirationDate
    }
}

struct WidgetMembershipStore {
    static let appGroupID = "group.com.marsolab.PrayerFocus"
    static let snapshotKey = "dailyAffirmation.verifiedMembership.v1"
    static let widgetKind = "DailyAffirmation"

    private let defaults: UserDefaults?

    init(defaults: UserDefaults? = sharedDefaults) {
        self.defaults = defaults
    }

    func read() -> WidgetMembershipSnapshot? {
        guard let data = defaults?.data(forKey: Self.snapshotKey),
            let snapshot = try? JSONDecoder().decode(WidgetMembershipSnapshot.self, from: data),
            snapshot.isWellFormed
        else { return nil }
        return snapshot
    }

    /// Returns true only when the shared stored value changes.
    @discardableResult
    func write(_ snapshot: WidgetMembershipSnapshot?) -> Bool {
        guard let defaults else { return false }
        let data = snapshot.flatMap { value in
            value.isWellFormed ? try? JSONEncoder().encode(value) : nil
        }
        if data != nil, read() == snapshot { return false }
        if data == nil, defaults.object(forKey: Self.snapshotKey) == nil { return false }

        if let data {
            defaults.set(data, forKey: Self.snapshotKey)
        } else {
            defaults.removeObject(forKey: Self.snapshotKey)
        }
        return true
    }

    private static var sharedDefaults: UserDefaults? {
        guard FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) != nil else {
            return nil
        }
        return UserDefaults(suiteName: appGroupID)
    }
}
