import SwiftUI

// SettingsView is the UI shown inside the screensaver's "Options..." sheet.
// It lets the user pick what hour their work day ends on Friday.
//
// selectedHour is a local copy of prefs.tgifHour so that cancelling the sheet
// discards changes — we only write to prefs when the user clicks OK.
struct SettingsView: View {

    @ObservedObject var prefs: ClockPreferences

    // onDismiss is called by both OK and Cancel to close the sheet.
    // The actual NSWindow dismissal logic lives in TgifScreensaverView,
    // which creates this view and passes the closure in.
    let onDismiss: () -> Void

    // Local copy of the hour so Cancel can discard without touching prefs.
    @State private var selectedHour: Int

    init(prefs: ClockPreferences, onDismiss: @escaping () -> Void) {
        self.prefs = prefs
        self.onDismiss = onDismiss
        _selectedHour = State(initialValue: prefs.tgifHour)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text("Flip Clock Settings")
                .font(.headline)

            Divider()

            HStack {
                Text("Work ends at")
                Spacer()
                // Picker shows hours as "09:00", "17:00", etc.
                // The tag(hour) binds each option to its integer value.
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

            Divider()

            HStack {
                Spacer()
                Button("Cancel") {
                    onDismiss()
                }
                .keyboardShortcut(.escape, modifiers: [])

                Button("OK") {
                    prefs.tgifHour = selectedHour
                    prefs.save()
                    onDismiss()
                }
                .keyboardShortcut(.return, modifiers: [])
            }
        }
        .padding(24)
        .frame(width: 320)
        // If the sheet is opened a second time, reset the picker to the saved value
        // (in case a previous session ended with Cancel, selectedHour could be stale).
        .onAppear {
            selectedHour = prefs.tgifHour
        }
    }
}

#Preview {
    // ScreenSaverDefaults isn't available in previews, so we stub a fake bundle ID.
    SettingsView(prefs: ClockPreferences(bundleID: "com.preview"), onDismiss: {})
}
