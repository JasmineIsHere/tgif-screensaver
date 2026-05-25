// swift-tools-version: 5.9
//
// This package exists solely to run unit tests against CountdownEngine
// from the terminal with `swift test`. It has no dependency on Xcode,
// ScreenSaver.framework, or SwiftUI — just plain Foundation.
//
// Run from TheWorkCountdown/:
//   swift test
//
// The source file under Sources/CountdownLogic/ is a copy of
// TgifScreensaver/TgifScreensaver/CountdownEngine.swift.
// If you change the countdown logic, update both files.

import PackageDescription

let package = Package(
    name: "CountdownLogic",
    platforms: [.macOS(.v13)],
    targets: [
        .target(
            name: "CountdownLogic",
            path: "Sources/CountdownLogic"
        ),
        .testTarget(
            name: "CountdownLogicTests",
            dependencies: ["CountdownLogic"],
            path: "Tests/CountdownLogicTests"
        ),
    ]
)
