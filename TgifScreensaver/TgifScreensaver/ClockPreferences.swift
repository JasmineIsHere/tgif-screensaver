import ScreenSaver

final class ClockPreferences: ObservableObject {

    @Published var usesSpecificDate: Bool
    @Published var targetDate: Date
    @Published var countdownLabel: String
    @Published var tgifHour: Int

    private let defaults: ScreenSaverDefaults?

    private let tgifHourKey = "tgifHour"
    init(bundleID: String) {
        let d = ScreenSaverDefaults(forModuleWithName: bundleID)
        d?.register(defaults: [
            "usesSpecificDate": true,
            "targetDate": CountdownEngine.initialTargetDate,
            "countdownLabel": "FREEDOM IN",
            tgifHourKey: 18,
        ])
        self.defaults = d
        self.usesSpecificDate = d?.bool(forKey: "usesSpecificDate") ?? true
        self.targetDate =
            d?.object(forKey: "targetDate") as? Date ?? CountdownEngine.initialTargetDate
        self.countdownLabel = d?.string(forKey: "countdownLabel") ?? "FREEDOM IN"
        self.tgifHour = d?.integer(forKey: "tgifHour") ?? 18
    }

    // Re-read preferences so preview and full-screen instances see Options changes.
    func reload() {
        defaults?.synchronize()
        guard let defaults else { return }
        let mode = defaults.bool(forKey: "usesSpecificDate")
        let date =
            defaults.object(forKey: "targetDate") as? Date ?? CountdownEngine.initialTargetDate
        let label = defaults.string(forKey: "countdownLabel") ?? "FREEDOM IN"
        let hour = defaults.integer(forKey: tgifHourKey)
        if usesSpecificDate != mode { usesSpecificDate = mode }
        if targetDate != date { targetDate = date }
        if countdownLabel != label { countdownLabel = label }
        if tgifHour != hour { tgifHour = hour }
    }

    func save() {
        defaults?.set(usesSpecificDate, forKey: "usesSpecificDate")
        defaults?.set(targetDate, forKey: "targetDate")
        defaults?.set(countdownLabel, forKey: "countdownLabel")
        defaults?.set(tgifHour, forKey: tgifHourKey)
        defaults?.synchronize()
    }
}
