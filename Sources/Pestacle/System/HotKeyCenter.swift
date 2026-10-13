import AppKit
import Carbon.HIToolbox
import OSLog
import PestacleCore

/// Raccourcis globaux via Carbon `RegisterEventHotKey` : aucune permission « Surveillance de
/// l'entrée » requise. Un raccourci qu'une autre app détient (`eventHotKeyExistsErr`) est
/// conservé et marqué inactif, puis retenté par `retryInactive()`.
@MainActor
final class HotKeyCenter {
    private let log = Logger(subsystem: "fr.maximebriand.Pestacle", category: "hotkeys")
    private var bindings: [WindowAction: Shortcut] = [:]
    private var registered: [WindowAction: EventHotKeyRef] = [:]
    private var handler: EventHandlerRef?
    private var suspended = false

    /// Appelé quand un raccourci actif est pressé.
    var onTrigger: ((WindowAction) -> Void)?
    /// Appelé quand l'ensemble des raccourcis inactifs change.
    var onStatusChange: (() -> Void)?

    /// Actions dont le raccourci n'a pas pu être activé.
    var inactiveActions: Set<WindowAction> {
        suspended ? [] : Set(bindings.keys).subtracting(registered.keys)
    }

    private var terminationObserver: NSObjectProtocol?

    init() {
        installHandler()
        terminationObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didTerminateApplicationNotification, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.retryInactive() }
        }
    }

    /// Remplace tous les raccourcis. `nil` = action sans raccourci.
    func setBindings(_ newBindings: [WindowAction: Shortcut?]) {
        unregisterAll()
        bindings = newBindings.compactMapValues { $0 }
        if !suspended { registerAll() }
        onStatusChange?()
    }

    /// Suspend tous les raccourcis (pendant l'enregistrement d'un raccourci).
    func suspendAll() {
        guard !suspended else { return }
        suspended = true
        unregisterAll()
    }

    func resumeAll() {
        guard suspended else { return }
        suspended = false
        registerAll()
        onStatusChange?()
    }

    /// Retente les raccourcis inactifs (une app concurrente vient de quitter, réglages ouverts…).
    func retryInactive() {
        guard !suspended else { return }
        let before = inactiveActions
        guard !before.isEmpty else { return }
        for action in before { register(action) }
        if inactiveActions != before { onStatusChange?() }
    }

    // MARK: - Carbon

    private static let signature: OSType = 0x5045_5354 // 'PEST'

    private func registerAll() {
        for action in bindings.keys { register(action) }
    }

    private func register(_ action: WindowAction) {
        guard registered[action] == nil, let shortcut = bindings[action],
              let index = WindowAction.allCases.firstIndex(of: action) else { return }
        var ref: EventHotKeyRef?
        let id = EventHotKeyID(signature: Self.signature, id: UInt32(index))
        let status = RegisterEventHotKey(shortcut.keyCode, shortcut.modifiers.rawValue, id,
                                         GetApplicationEventTarget(), 0, &ref)
        if status == noErr, let ref {
            registered[action] = ref
        } else {
            log.notice("raccourci \(shortcut.description, privacy: .public) de \(action.rawValue, privacy: .public) inactif (\(status))")
        }
    }

    private func unregisterAll() {
        for ref in registered.values { UnregisterEventHotKey(ref) }
        registered.removeAll()
    }

    private func installHandler() {
        var spec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let context = Unmanaged.passUnretained(self).toOpaque()
        InstallEventHandler(GetApplicationEventTarget(), { _, event, context in
            guard let event, let context else { return OSStatus(eventNotHandledErr) }
            var id = EventHotKeyID()
            let status = GetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID),
                                           nil, MemoryLayout<EventHotKeyID>.size, nil, &id)
            guard status == noErr, id.signature == HotKeyCenter.signature,
                  Int(id.id) < WindowAction.allCases.count else { return OSStatus(eventNotHandledErr) }
            let action = WindowAction.allCases[Int(id.id)]
            let center = Unmanaged<HotKeyCenter>.fromOpaque(context).takeUnretainedValue()
            MainActor.assumeIsolated { center.onTrigger?(action) }
            return noErr
        }, 1, &spec, context, &handler)
    }
}
