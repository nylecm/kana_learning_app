import AppKit
import Foundation

/// A key press translated from an `NSEvent`.
enum KeyPress: Equatable {
    case space
    case enter
    case escape
    case left
    case right
    case up
    case down
    case character(Character)
}

/// One app-wide key monitor (spec.md §6).
///
/// A *local* monitor sees events already routed to this app, so it needs no accessibility
/// permission. It stands down entirely while a text field is the first responder, which keeps
/// typing mode usable, and ignores anything with ⌘/⌃/⌥ so menu shortcuts still work.
@MainActor
final class KeyRouter {
    private var monitor: Any?
    private weak var model: AppModel?

    init(model: AppModel) {
        self.model = model
    }

    func install() {
        guard monitor == nil else { return }
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self, let model = self.model else { return event }
            guard !KeyRouter.isTyping else { return event }

            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            guard !flags.contains(.command),
                  !flags.contains(.control),
                  !flags.contains(.option) else { return event }

            guard let press = KeyRouter.press(for: event) else { return event }
            return model.handleKey(press) ? nil : event
        }
    }

    func uninstall() {
        if let monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }

    private static var isTyping: Bool {
        guard let responder = NSApp.keyWindow?.firstResponder else { return false }
        return responder is NSTextView || responder is NSTextField
    }

    private static func press(for event: NSEvent) -> KeyPress? {
        switch event.keyCode {
        case 49: return .space
        case 36, 76: return .enter
        case 53: return .escape
        case 123: return .left
        case 124: return .right
        case 125: return .down
        case 126: return .up
        default: break
        }

        guard let characters = event.charactersIgnoringModifiers,
              let first = characters.first,
              first.isLetter || first.isNumber
        else { return nil }

        return .character(Character(String(first).lowercased()))
    }
}
