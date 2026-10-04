import SwiftUI

struct MembershipGateView: View {
    let session: PrayerFocusSession
    @Environment(MembershipStore.self) private var membership
    @Environment(FocusConfiguration.self) private var configuration
    @State private var isShowingOffer = false

    var body: some View {
        Group {
            if membership.hasAccess {
                TodayView(session: session)
            } else if !configuration.hasCompletedSetup {
                FocusSettingsView(session: session, isSetup: true, allowsPrayerActions: false)
            } else {
                introduction
                    .blur(radius: isShowingOffer ? 20 : 0, opaque: true)
                    .ignoresSafeArea(.container, edges: .top)
                    .allowsHitTesting(!isShowingOffer)
                    .accessibilityHidden(isShowingOffer)
            }
        }
        .sheet(isPresented: $isShowingOffer) {
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
        .task {
            isShowingOffer = configuration.hasCompletedSetup && !membership.hasAccess
        }
        .onChange(of: configuration.hasCompletedSetup) { _, isComplete in
            isShowingOffer = isComplete && !membership.hasAccess
        }
        .onChange(of: membership.hasAccess) { _, hasAccess in
            isShowingOffer = configuration.hasCompletedSetup && !hasAccess
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
