import SwiftUI

// Displays one countdown unit as individual flip cards plus a label.
// Example: value=4, label="DAYS" → [0][4] over DAYS, where each card flips independently.
//
// Splitting into tens/units means "09" → "10" only flips the right card for 9→0
// and the left card for 0→1, just like a real flip clock.
struct DigitGroupView: View {
    let value: Int
    let label: String

    // Keep at least two tiles, allowing distant targets to show three or more days digits.
    private var digits: [String] {
        String(format: "%02d", value).map { String($0) }
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 4) {
                ForEach(Array(digits.enumerated()), id: \.offset) { _, digit in
                    FlipDigitView(digit: digit)
                }
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
        DigitGroupView(value: 4, label: "DAYS")
        DigitGroupView(value: 13, label: "HRS")
        DigitGroupView(value: 7, label: "MINS")
        DigitGroupView(value: 42, label: "SECS")
    }
    .padding(60)
    .background(.black)
}
