import ScreenSaver

// ClockPreferences stores user settings using ScreenSaverDefaults.
//
// ScreenSaverDefaults is Apple's version of UserDefaults scoped to a specific
// screensaver bundle — it writes to ~/Library/Preferences/<bundleID>.plist so
// the screensaver's prefs don't collide with other apps.
//
// This class is an ObservableObject so SwiftUI views can react when tgifHour changes.
final class ClockPreferences: ObservableObject {

    // @Published means: whenever tgifHour is set, notify any SwiftUI views watching this object.
    @Published var tgifHour: Int

    private let defaults: ScreenSaverDefaults?
    private let tgifHourKey = "tgifHour"

    // bundleID must match the screensaver bundle's CFBundleIdentifier.
    // We get this at runtime from the bundle itself (see TgifScreensaverView).
    init(bundleID: String) {
        let d = ScreenSaverDefaults(forModuleWithName: bundleID)
        // register(defaults:) sets the fallback value used when the key has never been written.
        // It does NOT overwrite an existing saved value.
        d?.register(defaults: ["tgifHour": 18])
        self.defaults = d
        self.tgifHour = d?.integer(forKey: "tgifHour") ?? 18
    }

    // Persists the current tgifHour value to disk.
    // Call this when the user confirms the settings sheet.
    func save() {
        defaults?.set(tgifHour, forKey: tgifHourKey)
        // synchronize() flushes the in-memory cache to disk immediately.
        // Without it, writes might be delayed until the app quits.
        defaults?.synchronize()
    }
}
