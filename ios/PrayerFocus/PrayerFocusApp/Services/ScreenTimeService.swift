import FamilyControls
import Foundation
import Observation

@MainActor
@Observable
final class ScreenTimeService {
    var selection = FamilyActivitySelection()
    private(set) var lastError: String?

    var authorizationStatus: AuthorizationStatus {
        AuthorizationCenter.shared.authorizationStatus
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

    func requestAuthorization() async {
        lastError = nil

        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
        } catch {
            lastError = error.localizedDescription
        }
    }
}
