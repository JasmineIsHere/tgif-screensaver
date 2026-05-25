import SwiftUI

// FlipDigitView renders a single digit (e.g. "4") on a dark card,
// and animates a fold-down/fold-up transition whenever the digit changes.
//
// The animation uses four layers — two static back layers and two animating flaps.
// See the ClockView architecture comment for the full layer description.
struct FlipDigitView: View {

    let digit: String   // a single character: "0"–"9"

    // previousDigit is what was showing before the current flip started.
    // nextDigit is what we're flipping to.
    // They are the same at rest.
    @State private var previousDigit: String
    @State private var nextDigit: String

    // Rotation angles for the two animating flaps.
    // At rest both are 0° (flat). During a flip:
    //   topDegrees:    0° → -90° (top flap folds down and disappears)
    //   bottomDegrees: 90° → 0°  (bottom flap comes in from below)
    @State private var topDegrees: Double = 0
    @State private var bottomDegrees: Double = 0

    private let cardWidth:  CGFloat = 60
    private let cardHeight: CGFloat = 80
    private let fontSize:   CGFloat = 62

    init(digit: String) {
        self.digit = digit
        // State(initialValue:) sets the starting value before the view first renders.
        _previousDigit = State(initialValue: digit)
        _nextDigit     = State(initialValue: digit)
    }

    var body: some View {
        ZStack {

            // — Back layers (always visible, sit behind the flaps) —

            // Top half of the NEXT digit — revealed as the top flap rotates away.
            cardFace(nextDigit)
                .mask(alignment: .top) {
                    Rectangle().frame(height: cardHeight / 2)
                }

            // Bottom half of the PREVIOUS digit — visible while the top flap is falling.
            cardFace(previousDigit)
                .mask(alignment: .bottom) {
                    Rectangle().frame(height: cardHeight / 2)
                }

            // — Animating flaps (sit in front of the back layers) —

            // Top flap: previous digit's top half, folds down (0° → -90°).
            // When it reaches -90° it is perpendicular to the screen — invisible.
            cardFace(previousDigit)
                .mask(alignment: .top) {
                    Rectangle().frame(height: cardHeight / 2)
                }
                .rotation3DEffect(
                    .degrees(topDegrees),
                    axis: (x: 1, y: 0, z: 0),
                    // Rotating around the card's horizontal centre line (y: 0.5).
                    anchor: .center,
                    perspective: 0.4
                )

            // Bottom flap: next digit's bottom half, folds in (90° → 0°).
            // Starts perpendicular (invisible) and rotates flat into view.
            cardFace(nextDigit)
                .mask(alignment: .bottom) {
                    Rectangle().frame(height: cardHeight / 2)
                }
                .rotation3DEffect(
                    .degrees(bottomDegrees),
                    axis: (x: 1, y: 0, z: 0),
                    anchor: .center,
                    perspective: 0.4
                )

            // The midline gap — the visual "split" of a real flip clock card.
            Rectangle()
                .fill(.black)
                .frame(width: cardWidth, height: 1.5)
        }
        .frame(width: cardWidth, height: cardHeight)
        // onChange fires whenever `digit` receives a new value from the parent view.
        .onChange(of: digit, perform: flip)
    }

    // Runs the two-phase flip animation whenever the digit changes.
    private func flip(_ newDigit: String) {
        nextDigit     = newDigit   // update the back layer immediately
        topDegrees    = 0          // ensure top flap starts flat
        bottomDegrees = 90         // bottom flap starts perpendicular (invisible)

        // Phase 1 — top flap folds away, revealing the new digit's top half.
        // easeIn: starts slow, accelerates like a falling card.
        withAnimation(.easeIn(duration: 0.15)) {
            topDegrees = -90
        }

        // Phase 2 — bottom flap folds into view, completing the new digit.
        // easeOut: decelerates as it settles, like a card coming to rest.
        withAnimation(.easeOut(duration: 0.15).delay(0.15)) {
            bottomDegrees = 0
        }

        // After the full animation (0.30 s), sync previousDigit so the
        // next flip starts from the correct "old" value.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
            previousDigit = newDigit
            topDegrees    = 0
        }
    }

    // Renders the full card face: dark background + the digit centred on it.
    private func cardFace(_ text: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(white: 0.14))
            Text(text)
                .font(.system(size: fontSize, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
        }
        .frame(width: cardWidth, height: cardHeight)
    }
}

#Preview {
    HStack(spacing: 4) {
        FlipDigitView(digit: "0")
        FlipDigitView(digit: "4")
    }
    .padding(40)
    .background(.black)
}
