import Foundation
import Observation

@MainActor
@Observable
final class FocusConfiguration {
    static let cities = ["Select city", "London", "New York", "Toronto", "Dubai", "Kuala Lumpur"]
    static let methods = ["Select method", "Muslim World League", "ISNA", "Umm al-Qura", "Egyptian Authority"]

    var city: String {
        didSet { defaults?.set(city, forKey: "focus.city") }
    }
    var calculationMethod: String {
        didSet { defaults?.set(calculationMethod, forKey: "focus.calculationMethod") }
    }
    var notificationsEnabled: Bool {
        didSet { defaults?.set(notificationsEnabled, forKey: "focus.notificationsEnabled") }
    }
    private(set) var hasCompletedSetup = false
    private let defaults: UserDefaults?

    init(defaults: UserDefaults? = nil) {
        self.defaults = defaults
        city = defaults?.string(forKey: "focus.city") ?? Self.cities[0]
        calculationMethod = defaults?.string(forKey: "focus.calculationMethod") ?? Self.methods[0]
        notificationsEnabled = defaults?.object(forKey: "focus.notificationsEnabled") as? Bool ?? true
        hasCompletedSetup =
            defaults?.bool(forKey: "focus.hasCompletedSetup") == true
            && Self.cities.dropFirst().contains(city)
            && Self.methods.dropFirst().contains(calculationMethod)
    }

    var canCompleteSetup: Bool {
        Self.cities.dropFirst().contains(city) && Self.methods.dropFirst().contains(calculationMethod)
    }

    func completeSetup() {
        guard canCompleteSetup else { return }
        hasCompletedSetup = true
        defaults?.set(true, forKey: "focus.hasCompletedSetup")
    }
}
