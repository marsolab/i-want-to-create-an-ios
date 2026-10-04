import SwiftUI

@main
struct PrayerFocusApp: App {
    @State private var session: PrayerFocusSession
    @State private var screenTime: ScreenTimeService
    @State private var configuration: FocusConfiguration
    @State private var membership = MembershipStore()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        let defaults: UserDefaults
        #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("-ui-testing") {
                let suite = "com.marsolab.PrayerFocus.UITests"
                defaults = UserDefaults(suiteName: suite)!
                if ProcessInfo.processInfo.arguments.contains("-reset-setup") {
                    defaults.removePersistentDomain(forName: suite)
                }
            } else {
                defaults = .standard
            }
        #else
            defaults = .standard
        #endif
        _configuration = State(initialValue: FocusConfiguration(defaults: defaults))
        _session = State(initialValue: PrayerFocusSession(defaults: defaults))
        _screenTime = State(initialValue: ScreenTimeService(defaults: defaults))
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if isTodayPreview {
                    TodayView(session: session)
                } else if membership.hasCheckedEntitlements {
                    MembershipGateView(session: session)
                } else {
                    ProgressView()
                        .tint(PrayerTheme.sage)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(PrayerTheme.canvas.ignoresSafeArea())
                }
            }
            .environment(screenTime)
            .environment(membership)
            .environment(configuration)
            .preferredColorScheme(.light)
            .task {
                // The unit-test host must let SKTestSession configure StoreKit first.
                guard !isUnitTestHost else { return }
                await membership.prepare()
                await membership.observeTransactions()
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active && !isUnitTestHost {
                    Task { await membership.refreshAccess() }
                }
            }
        }
    }

    private var isUnitTestHost: Bool {
        #if DEBUG
            NSClassFromString("XCTestCase") != nil
        #else
            false
        #endif
    }

    private var isTodayPreview: Bool {
        #if DEBUG
            ProcessInfo.processInfo.arguments.contains("-preview-today")
        #else
            false
        #endif
    }
}
