import FamilyControls
import SwiftUI

struct FocusSettingsView: View {
    @Bindable var session: PrayerFocusSession
    @Environment(ScreenTimeService.self) private var screenTime
    @Environment(FocusConfiguration.self) private var configuration
    @Environment(\.dismiss) private var dismiss
    var isSetup = false
    var allowsPrayerActions = true

    @State private var isPickerPresented = false

    var body: some View {
        @Bindable var screenTime = screenTime
        @Bindable var configuration = configuration

        NavigationStack {
            Form {
                if isSetup {
                    Section {
                        Text("Make space for salah, your way.")
                            .font(.title2.weight(.semibold))
                        Text(
                            "Choose your prayer settings and the apps you want to pause. You can change these later, pause focus, or unlock apps for any prayer."
                        )
                        Text(
                            "Next, choose a monthly or yearly membership. Eligible subscribers can start with 3 days free after confirming with Apple."
                        )
                        .foregroundStyle(PrayerTheme.secondaryInk)
                    }
                }

                Section {
                    Picker("City", selection: $configuration.city) {
                        ForEach(FocusConfiguration.cities, id: \.self) { city in
                            Text(city).tag(city)
                        }
                    }
                    .accessibilityIdentifier("setup.city")

                    Picker("Calculation method", selection: $configuration.calculationMethod) {
                        ForEach(FocusConfiguration.methods, id: \.self) { method in
                            Text(method).tag(method)
                        }
                    }
                    .accessibilityIdentifier("setup.calculationMethod")
                } header: {
                    Text("Prayer schedule")
                } footer: {
                    Text(
                        "Choose the settings used by your local mosque. Prayer-time calculation is still being prepared; these choices are saved on this device."
                    )
                }

                if !isSetup && allowsPrayerActions {
                    Section {
                        NavigationLink {
                            DailyAffirmationView()
                        } label: {
                            Label("Daily affirmations", systemImage: "moon")
                        }
                        .accessibilityIdentifier("settings.dailyAffirmations")
                    }
                }

                Section {
                    LabeledContent("Permission", value: screenTime.authorizationLabel)

                    if !screenTime.isAuthorized {
                        Button("Allow Screen Time access") {
                            Task { await screenTime.requestAuthorization() }
                        }
                    }

                    Button {
                        isPickerPresented = true
                    } label: {
                        LabeledContent("Distracting apps", value: selectedItemsLabel)
                    }
                    .disabled(!screenTime.isAuthorized)

                    if let lastError = screenTime.lastError {
                        Text(lastError)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                } header: {
                    Text("Screen Time")
                } footer: {
                    Text(
                        "Scheduled shielding still requires the Family Controls entitlement and validation on a physical iPhone."
                    )
                }

                Section("Focus for prayers") {
                    ForEach(Prayer.allCases) { prayer in
                        Toggle(
                            prayer.displayName,
                            isOn: focusBinding(for: prayer)
                        )
                        .tint(PrayerTheme.sage)
                        .accessibilityIdentifier("setup.prayer.\(prayer.rawValue)")
                    }
                }

                Section("Notifications") {
                    Toggle("Prayer start notification", isOn: $configuration.notificationsEnabled)
                        .tint(PrayerTheme.sage)
                        .accessibilityIdentifier("setup.notifications")
                }

                if allowsPrayerActions && !isSetup {
                    Section {
                        Button("Unlock current prayer") {
                            session.unlockWithoutCheckIn()
                            dismiss()
                        }
                    } footer: {
                        Text("Check-ins are self-reported and stored only on this device in this development slice.")
                    }
                }
            }
            .navigationTitle(isSetup ? "Set up Prayer Focus" : "Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !isSetup {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { dismiss() }
                            .fontWeight(.semibold)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if isSetup {
                    VStack(spacing: 8) {
                        Button("Continue to membership") { configuration.completeSetup() }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: PrayerTheme.controlHeight)
                            .background(PrayerTheme.sage, in: RoundedRectangle(cornerRadius: 16))
                            .buttonStyle(.plain)
                            .disabled(!configuration.canCompleteSetup)
                            .opacity(configuration.canCompleteSetup ? 1 : 0.5)
                            .accessibilityIdentifier("setup.continue")
                        Text("Your setup is saved. No payment is taken here.")
                            .font(.footnote)
                            .foregroundStyle(PrayerTheme.secondaryInk)
                    }
                    .padding(16)
                    .background(PrayerTheme.canvas)
                }
            }
            .familyActivityPicker(
                isPresented: $isPickerPresented,
                selection: $screenTime.selection
            )
        }
        .tint(PrayerTheme.sage)
    }

    private var selectedItemsLabel: String {
        let count = screenTime.selectedItemCount
        return count == 0 ? "None" : "\(count) selected"
    }

    private func focusBinding(for prayer: Prayer) -> Binding<Bool> {
        Binding(
            get: { session.isFocusEnabled(for: prayer) },
            set: { session.focusEnabled[prayer] = $0 }
        )
    }
}
