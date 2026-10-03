import SwiftUI

@main
struct PrayerFocusApp: App {
    @State private var session = PrayerFocusSession()
    @State private var screenTime = ScreenTimeService()
    @State private var membership = MembershipStore()
    @Environment(\.scenePhase) private var scenePhase

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
            .preferredColorScheme(.light)
            .task {
                await membership.prepare()
                await membership.observeTransactions()
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    Task { await membership.refreshAccess() }
                }
            }
        }
    }

    private var isTodayPreview: Bool {
        #if DEBUG
            ProcessInfo.processInfo.arguments.contains("-preview-today")
        #else
            false
        #endif
    }
}
