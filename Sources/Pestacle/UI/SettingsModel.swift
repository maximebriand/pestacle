import AppKit
import Observation
import PestacleCore

/// État affiché par la fenêtre de réglages. Les modifications passent par `AppController`
/// (via les fermetures), qui les applique immédiatement et les persiste.
@MainActor
@Observable
final class SettingsModel {
    var shortcuts: [WindowAction: Shortcut?] = [:]
    var inactive: Set<WindowAction> = []
    var cyclesSizes = true
    var showsMenuBarIcon = true
    var loginItem: LoginItem.State = .disabled
    var canImportFromSpectacle = false
    /// Incrémenté au changement de disposition clavier, pour recalculer les libellés.
    var layoutGeneration = 0

    /// Action dont le raccourci est en cours d'enregistrement.
    private(set) var recording: WindowAction?
    /// Message d'erreur de la dernière saisie, par action.
    var errors: [WindowAction: String] = [:]
    var notice: String?

    @ObservationIgnored var assign: (Shortcut?, WindowAction) -> ShortcutValidation = { _, _ in .valid }
    @ObservationIgnored var resetDefaults: () -> Void = {}
    @ObservationIgnored var importFromSpectacle: () -> Bool = { false }
    @ObservationIgnored var setCyclesSizes: (Bool) -> Void = { _ in }
    @ObservationIgnored var setShowsMenuBarIcon: (Bool) -> Void = { _ in }
    @ObservationIgnored var setLoginItem: (Bool) -> LoginItem.State = { _ in .disabled }
    @ObservationIgnored var openLoginItemsSettings: () -> Void = {}
    @ObservationIgnored var suspendShortcuts: () -> Void = {}
    @ObservationIgnored var resumeShortcuts: () -> Void = {}

    @ObservationIgnored private var monitor: Any?
    @ObservationIgnored private var systemHotKeysToken: UnsafeMutableRawPointer?

    func label(for action: WindowAction) -> String? {
        _ = layoutGeneration
        guard let shortcut = shortcuts[action] ?? nil else { return nil }
        return KeyboardLayout.label(for: shortcut)
    }

    // MARK: - Enregistrement d'un raccourci

    /// Pendant la saisie, les raccourcis de Pestacle et ceux du système sont suspendus :
    /// ⌥⌘← ne déplace aucune fenêtre et ⌃↑ n'ouvre pas Mission Control.
    func startRecording(_ action: WindowAction) {
        stopRecording()
        recording = action
        errors[action] = nil
        suspendShortcuts()
        systemHotKeysToken = SystemShortcuts.beginRecording()
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            MainActor.assumeIsolated { self?.handle(event) }
            return nil
        }
    }

    /// Termine la saisie, y compris en cas d'annulation ou de fermeture de la fenêtre.
    func stopRecording() {
        if let monitor { NSEvent.removeMonitor(monitor) }
        monitor = nil
        if recording != nil {
            SystemShortcuts.endRecording(token: systemHotKeysToken)
            systemHotKeysToken = nil
            resumeShortcuts()
        }
        recording = nil
    }

    private func handle(_ event: NSEvent) {
        guard let action = recording else { return }
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        var modifiers: Modifiers = []
        if flags.contains(.command) { modifiers.insert(.command) }
        if flags.contains(.option) { modifiers.insert(.option) }
        if flags.contains(.control) { modifiers.insert(.control) }
        if flags.contains(.shift) { modifiers.insert(.shift) }
        let keyCode = UInt32(event.keyCode)

        if modifiers.isEmpty && keyCode == KeyCode.escape {
            stopRecording()
            return
        }
        if modifiers.isEmpty && (keyCode == 51 || keyCode == 117) {
            stopRecording()
            _ = assign(nil, action)
            return
        }
        let result = assign(Shortcut(keyCode: keyCode, modifiers: modifiers), action)
        switch result {
        case .valid:
            stopRecording()
        case .missingModifier:
            errors[action] = String(localized: "Use at least one of ⌘, ⌥ or ⌃, or a function key.")
            stopRecording()
        case .conflict(let other):
            errors[action] = String(localized: "Already used by “\(other.title)”.")
            stopRecording()
        case .reservedBySystem:
            errors[action] = String(localized: "This shortcut is reserved by macOS. You can change it in System Settings › Keyboard › Keyboard Shortcuts.")
            stopRecording()
        }
    }
}
