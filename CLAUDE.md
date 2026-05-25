# Flip Clock Screensaver

## Project Overview
A native macOS screensaver that displays a dynamic flip clock with two modes:
- **Work week mode**: counts down days, hours, minutes and seconds until the user's configured end-of-work time on Friday (TGIF)
- **Weekend mode**: counts down days, hours, minutes and seconds until Monday 00:00 (weekend time remaining)

The clock should feel satisfying to watch — smooth flip animations, 
clean typography, minimal design.

## Scope

### Timezone-aware countdown
The screensaver must count down to the user's **local** Friday end-of-work time, not a fixed UTC time. This is already satisfied by using `Calendar.current` and `Date()` — both respect the device's timezone automatically. No explicit timezone handling is needed; just never hardcode UTC offsets.

### Configurable end-of-work time
Users should be able to set their own TGIF cutoff (default: 18:00). Implementation requires:
- **`UserDefaults` storage** — store the chosen hour (integer 0–23) under a namespaced key (e.g. `com.flipclock.tgifHour`). `ScreenSaverDefaults` (a subclass of `UserDefaults` scoped to the bundle identifier) is the correct API for screensavers.
- **Settings sheet** — implement `hasConfigureSheet = true` and `configureSheet` in `FlipClockScreensaverView`. The sheet is an `NSWindow` containing a SwiftUI view with a simple time picker.
- **`CountdownEngine` update** — `countdownToTGIF(from:weekday:calendar:)` currently hardcodes hour `18`. Change its signature to accept a `tgifHour: Int` parameter so the engine stays pure and testable.
- **`ClockView` update** — read the stored preference on appear and pass it down to the engine.

## Tech Stack
- Language: Swift
- UI Framework: SwiftUI
- Target: macOS screensaver (.saver bundle)
- Framework: ScreenSaver.framework (Apple)
- Build Tool: Xcode

## Project Owner
I am a software engineer who is not familiar with Swift or SwiftUI.
Explain Swift/SwiftUI-specific decisions clearly, as if to someone 
who understands programming concepts but is new to the Apple ecosystem.
Always explain what a piece of code does before writing it.

## Agent Roles
This project uses specialised agents. Always stay within your assigned scope:
- Swift Agent: core logic, data types, timers, state management
- SwiftUI Agent: all UI components, layout, typography, colour
- macOS Agent: ScreenSaver.framework integration, bundling, code signing
- QA Agent: testing, bug identification, improvement suggestions

## Coding Conventions
- Prefer readability over cleverness — this is a learning project
- Add comments explaining the why, not just the what
- Keep files small and single-purpose
- Use SwiftUI previews wherever possible so UI can be checked without running the full screensaver
- Commit working code only — no half-finished code in main

## Architecture
- Separate UI (SwiftUI views) from logic (countdown calculation, timer)
- The flip animation should be its own reusable component
- Countdown logic should be pure and testable in isolation

## What NOT To Do
- Do not use AppKit directly unless ScreenSaver.framework absolutely requires it
- Do not put business logic inside SwiftUI views
- Do not skip comments — this is a learning project and context matters
- Do not assume I know Swift syntax — always explain new patterns when introduced

## Current Focus
- Completed.

## Known Constraints
- Must run on macOS only
- Should work on macOS Ventura and above
- No internet connection required — all logic is local
- Machine architecture: Apple Silicon (arm64)
- Swift version: 6.3.2

## Context Preservation Rules

These rules apply continuously throughout every session, 
not just at the end.

### After every completed task:
- Update .claude/handoff.md with what was just completed
  and what the next step is
- If a decision was made, log it immediately in .claude/decisions.md
- If a new constraint or rule was discovered, add it to CLAUDE.md

### After every failed attempt:
- Log what was tried and why it didn't work in .claude/decisions.md
  under a "Dead Ends" section — this stops the same mistake 
  being repeated in a new session

### Definition of "completed task":
A task is complete when:
- Code is written and working
- handoff.md is updated
- Any decisions made are logged