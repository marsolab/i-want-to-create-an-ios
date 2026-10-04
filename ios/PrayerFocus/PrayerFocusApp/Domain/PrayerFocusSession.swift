import Foundation
import Observation

@MainActor
@Observable
final class PrayerFocusSession {
    private(set) var currentPrayer: Prayer
    private(set) var phase: PrayerSessionPhase
    var focusEnabled: [Prayer: Bool] {
        didSet {
            defaults?.set(
                Dictionary(uniqueKeysWithValues: focusEnabled.map { ($0.key.rawValue, $0.value) }),
                forKey: "focus.enabledPrayers"
            )
        }
    }
    private let defaults: UserDefaults?

    init(
        currentPrayer: Prayer = .dhuhr,
        phase: PrayerSessionPhase = .ready,
        focusEnabled: [Prayer: Bool]? = nil,
        defaults: UserDefaults? = nil
    ) {
        self.currentPrayer = currentPrayer
        self.phase = phase
        self.defaults = defaults
        let savedFocus = defaults?.dictionary(forKey: "focus.enabledPrayers") as? [String: Bool]
        self.focusEnabled =
            focusEnabled
            ?? Dictionary(
                uniqueKeysWithValues: Prayer.allCases.map { ($0, savedFocus?[$0.rawValue] ?? true) }
            )
    }

    var primaryActionTitle: String {
        switch phase {
        case .ready: "Start prayer"
        case .inProgress: "Finish prayer"
        case .checkedIn: "Prayer checked in"
        case .unlocked: "Start prayer"
        }
    }

    var canPerformPrimaryAction: Bool {
        phase != .checkedIn
    }

    func performPrimaryAction() {
        switch phase {
        case .ready, .unlocked:
            phase = .inProgress
        case .inProgress:
            phase = .checkedIn
        case .checkedIn:
            break
        }
    }

    func markAlreadyPrayed() {
        phase = .checkedIn
    }

    func unlockWithoutCheckIn() {
        phase = .unlocked
    }

    func reset(for prayer: Prayer) {
        currentPrayer = prayer
        phase = .ready
    }

    func isFocusEnabled(for prayer: Prayer) -> Bool {
        focusEnabled[prayer, default: true]
    }
}
