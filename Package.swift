// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Kana",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "Kana", targets: ["Kana"])
    ],
    targets: [
        .executableTarget(
            name: "Kana",
            path: "Sources/Kana"
        )
    ],
    // Swift 5 language mode: this app leans on AVSpeechSynthesizer and NSEvent monitors, where
    // Swift 6 strict-concurrency checking adds friction without buying correctness for a
    // single-window, main-actor-only app. All app state is still explicitly @MainActor.
    swiftLanguageModes: [.v5]
)
