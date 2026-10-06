import SwiftUI

// Settings are staged locally; Cancel discards edits and OK persists them.
struct SettingsView: View {
    @ObservedObject var prefs: ClockPreferences
    let onDismiss: () -> Void

    @State private var usesSpecificDate: Bool
    @State private var targetDate: Date
    @State private var countdownLabel: String
    @State private var selectedHour: Int

    private let singaporeTimeZone = TimeZone(identifier: "Asia/Singapore")!

    init(prefs: ClockPreferences, onDismiss: @escaping () -> Void) {
        self.prefs = prefs
        self.onDismiss = onDismiss
        _usesSpecificDate = State(initialValue: prefs.usesSpecificDate)
        _targetDate = State(initialValue: prefs.targetDate)
        _countdownLabel = State(initialValue: prefs.countdownLabel)
        _selectedHour = State(initialValue: prefs.tgifHour)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Flip Clock Settings").font(.headline)
            Divider()
            Picker("Countdown to", selection: $usesSpecificDate) {
                Text("Specific date").tag(true)
                Text("End of the week").tag(false)
            }

            if usesSpecificDate {
                DatePicker(
                    "Target", selection: $targetDate, displayedComponents: [.date, .hourAndMinute]
                )
                .environment(\.timeZone, singaporeTimeZone)
                Text("Singapore time (SGT, UTC+8)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("Countdown label", text: $countdownLabel)
                Text("At the target time, the countdown stays at zero and shows “It’s time!”.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                HStack {
                    Text("Work ends at")
                    Spacer()
                    Picker("", selection: $selectedHour) {
                        ForEach(0..<24, id: \.self) { hour in
                            Text(String(format: "%02d:00", hour)).tag(hour)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 90)
                }
                Text("The screensaver switches to weekend mode at this time on Friday.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

            }

            Divider()
            HStack {
                Spacer()
                Button("Cancel") { onDismiss() }
                    .keyboardShortcut(.escape, modifiers: [])
                Button("OK") {
                    prefs.usesSpecificDate = usesSpecificDate
                    prefs.targetDate = targetDate
                    prefs.countdownLabel = countdownLabel
                    prefs.tgifHour = selectedHour
                    prefs.save()
                    onDismiss()
                }
                .keyboardShortcut(.return, modifiers: [])
            }
        }
        .padding(24)
        .frame(width: 420)
        .onAppear {
            prefs.reload()
            usesSpecificDate = prefs.usesSpecificDate
            targetDate = prefs.targetDate
            countdownLabel = prefs.countdownLabel
            selectedHour = prefs.tgifHour
        }
    }
}

#Preview {
    SettingsView(prefs: ClockPreferences(bundleID: "com.preview"), onDismiss: {})
}
