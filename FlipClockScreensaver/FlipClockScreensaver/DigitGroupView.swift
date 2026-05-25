import SwiftUI

// Displays one countdown unit as two individual flip cards plus a label.
// Example: value=4, label="DAYS" → [0][4] over DAYS, where each card flips independently.
//
// Splitting into tens/units means "09" → "10" only flips the right card for 9→0
// and the left card for 0→1, just like a real flip clock.
struct DigitGroupView: View {
    let value: Int
    let label: String

    // Integer division and remainder cleanly extract the two digits.
    // value=4  → tens="0", units="4"
    // value=13 → tens="1", units="3"
    private var tensDigit:  String { String(value / 10) }
    private var unitsDigit: String { String(value % 10) }

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 4) {
                FlipDigitView(digit: tensDigit)
                FlipDigitView(digit: unitsDigit)
            }

            Text(label)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(.gray)
                .tracking(3)
        }
    }
}

#Preview {
    HStack(spacing: 28) {
        DigitGroupView(value: 4,  label: "DAYS")
        DigitGroupView(value: 13, label: "HRS")
        DigitGroupView(value: 7,  label: "MINS")
        DigitGroupView(value: 42, label: "SECS")
    }
    .padding(60)
    .background(.black)
}
