#if DEBUG
import AppKit
import PestacleCore

/// Canal de commande réservé aux builds Debug, pour la recette automatisée
/// (`scripts/pestacle-debug`). Requête et réponse passent par des notifications distribuées.
@MainActor
final class DebugChannel {
    static let shared = DebugChannel()
    static let request = Notification.Name("fr.maximebriand.Pestacle.debug.request")
    static let reply = Notification.Name("fr.maximebriand.Pestacle.debug.reply")

    private weak var controller: AppController?
    private var observer: NSObjectProtocol?

    func attach(to controller: AppController) {
        self.controller = controller
        observer = DistributedNotificationCenter.default().addObserver(forName: Self.request, object: nil, queue: .main) { note in
            let id = note.userInfo?["id"] as? String ?? ""
            let command = note.userInfo?["command"] as? String ?? ""
            MainActor.assumeIsolated {
                let output = DebugChannel.shared.run(command)
                DistributedNotificationCenter.default().postNotificationName(
                    Self.reply, object: nil, userInfo: ["id": id, "output": output], deliverImmediately: true)
            }
        }
    }

    private func run(_ command: String) -> String {
        guard let controller else { return "erreur : pas de contrôleur" }
        let words = command.split(separator: " ").map(String.init)
        switch words.first {
        case "perform":
            guard words.count == 2, let action = WindowAction(rawValue: words[1]) else { return "erreur : action inconnue" }
            let outcome = controller.coordinator.perform(action)
            let timing = controller.coordinator.lastTimeToFirstWrite.map {
                " en \(String(format: "%.2f", Double($0.components.attoseconds) / 1e15 + Double($0.components.seconds) * 1000)) ms"
            } ?? ""
            return "\(outcome)\(timing)"
        case "frame":
            switch AccessibilityWindowSource().focusedWindow() {
            case .success(let w): return (try? w.frame().description) ?? "erreur : cadre illisible"
            case .failure(let f): return "échec : \(f)"
            }
        case "setframe":
            let n = words.dropFirst().compactMap(Double.init)
            guard n.count == 4 else { return "usage : setframe x y w h" }
            switch AccessibilityWindowSource().focusedWindow() {
            case .success(let w):
                return (try? w.setFrame(Rect(x: n[0], y: n[1], width: n[2], height: n[3])).description) ?? "erreur"
            case .failure(let f): return "échec : \(f)"
            }
        case "screens":
            return controller.screens.screens.map { "\($0.id) cadre \($0.frame) utile \($0.visibleFrame)" }.joined(separator: "\n")
        case "state":
            let front = NSWorkspace.shared.frontmostApplication?.bundleIdentifier ?? "?"
            let inactive = controller.hotKeys.inactiveActions.map(\.rawValue).sorted().joined(separator: ",")
            let labels = WindowAction.allCases.map { a in
                "\(a.rawValue)=\((controller.shortcuts[a] ?? nil).map { KeyboardLayout.label(for: $0) } ?? "—")"
            }
            return (["trusted=\(controller.permission.refresh())", "front=\(front)", "inactive=\(inactive)"] + labels)
                .joined(separator: "\n")
        case "key":
            // key <keyCode> [cmd] [alt] [ctrl] [shift] : simule un appui réel, qui passe par le système.
            guard words.count >= 2, let code = UInt16(words[1]) else { return "usage : key <code> [cmd alt ctrl shift]" }
            var flags: CGEventFlags = []
            for w in words.dropFirst(2) {
                switch w {
                case "cmd": flags.insert(.maskCommand)
                case "alt": flags.insert(.maskAlternate)
                case "ctrl": flags.insert(.maskControl)
                case "shift": flags.insert(.maskShift)
                default: break
                }
            }
            let source = CGEventSource(stateID: .hidSystemState)
            for down in [true, false] {
                guard let event = CGEvent(keyboardEventSource: source, virtualKey: code, keyDown: down) else { continue }
                // Garder les drapeaux posés par le système (pavé numérique et fn pour les flèches).
                event.flags = event.flags.union(flags)
                event.post(tap: .cghidEventTap)
            }
            return "posté"
        case "initial-shortcuts":
            return "import : \(controller.assignInitialShortcuts())"
        case "loc":
            return [WindowAction.center.title, WindowAction.undo.title, String(localized: "Settings…")].joined(separator: " | ")
        case "settings":
            controller.showSettings()
            return "réglages ouverts"
        default:
            return "commandes : perform <Action> | frame | setframe x y w h | screens | state | key <code> [mods] | settings"
        }
    }
}
#endif
