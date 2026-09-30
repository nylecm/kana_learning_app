// swift-tools-version: 6.0
import PackageDescription

/// The SDK version recorded in the binary's `LC_BUILD_VERSION` load command.
///
/// AppKit picks the era of its window chrome — and a number of its other behaviours — from the SDK
/// an app was *linked* against, not from the OS it happens to run on. SwiftPM records the
/// deployment target in that field rather than the SDK it actually compiled with, so with the
/// macOS 14 target below the app keeps the older window controls even on macOS 27.
/// Naming the SDK explicitly fixes that while the deployment target stays at 14.0: an app linked
/// against a newer SDK than it deploys to is the ordinary case for anything built with a current
/// Xcode, and macOS 14 still runs it happily.
///
/// Bump this when you move to a newer Xcode.
let linkedSDKVersion = "27.0"

/// Mirrors `platforms:` below — the linker wants both halves of the platform version.
let macOSDeploymentTarget = "14.0"

let package = Package(
    name: "Kana",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "Kana", targets: ["Kana"])
    ],
    targets: [
        .executableTarget(
            name: "Kana",
            path: "Sources/Kana",
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-platform_version",
                    "-Xlinker", "macos",
                    "-Xlinker", macOSDeploymentTarget,
                    "-Xlinker", linkedSDKVersion,
                ])
            ]
        )
    ],
    // Swift 5 language mode: this app leans on AVSpeechSynthesizer and NSEvent monitors, where
    // Swift 6 strict-concurrency checking adds friction without buying correctness for a
    // single-window, main-actor-only app. All app state is still explicitly @MainActor.
    swiftLanguageModes: [.v5]
)
