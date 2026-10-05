import SwiftUI

struct MembershipGateView: View {
    let session: PrayerFocusSession
    @Environment(MembershipStore.self) private var membership
    @Environment(FocusConfiguration.self) private var configuration
    @Environment(AffirmationDestination.self) private var affirmationDestination
    @State private var isShowingOffer = false
    @State private var memberSheet: AffirmationPresentation?
    @State private var isDismissingMemberSheet = false

    var body: some View {
        Group {
            if !configuration.hasCompletedSetup {
                FocusSettingsView(session: session, isSetup: true, allowsPrayerActions: false)
            } else if membership.hasAccess {
                TodayView(session: session, showSettings: { memberSheet = .settings })
            } else {
                introduction
                    .blur(radius: isShowingOffer ? 20 : 0, opaque: true)
                    .ignoresSafeArea(.container, edges: .top)
                    .allowsHitTesting(!isShowingOffer)
                    .accessibilityHidden(isShowingOffer)
            }
        }
        .sheet(isPresented: $isShowingOffer, onDismiss: showPendingAffirmation) {
            MembershipPaywallView(session: session)
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(28)
                .presentationBackground(PrayerTheme.canvas)
                // Show the blurred photo behind the status bar without a grey
                // dimming layer. The introduction cannot receive input.
                .presentationBackgroundInteraction(.enabled(upThrough: .large))
                .interactiveDismissDisabled(!membership.hasAccess)
        }
        .sheet(item: $memberSheet, onDismiss: memberSheetDidDismiss) { sheet in
            switch sheet {
            case .daily:
                DailyAffirmationSheet()
            case .settings:
                FocusSettingsView(session: session)
            }
        }
        .task {
            isShowingOffer = configuration.hasCompletedSetup && !membership.hasAccess
            showPendingAffirmation()
        }
        .onChange(of: configuration.hasCompletedSetup) { _, isComplete in
            isShowingOffer = isComplete && !membership.hasAccess
        }
        .onChange(of: membership.hasAccess) { _, hasAccess in
            if !hasAccess {
                if memberSheet != nil {
                    isDismissingMemberSheet = true
                    memberSheet = nil
                } else if !isDismissingMemberSheet {
                    isShowingOffer = configuration.hasCompletedSetup
                }
            } else {
                isShowingOffer = false
                showPendingAffirmation()
            }
        }
        .onChange(of: affirmationDestination.hasPendingRequest) { _, _ in
            showPendingAffirmation()
        }
        .onChange(of: membership.isRefreshingAccess) { _, isRefreshing in
            if !isRefreshing { showPendingAffirmation() }
        }
    }

    private func showPendingAffirmation() {
        guard !isShowingOffer, !isDismissingMemberSheet,
            !membership.isRefreshingAccess, membership.hasAccess,
            affirmationDestination.hasPendingRequest
        else { return }
        if memberSheet == .settings {
            isDismissingMemberSheet = true
            memberSheet = nil
            return
        }
        if affirmationDestination.consumeIfAllowed(
            hasAccess: membership.hasAccess,
            hasCheckedEntitlements: membership.hasCheckedEntitlements
        ) {
            memberSheet = .daily
        }
    }

    private func memberSheetDidDismiss() {
        isDismissingMemberSheet = false
        if membership.hasAccess {
            showPendingAffirmation()
        } else {
            isShowingOffer = configuration.hasCompletedSetup
        }
    }

    private var introduction: some View {
        VStack(spacing: 24) {
            Image("PaywallMosque")
                .resizable()
                .scaledToFill()
                .frame(height: 330)
                .clipped()

            VStack(alignment: .leading, spacing: 14) {
                Text("Make space\nfor salah.")
                    .font(.system(size: 36, weight: .bold))
                    .tracking(-1)
                    .foregroundStyle(PrayerTheme.ink)

                Text("Your setup is saved. Choose a membership to begin.")
                    .font(.body)
                    .foregroundStyle(PrayerTheme.secondaryInk)

                Button("See membership options") { isShowingOffer = true }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: PrayerTheme.controlHeight)
                    .background(PrayerTheme.sage, in: RoundedRectangle(cornerRadius: 16))
                    .buttonStyle(.plain)
                    .padding(.top, 12)
                    .accessibilityIdentifier("membership.seePlans")
            }
            .padding(.horizontal, 24)

            Spacer(minLength: 0)
        }
        .background(PrayerTheme.canvas.ignoresSafeArea())
    }
}
