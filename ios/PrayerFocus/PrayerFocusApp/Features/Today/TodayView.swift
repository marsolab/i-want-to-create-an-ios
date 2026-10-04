import SwiftUI

struct TodayView: View {
    @Bindable var session: PrayerFocusSession
    @Environment(ScreenTimeService.self) private var screenTime
    var showSettings: (() -> Void)?

    @State private var isShowingSettings = false
    @State private var isConfirmingUnlock = false

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    PrayerHeroView(
                        prayer: session.currentPrayer,
                        phase: session.phase,
                        selectedItemCount: screenTime.selectedItemCount,
                        isAuthorized: screenTime.isAuthorized,
                        topSafeAreaInset: geometry.safeAreaInsets.top,
                        settingsAction: {
                            if let showSettings {
                                showSettings()
                            } else {
                                isShowingSettings = true
                            }
                        }
                    )

                    VStack(spacing: 12) {
                        Button(action: session.performPrimaryAction) {
                            HStack {
                                Spacer()
                                Text(session.primaryActionTitle)
                                    .font(.headline)
                                Spacer()
                                Image(
                                    systemName: session.phase == .inProgress
                                        ? "checkmark" : "arrow.right"
                                )
                                .font(.system(size: 18, weight: .semibold))
                            }
                            .padding(.horizontal, 20)
                            .frame(minHeight: PrayerTheme.controlHeight)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.white)
                        .background(PrayerTheme.sage)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .opacity(session.canPerformPrimaryAction ? 1 : 0.55)
                        .disabled(!session.canPerformPrimaryAction)

                        if session.phase != .checkedIn {
                            Button("Already prayed", action: session.markAlreadyPrayed)
                                .font(.headline)
                                .foregroundStyle(PrayerTheme.sage)
                                .frame(maxWidth: .infinity, minHeight: PrayerTheme.controlHeight)
                                .background(PrayerTheme.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(PrayerTheme.sage.opacity(0.65), lineWidth: 1)
                                }
                        }

                        if session.phase != .checkedIn && session.phase != .unlocked {
                            Button("Unlock for this prayer") {
                                isConfirmingUnlock = true
                            }
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(PrayerTheme.secondaryInk)
                            .frame(minHeight: 44)
                        }
                    }
                    .padding(.horizontal, PrayerTheme.pageMargin)
                    .padding(.top, 42)

                    PrayerScheduleView(
                        currentPrayer: session.currentPrayer,
                        phase: session.phase
                    )
                    .padding(.horizontal, PrayerTheme.pageMargin)
                    .padding(.top, 34)
                    .padding(.bottom, 36)
                }
            }
            .contentMargins(.top, 0, for: .scrollContent)
            .ignoresSafeArea(.container, edges: .top)
            .scrollIndicators(.hidden)
        }
        .background(PrayerTheme.canvas.ignoresSafeArea())
        .sheet(isPresented: $isShowingSettings) {
            FocusSettingsView(session: session)
                .environment(screenTime)
        }
        .confirmationDialog(
            "Unlock selected apps for this prayer?",
            isPresented: $isConfirmingUnlock,
            titleVisibility: .visible
        ) {
            Button("Unlock without check-in", role: .destructive) {
                session.unlockWithoutCheckIn()
            }
            Button("Keep focus", role: .cancel) {}
        } message: {
            Text("This does not record the prayer as completed.")
        }
    }
}

#Preview {
    TodayView(session: PrayerFocusSession())
        .environment(ScreenTimeService())
}
