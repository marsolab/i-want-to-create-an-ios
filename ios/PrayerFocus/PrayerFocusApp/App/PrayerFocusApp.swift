import SwiftUI
import UIKit
import WidgetKit

@main
struct PrayerFocusApp: App {
    @State private var session = PrayerFocusSession()
    @State private var screenTime = ScreenTimeService()
    @State private var membership = MembershipStore()
    @State private var affirmationDestination = AffirmationDestination()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            Group {
                if isAffirmationPreview {
                    NavigationStack {
                        DailyAffirmationView(previewAffirmation: DailyAffirmationCatalog.all[14])
                    }
                } else if isTodayPreview {
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
            .environment(affirmationDestination)
            .preferredColorScheme(.light)
            .onOpenURL { url in
                if affirmationDestination.receive(url) {
                    membership.beginAccessRefresh()
                    Task { await membership.refreshAccess() }
                }
            }
            .task {
                #if DEBUG
                    if ProcessInfo.processInfo.arguments.contains("-open-affirmation") {
                        affirmationDestination.receive(URL(string: "prayerfocus://daily-affirmation")!)
                    }
                #endif
                await membership.prepare()
                await membership.observeTransactions()
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    membership.beginAccessRefresh()
                    Task { await membership.refreshAccess() }
                    WidgetCenter.shared.reloadTimelines(ofKind: WidgetMembershipStore.widgetKind)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) {
                _ in
                membership.beginAccessRefresh()
                Task { await membership.refreshAccess() }
                WidgetCenter.shared.reloadTimelines(ofKind: WidgetMembershipStore.widgetKind)
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

    private var isAffirmationPreview: Bool {
        #if DEBUG
            ProcessInfo.processInfo.arguments.contains("-preview-affirmation")
        #else
            false
        #endif
    }
}
