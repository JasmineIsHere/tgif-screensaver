import SwiftUI

// ClockView is the root SwiftUI view for the screensaver.
// Its only jobs are: own the countdown state, drive the timer, and lay out the components.
// All calculation lives in CountdownEngine — this view only displays what it receives.
struct ClockView: View {

    // @EnvironmentObject is SwiftUI's way of sharing an object across many views without
    // passing it through every intermediate view manually. FlipClockScreensaverView injects
    // ClockPreferences into the environment; we just declare that we need it here.
    @EnvironmentObject var prefs: ClockPreferences

    // @State tells SwiftUI: "when this value changes, redraw the view."
    @State private var countdown = CountdownEngine.currentCountdown()

    // Timer.publish creates a Combine publisher that fires every second on the main thread.
    // .autoconnect() starts the timer as soon as the view appears.
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 28) {

                // Header line — changes based on which phase we're in.
                Text(headerText)
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.gray)
                    .tracking(5)

                // The four digit groups in a row, separated by colons.
                HStack(alignment: .top, spacing: 20) {
                    DigitGroupView(value: countdown.days,    label: "DAYS")
                    colonSeparator
                    DigitGroupView(value: countdown.hours,   label: "HRS")
                    colonSeparator
                    DigitGroupView(value: countdown.minutes, label: "MINS")
                    colonSeparator
                    DigitGroupView(value: countdown.seconds, label: "SECS")
                }
            }
        }
        // Compute the first value immediately so the display isn't blank for 1 second.
        .onAppear {
            countdown = CountdownEngine.currentCountdown(tgifHour: prefs.tgifHour)
        }
        // onReceive fires on every timer tick — we pass tgifHour so changes take effect
        // at most one second after the user saves them in Settings.
        .onReceive(timer) { _ in
            countdown = CountdownEngine.currentCountdown(tgifHour: prefs.tgifHour)
        }
    }

    // The colon separator between digit groups.
    // The invisible label Text at the bottom matches the height of the label in
    // DigitGroupView so the colon stays vertically aligned with the digits, not the labels.
    private var colonSeparator: some View {
        VStack(spacing: 10) {
            // Frame matches the flip card height (80pt) so the colon sits
            // centred on the cards rather than drifting up with the font metrics.
            Text(":")
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundStyle(.gray.opacity(0.25))
                .frame(height: 80)
            // Invisible spacer mirrors the label row in DigitGroupView.
            Text(" ")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
        }
    }

    // Returns the header string for the current countdown phase.
    private var headerText: String {
        switch countdown.phase {
        case .toTGIF:   return "TIME UNTIL TGIF"
        case .toMonday: return "WEEKEND ENDS IN"
        }
    }
}

// Two previews — one per phase — so both states can be checked in the canvas.
#Preview("Work week") {
    ClockView()
        .environmentObject(ClockPreferences(bundleID: "com.preview"))
        .frame(width: 800, height: 500)
}

#Preview("Digit tile") {
    DigitGroupView(value: 4, label: "DAYS")
        .padding(60)
        .background(.black)
}
