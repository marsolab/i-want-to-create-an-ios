import FamilyControls
import SwiftUI

struct FocusSettingsView: View {
    @Bindable var session: PrayerFocusSession
    @Environment(ScreenTimeService.self) private var screenTime
    @Environment(\.dismiss) private var dismiss

    @State private var isPickerPresented = false
    @State private var notificationsEnabled = true
    @State private var city = "Select city"
    @State private var calculationMethod = "Select method"

    private let cities = ["Select city", "London", "New York", "Toronto", "Dubai", "Kuala Lumpur"]
    private let methods = ["Select method", "Muslim World League", "ISNA", "Umm al-Qura", "Egyptian Authority"]

    var body: some View {
        @Bindable var screenTime = screenTime

        NavigationStack {
            Form {
                Section {
                    NavigationLink {
                        DailyAffirmationView()
                    } label: {
                        Label("Daily affirmations", systemImage: "moon")
                    }
                    .accessibilityIdentifier("settings.dailyAffirmations")
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
                    }
                }

                Section {
                    Picker("City", selection: $city) {
                        ForEach(cities, id: \.self) { city in
                            Text(city).tag(city)
                        }
                    }

                    Picker("Calculation method", selection: $calculationMethod) {
                        ForEach(methods, id: \.self) { method in
                            Text(method).tag(method)
                        }
                    }
                } header: {
                    Text("Prayer schedule")
                } footer: {
                    Text("Compare the schedule with a trusted local timetable before turning focus on.")
                }

                Section("Notifications") {
                    Toggle("Prayer start notification", isOn: $notificationsEnabled)
                        .tint(PrayerTheme.sage)
                }

                Section {
                    Button("Unlock current prayer") {
                        session.unlockWithoutCheckIn()
                        dismiss()
                    }
                } footer: {
                    Text("Check-ins are self-reported and stored only on this device in this development slice.")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
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
