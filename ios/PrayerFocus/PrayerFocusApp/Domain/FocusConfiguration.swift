import Foundation
import Observation

@MainActor
@Observable
final class FocusConfiguration {
    static let cities = ["Select city", "London", "New York", "Toronto", "Dubai", "Kuala Lumpur"]
    static let methods = [
        "Select method", "Muslim World League", "ISNA", "Umm al-Qura", "Egyptian Authority", "Dubai",
        "Moonsighting Committee", "Singapore",
    ]

    static let highLatitudeRules = ["Recommended for city", "Middle of night", "Seventh of night", "Twilight angle"]

    var highLatitudeRule: String {
        didSet { defaults?.set(highLatitudeRule, forKey: "focus.highLatitudeRule") }
    }
    var city: String {
        didSet { defaults?.set(city, forKey: "focus.city") }
    }
    var calculationMethod: String {
        didSet { defaults?.set(calculationMethod, forKey: "focus.calculationMethod") }
    }
    var notificationsEnabled: Bool {
        didSet { defaults?.set(notificationsEnabled, forKey: "focus.notificationsEnabled") }
    }
    var hanafiAsr: Bool {
        didSet { defaults?.set(hanafiAsr, forKey: "focus.hanafiAsr") }
    }
    var adjustments: [String: Int] {
        didSet { defaults?.set(adjustments, forKey: "focus.adjustments") }
    }
    private(set) var hasCompletedSetup = false
    private let defaults: UserDefaults?

    init(defaults: UserDefaults? = nil) {
        self.defaults = defaults
        highLatitudeRule = defaults?.string(forKey: "focus.highLatitudeRule") ?? Self.highLatitudeRules[0]
        city = defaults?.string(forKey: "focus.city") ?? Self.cities[0]
        calculationMethod = defaults?.string(forKey: "focus.calculationMethod") ?? Self.methods[0]
        notificationsEnabled = defaults?.object(forKey: "focus.notificationsEnabled") as? Bool ?? true
        hanafiAsr = defaults?.bool(forKey: "focus.hanafiAsr") ?? false
        adjustments = defaults?.dictionary(forKey: "focus.adjustments") as? [String: Int] ?? [:]
        hasCompletedSetup =
            defaults?.bool(forKey: "focus.hasCompletedSetup") == true
            && Self.cities.dropFirst().contains(city)
            && Self.methods.dropFirst().contains(calculationMethod)
    }

    var canCompleteSetup: Bool {
        Self.cities.dropFirst().contains(city) && Self.methods.dropFirst().contains(calculationMethod)
    }

    func eraseLocalSetup() {
        city = Self.cities[0]
        calculationMethod = Self.methods[0]
        highLatitudeRule = Self.highLatitudeRules[0]
        hanafiAsr = false
        adjustments = [:]
        notificationsEnabled = true
        hasCompletedSetup = false
        defaults?.removeObject(forKey: "focus.hasCompletedSetup")
    }

    func completeSetup() {
        guard canCompleteSetup else { return }
        hasCompletedSetup = true
        defaults?.set(true, forKey: "focus.hasCompletedSetup")
    }
}
