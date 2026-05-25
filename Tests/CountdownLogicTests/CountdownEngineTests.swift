import XCTest
import Foundation
@testable import CountdownLogic

// Helper: build a specific Date from components without boilerplate.
// If the components are invalid (e.g. month 13), the test will crash — that's intentional.
private func makeDate(year: Int, month: Int, day: Int,
                      hour: Int = 0, minute: Int = 0, second: Int = 0) -> Date {
    var c = DateComponents()
    c.year = year; c.month = month; c.day = day
    c.hour = hour; c.minute = minute; c.second = second
    return Calendar.current.date(from: c)!
}

final class CountdownEngineTests: XCTestCase {

    // MARK: - Phase detection

    // Monday should be work-week phase (counting down to TGIF).
    func testMonday_isToTGIF() {
        // 2026-01-05 is a Monday.
        let monday = makeDate(year: 2026, month: 1, day: 5, hour: 9)
        let result = CountdownEngine.currentCountdown(from: monday)
        XCTAssertEqual(result.phase, .toTGIF)
    }

    // Thursday should be work-week phase.
    func testThursday_isToTGIF() {
        // 2026-01-08 is a Thursday.
        let thursday = makeDate(year: 2026, month: 1, day: 8, hour: 14)
        let result = CountdownEngine.currentCountdown(from: thursday)
        XCTAssertEqual(result.phase, .toTGIF)
    }

    // Friday before 18:00 is still work-week phase.
    func testFriday_before18_isToTGIF() {
        // 2026-01-09 is a Friday.
        let friday = makeDate(year: 2026, month: 1, day: 9, hour: 17, minute: 59, second: 59)
        let result = CountdownEngine.currentCountdown(from: friday)
        XCTAssertEqual(result.phase, .toTGIF)
    }

    // Friday at exactly 18:00 flips to weekend phase.
    func testFriday_at18_isToMonday() {
        let friday6pm = makeDate(year: 2026, month: 1, day: 9, hour: 18, minute: 0, second: 0)
        let result = CountdownEngine.currentCountdown(from: friday6pm)
        XCTAssertEqual(result.phase, .toMonday)
    }

    // Friday after 18:00 is weekend phase.
    func testFriday_after18_isToMonday() {
        let friday = makeDate(year: 2026, month: 1, day: 9, hour: 20)
        let result = CountdownEngine.currentCountdown(from: friday)
        XCTAssertEqual(result.phase, .toMonday)
    }

    // Saturday is always weekend phase.
    func testSaturday_isToMonday() {
        let saturday = makeDate(year: 2026, month: 1, day: 10, hour: 12)
        let result = CountdownEngine.currentCountdown(from: saturday)
        XCTAssertEqual(result.phase, .toMonday)
    }

    // Sunday is always weekend phase.
    func testSunday_isToMonday() {
        let sunday = makeDate(year: 2026, month: 1, day: 11, hour: 12)
        let result = CountdownEngine.currentCountdown(from: sunday)
        XCTAssertEqual(result.phase, .toMonday)
    }

    // MARK: - Days remaining

    // On Monday, there are 4 days until Friday.
    func testMonday_4DaysToTGIF() {
        let monday = makeDate(year: 2026, month: 1, day: 5, hour: 0, minute: 0, second: 0)
        let result = CountdownEngine.currentCountdown(from: monday)
        XCTAssertEqual(result.days, 4)
    }

    // On Wednesday midday, 2 days remain (the countdown spans Wed noon → Fri 18:00,
    // which is > 48 hours, so days = 2).
    func testWednesday_2DaysToTGIF() {
        let wednesday = makeDate(year: 2026, month: 1, day: 7, hour: 12)
        let result = CountdownEngine.currentCountdown(from: wednesday)
        XCTAssertEqual(result.days, 2)
    }

    // On Friday at 17:00, 0 days remain (just under 1 hour to go).
    func testFriday17_0DaysToTGIF() {
        let friday = makeDate(year: 2026, month: 1, day: 9, hour: 17)
        let result = CountdownEngine.currentCountdown(from: friday)
        XCTAssertEqual(result.days, 0)
    }

    // On Saturday noon, 1 day + 12 hours remain until Monday 00:00.
    func testSaturdayNoon_1DayToMonday() {
        let saturday = makeDate(year: 2026, month: 1, day: 10, hour: 12)
        let result = CountdownEngine.currentCountdown(from: saturday)
        XCTAssertEqual(result.days, 1)
        XCTAssertEqual(result.hours, 12)
    }

