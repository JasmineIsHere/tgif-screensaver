import ScreenSaver
import SwiftUI

// ScreenSaver.framework requires an ObjC-visible class as the bundle's principal class.
// The @objc(...) annotation gives it a predictable ObjC name so NSPrincipalClass in
// Info.plist can find it at runtime.
@objc(FlipClockScreensaverView)
class FlipClockScreensaverView: ScreenSaverView {

    // NSHostingView bridges AppKit (ScreenSaverView) → SwiftUI (ClockView).
    // We hold a strong reference so it isn't deallocated.
    private var hostingView: NSHostingView<AnyView>?

    // preferences is created once and shared between ClockView and the settings sheet.
    // lazy var means it's only created when first accessed, at which point Self.self
    // is a fully initialised object and Bundle(for:) works correctly.
    private lazy var preferences: ClockPreferences = {
        let bundleID = Bundle(for: FlipClockScreensaverView.self).bundleIdentifier
            ?? "com.flipclock"
        return ClockPreferences(bundleID: bundleID)
    }()

    // The settings window is also created lazily so we only build it if the user
    // actually clicks "Options..." in System Settings.
    private lazy var configureSheetWindow: NSWindow = {
        let view = SettingsView(prefs: preferences) { [weak self] in
            guard let self else { return }
            // endSheet tells macOS the modal sheet is finished.
            // The parent is the System Settings window that presented the sheet.
            self.configureSheetWindow.sheetParent?.endSheet(self.configureSheetWindow)
        }
        // NSHostingController wraps a SwiftUI view so it can be the content of an NSWindow.
        let controller = NSHostingController(rootView: view)
        let window = NSWindow(contentViewController: controller)
        window.styleMask = [.titled]
        return window
    }()

    // macOS calls this when the screensaver is first loaded.
    // isPreview is true when shown in System Settings, false on the real screen.
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        animationTimeInterval = 1.0
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        animationTimeInterval = 1.0
        setup()
    }

    private func setup() {
        // Inject preferences into the SwiftUI environment so ClockView can read tgifHour.
        // AnyView is a type-erased wrapper — needed because environmentObject() changes
        // the concrete type of ClockView and NSHostingView requires a fixed generic type.
        let root = AnyView(ClockView().environmentObject(preferences))
        let hosting = NSHostingView(rootView: root)
        hosting.frame = bounds
        hosting.autoresizingMask = [.width, .height]
        addSubview(hosting)
        hostingView = hosting
    }

    // Called by macOS on every animationTimeInterval tick.
    // ClockView drives its own timer internally, so nothing extra is needed here.
    override func animateOneFrame() {
        super.animateOneFrame()
    }

    // Returning true tells macOS to show the "Options..." button in System Settings.
    override var hasConfigureSheet: Bool { true }

    // macOS calls this to get the window to show as a sheet when the user clicks "Options...".
    override var configureSheet: NSWindow? { configureSheetWindow }
}
