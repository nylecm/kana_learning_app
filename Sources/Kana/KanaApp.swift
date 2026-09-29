import AppKit
import SwiftUI

/// Entry point. `--verify-data` short-circuits into the dataset check so the content tables can be
/// validated from the command line without opening a window.
@main
enum KanaMain {
    static func main() {
        if CommandLine.arguments.contains("--verify-data") {
            exit(DataVerifier.run() ? 0 : 1)
        }
        KanaApp.main()
    }
}

struct KanaApp: App {
    @State private var model = AppModel()
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate

    var body: some Scene {
        Window("Kana", id: "main") {
            RootView()
                .environment(model)
                .onAppear { model.start() }
        }
        .defaultSize(width: 1080, height: 740)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Session") { model.startSession() }
                    .keyboardShortcut("n", modifiers: .command)
                    .disabled(!model.canStart)
            }

            CommandGroup(replacing: .appSettings) {
                Button("Settings…") { model.tab = .settings }
                    .keyboardShortcut(",", modifiers: .command)
            }

            CommandGroup(after: .toolbar) {
                Divider()
                Button("Study") { model.tab = .study }
                    .keyboardShortcut("1", modifiers: .command)
                Button("Progress") { model.tab = .progress }
                    .keyboardShortcut("2", modifiers: .command)
                Button("Settings") { model.tab = .settings }
                    .keyboardShortcut("3", modifiers: .command)

                Divider()
                Button("Select All Kana") { model.selectAllInChartScript() }
                    .keyboardShortcut("a", modifiers: .command)
                    .disabled(model.tab != .study || model.scope != .selected || model.session != nil)
                Button("Clear Selection") { model.clearSelection() }
                    .keyboardShortcut("a", modifiers: [.command, .shift])
                    .disabled(model.tab != .study || model.scope != .selected || model.session != nil)

                Divider()
                Toggle("Study Ahead (ignore due dates)", isOn: Binding(
                    get: { model.ignoreDue },
                    set: { model.ignoreDue = $0 }
                ))
                .keyboardShortcut("s", modifiers: [.command, .shift])
            }
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Makes `swift run Kana` behave like the bundled app: regular app, window in front.
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
