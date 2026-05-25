# Architecture Decisions

## Flip animation: 4-layer approach
**Decision:** `FlipDigitView` uses four `ZStack` layers — two static "back" layers and two animating flaps — rather than a single rotating card.  
**Why:** A single rotating card would show the wrong digit on the back face. The 4-layer approach lets us show the correct digit on every face at every moment during the animation, matching how a real mechanical flip clock works.  
**Trade-off:** More layers = slightly more complex code, but the visual result is correct.

## ClockView owns its own timer (not animateOneFrame)
**Decision:** `ClockView` drives itself with `Timer.publish(every: 1, ...)` rather than relying on `ScreenSaverView.animateOneFrame()`.  
**Why:** Keeps the SwiftUI layer self-contained and previewable in Xcode canvas without the ScreenSaver.framework at all. `animateOneFrame` is an AppKit-era API; piping data through it would tightly couple the UI to the bridge layer.  
**Trade-off:** The timer runs even in the preview canvas, which is fine.

## DigitGroupView splits value into tens and units
**Decision:** Each `DigitGroupView` renders two `FlipDigitView` cards — one for the tens digit, one for the units digit.  
**Why:** If we passed the full two-digit number to a single card, changing from 09→10 would flip the whole card. Splitting means only the digit that actually changed flips, which is how a real flip clock behaves and looks much better.

## NSHostingView bridge pattern
**Decision:** `FlipClockScreensaverView` (the ScreenSaverView subclass) embeds `ClockView` inside an `NSHostingView`, which fills the full frame with `autoresizingMask`.  
**Why:** ScreenSaver.framework is AppKit-based (NSView). `NSHostingView` is the standard Apple-provided bridge from AppKit → SwiftUI. We minimise AppKit usage to just this one class.

## @objc annotation on the principal class
**Decision:** `FlipClockScreensaverView` is annotated `@objc(FlipClockScreensaverView)` to give it a stable ObjC name.  
**Why:** `NSPrincipalClass` in Info.plist must exactly match the ObjC runtime name. Without the annotation, Swift may mangle the name (adding the module prefix), causing the screensaver to fail to load.

## CountdownEngine as a pure static struct
**Decision:** All countdown logic lives in static functions on `CountdownEngine`. No stored state, no timers, no observers.  
**Why:** Pure functions are trivially testable — pass any `Date`, get a deterministic `TimeRemaining` back. The view layer (ClockView) owns the timer and calls `currentCountdown()` on each tick.

## TGIF hour is configurable, defaulting to 18
**Decision:** The end-of-work hour is stored in `ScreenSaverDefaults` under key `"tgifHour"`, defaulting to 18 via `register(defaults:)`.  
**Why:** Different users end work at different times. Using `register(defaults:)` (not a hardcoded fallback in the read path) means the default is declared once and respected automatically if the key is never written.  
**How to apply:** Always call `register(defaults:)` before the first `integer(forKey:)` read, or the key's absence returns 0 instead of 18.

## ClockPreferences as ObservableObject injected via @EnvironmentObject
**Decision:** `ClockPreferences` is an `ObservableObject` created once in `FlipClockScreensaverView` and injected into `ClockView` via `.environmentObject()`.  
**Why:** Avoids passing the preferences object through every view layer manually. `@EnvironmentObject` is Swift's standard mechanism for this. The single instance is shared between `ClockView` (reads `tgifHour` on each tick) and `SettingsView` (writes on OK).  
**Trade-off:** `@EnvironmentObject` crashes at runtime if the object is missing from the environment — every preview must inject it explicitly with `.environmentObject(ClockPreferences(bundleID: "com.preview"))`.

## AnyView type erasure for NSHostingView
**Decision:** `setup()` wraps `ClockView().environmentObject(preferences)` in `AnyView` before passing to `NSHostingView`.  
**Why:** Calling `.environmentObject()` on a view changes its concrete Swift type (it returns a `ModifiedContent<ClockView, ...>`). `NSHostingView` is generic over its root view type, so the type must be fixed at compile time. `AnyView` erases the type, letting `NSHostingView<AnyView>` be declared as a stored property.  
**Trade-off:** `AnyView` disables some SwiftUI diff optimisations, but for a single root view in a screensaver this has no practical impact.

## Settings sheet via NSHostingController + NSWindow (lazy)
**Decision:** `configureSheetWindow` is a `lazy var` that creates an `NSWindow` backed by an `NSHostingController<SettingsView>`.  
**Why:** Screensaver settings sheets must be `NSWindow` instances (ScreenSaver.framework API). `NSHostingController` is the bridge from a SwiftUI view to an `NSViewController`, which `NSWindow(contentViewController:)` accepts. `lazy var` ensures the window is only built if the user actually clicks Options…  
**How to apply:** Dismiss is done via `sheetParent?.endSheet(configureSheetWindow)` — `sheetParent` is the System Settings window that presented the sheet.

## Unit tests via Swift Package (not Xcode test target)
**Decision:** Tests live in a `Package.swift` at the project root, not in an Xcode test target.  
**Why:** Adding a test target to the Xcode project requires GUI interaction or complex `project.pbxproj` surgery. A Swift Package avoids both and lets `swift test` run from the terminal. `CountdownEngine` only imports `Foundation`, so it compiles cleanly without ScreenSaver.framework or SwiftUI.  
**Trade-off:** `Sources/CountdownLogic/CountdownEngine.swift` is a manual copy of the Xcode file. Must be kept in sync when the engine changes.
