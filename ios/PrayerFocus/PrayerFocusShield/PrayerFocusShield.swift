import Foundation
import ManagedSettings
import ManagedSettingsUI
import UIKit

final class PrayerFocusShield: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration { configuration() }
    override func configuration(shielding application: Application, in category: ActivityCategory)
        -> ShieldConfiguration
    { configuration() }
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration { configuration() }
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        configuration()
    }

    private func configuration() -> ShieldConfiguration {
        var prayerName: String?
        let readable = FocusStateStore().transaction { state in
            if let window = FocusPolicy.activeWindow(
                state: state, membership: WidgetMembershipStore().read(), authorized: true, at: Date())
            {
                prayerName = Prayer(rawValue: window.prayer)?.displayName
            } else {
                ManagedSettingsStore(named: .init("salahside.focus")).clearAllSettings()
            }
        }
        if !readable { ManagedSettingsStore(named: .init("salahside.focus")).clearAllSettings() }
        let buttonTitle: String
        if #available(iOS 26.5, *) { buttonTitle = "Open SalahSide" } else { buttonTitle = "Close" }
        let ink = UIColor(red: 0.17, green: 0.23, blue: 0.19, alpha: 1)
        let sage = UIColor(red: 0.34, green: 0.43, blue: 0.36, alpha: 1)
        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterial,
            backgroundColor: UIColor(red: 0.97, green: 0.96, blue: 0.92, alpha: 1),
            icon: UIImage(systemName: "moon.stars"),
            title: .init(text: prayerName.map { "\($0) · SalahSide" } ?? "SalahSide", color: ink),
            subtitle: .init(
                text: "Make space for salah. Open SalahSide to finish prayer, unlock apps, or pause focus.", color: ink),
            primaryButtonLabel: .init(text: buttonTitle, color: .white), primaryButtonBackgroundColor: sage)
    }
}
