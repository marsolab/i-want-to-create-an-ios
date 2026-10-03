import SwiftUI

struct MembershipGateView: View {
    let session: PrayerFocusSession
    @Environment(MembershipStore.self) private var membership
    @State private var isShowingOffer = false

    var body: some View {
        Group {
            if membership.hasAccess {
                TodayView(session: session)
            } else {
                introduction
                    .blur(radius: isShowingOffer ? 20 : 0, opaque: true)
                    .ignoresSafeArea(.container, edges: .top)
                    .allowsHitTesting(!isShowingOffer)
                    .accessibilityHidden(isShowingOffer)
            }
        }
        .sheet(isPresented: $isShowingOffer) {
            MembershipPaywallView()
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
            isShowingOffer = !membership.hasAccess
        }
        .onChange(of: membership.hasAccess) { _, hasAccess in
            if !hasAccess {
                isShowingOffer = true
            }
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

                Text("A Prayer Focus subscription gives you access to the app.")
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
