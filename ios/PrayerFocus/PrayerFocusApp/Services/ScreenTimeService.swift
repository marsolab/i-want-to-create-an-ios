import Combine
import FamilyControls
import Foundation
import Observation

@MainActor
@Observable
final class ScreenTimeService {
    var selection: FamilyActivitySelection {
        didSet {
            if let data = try? JSONEncoder().encode(selection) {
                defaults?.set(data, forKey: "focus.appSelection")
            }
        }
    }
    private(set) var lastError: String?
    private(set) var pauseUntil: Date?
    private(set) var authorizationStatus: AuthorizationStatus = .notDetermined
    @ObservationIgnored private var authorizationObservation: AnyCancellable?
    private let defaults: UserDefaults?

    init(defaults: UserDefaults? = nil) {
        self.defaults = defaults
        if let data = defaults?.data(forKey: "focus.appSelection"),
            let savedSelection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
        {
            selection = savedSelection
        } else {
            selection = FamilyActivitySelection()
        }
        authorizationStatus = AuthorizationCenter.shared.authorizationStatus
        authorizationObservation = AuthorizationCenter.shared.$authorizationStatus.sink { [weak self] status in
            Task { @MainActor in self?.authorizationStatus = status }
        }
    }

    var isAuthorized: Bool {
        if #available(iOS 26.4, *), authorizationStatus == .approvedWithDataAccess {
            return true
        }
        return authorizationStatus == .approved
    }

    var selectedItemCount: Int {
        selection.applicationTokens.count
            + selection.categoryTokens.count
            + selection.webDomainTokens.count
    }

    var authorizationLabel: String {
        switch authorizationStatus {
        case .notDetermined: "Not requested"
        case .denied: "Not allowed"
        case .approved, .approvedWithDataAccess: "Allowed"
        @unknown default: "Unavailable"
        }
    }

    func updateFocus(configuration: FocusConfiguration, session: PrayerFocusSession) {
        refreshPauseStatus()
        let focus = FocusScheduleConfiguration(
            city: configuration.city, method: configuration.calculationMethod,
            hanafiAsr: configuration.hanafiAsr, highLatitudeRule: configuration.highLatitudeRule,
            adjustments: configuration.adjustments,
            enabledPrayers: Set(session.focusEnabled.filter { $0.value }.keys.map(\.rawValue)))
        if !FocusRuntime().configure(focus, selection: selection, releasedEventIDs: session.releasedEventIDs) {
            lastError =
                "Focus could not be scheduled. Selected apps have been unlocked. Review Screen Time access and try again."
        } else {
            lastError = nil
        }
    }

    func pauseForOneHour() {
        pauseUntil = Date().addingTimeInterval(3600)
        FocusRuntime().pause(until: pauseUntil)
    }

    func resumeFocus() {
        pauseUntil = nil
        FocusRuntime().pause(until: nil)
    }

    private func refreshPauseStatus() {
        FocusStateStore().transaction { state in
            pauseUntil = state?.pauseUntil.flatMap { $0 > Date() ? $0 : nil }
        }
    }

    func requestAuthorization() async {
        lastError = nil

        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            authorizationStatus = AuthorizationCenter.shared.authorizationStatus
        } catch {
            lastError = error.localizedDescription
        }
    }
}
