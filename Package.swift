// swift-tools-version: 5.9
//
// This package exists solely to run unit tests against CountdownEngine
// from the terminal with `swift test`. It has no dependency on Xcode,
// ScreenSaver.framework, or SwiftUI — just plain Foundation.
//
// Run from the project root:
//   swift test
//
// The CountdownLogic target points directly at the canonical Xcode source
// file so there is no duplicate to keep in sync.

import PackageDescription

let package = Package(
    name: "CountdownLogic",
    platforms: [.macOS(.v13)],
    targets: [
        // Point straight at the Xcode source — no copy needed.
        // `exclude` must come before `sources` (SPM manifest requirement).
        // `exclude` silences warnings about the other files in the same directory;
        // `sources` restricts compilation to CountdownEngine.swift only.
        .target(
            name: "CountdownLogic",
            path: "TgifScreensaver/TgifScreensaver",
            exclude: [
                "ClockPreferences.swift",
                "ClockView.swift",
                "DigitGroupView.swift",
                "FlipDigitView.swift",
                "SettingsView.swift",
                "TgifScreensaverView.swift",
                "Info.plist",
            ],
            sources: ["CountdownEngine.swift"]
        ),
        .testTarget(
            name: "CountdownLogicTests",
            dependencies: ["CountdownLogic"],
            path: "Tests/CountdownLogicTests"
        ),
    ]
)