    // On Sunday, 0 days remain (less than 24 h to Monday).
    func testSunday_0DaysToMonday() {
        let sunday = makeDate(year: 2026, month: 1, day: 11, hour: 6)
        let result = CountdownEngine.currentCountdown(from: sunday)
        XCTAssertEqual(result.days, 0)
    }

    // MARK: - Precision

    // Friday 17:59:01 → 59 seconds to go (18:00:00 − 17:59:01 = 59 s).
    func testFriday_nearMidnight_precision() {
        let friday = makeDate(year: 2026, month: 1, day: 9, hour: 17, minute: 59, second: 1)
        let result = CountdownEngine.currentCountdown(from: friday)
        XCTAssertEqual(result.days,    0)
        XCTAssertEqual(result.hours,   0)
        XCTAssertEqual(result.minutes, 0)
        XCTAssertEqual(result.seconds, 59)
    }

    // Sunday 23:59:01 → 59 seconds to Monday.
    func testSunday_nearMidnight_precision() {
        let sunday = makeDate(year: 2026, month: 1, day: 11, hour: 23, minute: 59, second: 1)
        let result = CountdownEngine.currentCountdown(from: sunday)
        XCTAssertEqual(result.days,    0)
        XCTAssertEqual(result.hours,   0)
        XCTAssertEqual(result.minutes, 0)
        XCTAssertEqual(result.seconds, 59)
    }

    // MARK: - Configurable tgifHour

    // A user who finishes at 17:00 should still be in work-week phase at 16:59.
    func testCustomTGIFHour_before_isToTGIF() {
        let friday = makeDate(year: 2026, month: 1, day: 9, hour: 16, minute: 59)
        let result = CountdownEngine.currentCountdown(from: friday, tgifHour: 17)
        XCTAssertEqual(result.phase, .toTGIF)
    }

    // A user who finishes at 17:00 should flip to weekend at exactly 17:00.
    func testCustomTGIFHour_at_isToMonday() {
        let friday = makeDate(year: 2026, month: 1, day: 9, hour: 17, minute: 0)
        let result = CountdownEngine.currentCountdown(from: friday, tgifHour: 17)
        XCTAssertEqual(result.phase, .toMonday)
    }

    // The countdown target should reflect the custom hour, not the default 18:00.
    // Monday 09:00 with tgifHour=17 → target is Friday 17:00 = 4d 8h away.
    func testCustomTGIFHour_countdownTarget() {
        let monday = makeDate(year: 2026, month: 1, day: 5, hour: 9, minute: 0, second: 0)
        let result = CountdownEngine.currentCountdown(from: monday, tgifHour: 17)
        XCTAssertEqual(result.phase, .toTGIF)
        XCTAssertEqual(result.days,  4)
        XCTAssertEqual(result.hours, 8)
        XCTAssertEqual(result.minutes, 0)
        XCTAssertEqual(result.seconds, 0)
    }

    // MARK: - TimeRemaining.fromSeconds decomposition

    // 90 061 seconds = 1 day, 1 hour, 1 minute, 1 second.
    func testFromSeconds_decomposition() {
        let t = TimeRemaining.fromSeconds(90_061, phase: .toTGIF)
        XCTAssertEqual(t.days,    1)
        XCTAssertEqual(t.hours,   1)
        XCTAssertEqual(t.minutes, 1)
        XCTAssertEqual(t.seconds, 1)
    }

    // 0 seconds → all zeros.
    func testFromSeconds_zero() {
        let t = TimeRemaining.fromSeconds(0, phase: .toMonday)
        XCTAssertEqual(t.days,    0)
        XCTAssertEqual(t.hours,   0)
        XCTAssertEqual(t.minutes, 0)
        XCTAssertEqual(t.seconds, 0)
    }

    // 86 399 seconds = 0 days, 23 hours, 59 minutes, 59 seconds.
    func testFromSeconds_almostOneDay() {
        let t = TimeRemaining.fromSeconds(86_399, phase: .toTGIF)
        XCTAssertEqual(t.days,    0)
        XCTAssertEqual(t.hours,   23)
        XCTAssertEqual(t.minutes, 59)
        XCTAssertEqual(t.seconds, 59)
    }
}
