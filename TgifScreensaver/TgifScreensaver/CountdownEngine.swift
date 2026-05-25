import Foundation

// Which countdown is currently active.
// The UI uses this to show different messaging for each phase.
enum CountdownPhase {
    case toTGIF     // Work week: counting down to Friday 18:00
    case toMonday   // Weekend: counting down to Monday 00:00
}

// TimeRemaining holds the countdown broken into its four display units,
// plus which phase we're in so the UI knows what message to show.
struct TimeRemaining {
    let days: Int
    let hours: Int
    let minutes: Int
    let seconds: Int
    let phase: CountdownPhase
}

// CountdownEngine is a pure calculation module — no UI, no timers, no side effects.
// Every function takes a date as input and returns a value, making it easy to test
// by passing any fake date you want.
struct CountdownEngine {

    // Returns the active countdown for right now.
    // `tgifHour` is the hour (0–23) at which the weekend phase begins on Friday.
    // Passing a custom `now` is only needed for testing; normal callers use the defaults.
    static func currentCountdown(from now: Date = Date(), tgifHour: Int = 18) -> TimeRemaining {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: now)
        // weekday values: 1=Sun, 2=Mon, 3=Tue, 4=Wed, 5=Thu, 6=Fri, 7=Sat

        // Weekend phase: Friday at or after tgifHour, all of Saturday, all of Sunday.
        // Work week phase: Monday through Thursday, and Friday before tgifHour.
        let inWeekendPhase: Bool
        switch weekday {
        case 7, 1:  // Saturday or Sunday — always weekend phase
            inWeekendPhase = true
        case 6:     // Friday — depends on whether we've passed tgifHour
            let hour = calendar.component(.hour, from: now)
            inWeekendPhase = hour >= tgifHour
        default:    // Monday (2) through Thursday (5)
            inWeekendPhase = false
        }

        return inWeekendPhase
            ? countdownToMonday(from: now, weekday: weekday, calendar: calendar)
            : countdownToTGIF(from: now, weekday: weekday, calendar: calendar, tgifHour: tgifHour)
    }

    // MARK: - Private helpers

    // Calculates time remaining until Friday at tgifHour:00:00.
    private static func countdownToTGIF(
        from now: Date, weekday: Int, calendar: Calendar, tgifHour: Int
    ) -> TimeRemaining {
        let startOfToday = calendar.startOfDay(for: now)

        // How many days until Friday?
        // Mon(2)→4, Tue(3)→3, Wed(4)→2, Thu(5)→1, Fri before tgifHour(6)→0
        let daysToFriday = 6 - weekday

        guard
            let friday = calendar.date(byAdding: .day, value: daysToFriday, to: startOfToday),
            // bySettingHour creates a new Date on the same day but at tgifHour:00:00 exactly
            let fridayAtTGIF = calendar.date(bySettingHour: tgifHour, minute: 0, second: 0, of: friday)
        else {
            return .zero(phase: .toTGIF)
        }

        let totalSeconds = Int(fridayAtTGIF.timeIntervalSince(now))
        guard totalSeconds > 0 else { return .zero(phase: .toTGIF) }
        return .fromSeconds(totalSeconds, phase: .toTGIF)
    }

    // Calculates time remaining until Monday at 00:00:00 (start of Monday).
    private static func countdownToMonday(
        from now: Date, weekday: Int, calendar: Calendar
    ) -> TimeRemaining {
        let startOfToday = calendar.startOfDay(for: now)

        // Days to next Monday using modular arithmetic:
        // Fri(6)→3, Sat(7)→2, Sun(1)→1
        let daysToMonday = (2 - weekday + 7) % 7

        guard let monday = calendar.date(byAdding: .day, value: daysToMonday, to: startOfToday) else {
            return .zero(phase: .toMonday)
        }

        let totalSeconds = Int(monday.timeIntervalSince(now))
        guard totalSeconds > 0 else { return .zero(phase: .toMonday) }
        return .fromSeconds(totalSeconds, phase: .toMonday)
    }
}

// MARK: - TimeRemaining convenience constructors

extension TimeRemaining {

    // All-zero value — used when the countdown has expired or a date calculation fails.
    static func zero(phase: CountdownPhase) -> TimeRemaining {
        TimeRemaining(days: 0, hours: 0, minutes: 0, seconds: 0, phase: phase)
    }

    // Breaks a raw total-seconds value into days/hours/minutes/seconds.
    // Example: 90061 seconds → 1d 1h 1m 1s
    static func fromSeconds(_ total: Int, phase: CountdownPhase) -> TimeRemaining {
        TimeRemaining(
            days:    total / 86400,           // 86400 = 60 * 60 * 24
            hours:   (total % 86400) / 3600,
            minutes: (total % 3600)  / 60,
            seconds:  total % 60,
            phase: phase
        )
    }
}
