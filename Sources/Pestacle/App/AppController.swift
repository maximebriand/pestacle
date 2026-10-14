import AppKit
import OSLog
import PestacleCore

/// Assemble les composants et applique les préférences.
@MainActor
final class AppController: ActionFeedback {
    private let log = Logger(subsystem: "fr.maximebriand.Pestacle", category: "app")
    let preferences: Preferences
    let screens = ScreenProvider()
    let permission = PermissionMonitor()
    let hotKeys = HotKeyCenter()
    let keyboard = KeyboardLayout()
    let lifetime = WindowLifetimeObserver()
    let settingsModel = SettingsModel()

    private(set) lazy var coordinator = ActionCoordinator(
        windows: AccessibilityWindowSource(), screens: screens,
        isTrusted: { [unowned self] in permission.refresh() },
        feedback: self,
        options: { [unowned self] in LayoutOptions(cyclesSizes: preferences.cyclesSizes) })

    private(set) lazy var statusMenu = StatusMenu(
        perform: { [unowned self] in coordinator.perform($0) },
        shortcuts: { [unowned self] in shortcuts },
        inactive: { [unowned self] in hotKeys.inactiveActions })

    private(set) lazy var permissionWindow = PermissionWindow { [unowned self] in permission.openSystemSettings() }
    private(set) lazy var settingsWindow = SettingsWindow(model: settingsModel)

    init(preferences: Preferences = Preferences()) {
        self.preferences = preferences
    }

    /// Défauts de Spectacle, lettres résolues selon la disposition clavier active.
    var defaultShortcuts: [WindowAction: Shortcut] {
        let layout = KeyboardLayout.current()
        return DefaultShortcuts.resolved { layout?.keyCode(for: $0) }
    }

    var shortcuts: [WindowAction: Shortcut?] {
        preferences.shortcuts(defaults: defaultShortcuts)
    }

    // MARK: - Démarrage

    func start() {
        let imported = completeFirstLaunchIfNeeded()
        preferences.migrateShortcuts(defaults: defaultShortcuts)

        hotKeys.onTrigger = { [unowned self] in coordinator.perform($0) }
        hotKeys.onStatusChange = { [unowned self] in refreshSettings() }
        hotKeys.setBindings(shortcuts)

        coordinator.onTrack = { [unowned self] in lifetime.track($0) }
        lifetime.onWindowClosed = { [unowned self] in coordinator.forget($0) }
        lifetime.onAppTerminated = { [unowned self] in coordinator.forget(pid: $0) }

        keyboard.onChange = { [unowned self] in settingsModel.layoutGeneration += 1 }

        statusMenu.onShowSettings = { [unowned self] in showSettings() }
        statusMenu.isVisible = preferences.showsMenuBarIcon
        bindSettings()

        permission.onChange = { [unowned self] trusted in
            if trusted { permissionWindow.close() }
        }
        permission.start()
        if !permission.isTrusted { permissionWindow.show() }

        announceSpectacle(imported: imported)
    }

    /// Premier lancement : reprend les raccourcis de Spectacle s'ils existent, sinon fige les
    /// défauts résolus selon la disposition du moment. Renvoie vrai si un import a eu lieu.
    private func completeFirstLaunchIfNeeded() -> Bool {
        guard !preferences.didCompleteFirstLaunch else { return false }
        defer { preferences.didCompleteFirstLaunch = true }
        return assignInitialShortcuts()
    }

    /// Défauts adaptés à la disposition, complétés des personnalisations Spectacle.
    @discardableResult
    func assignInitialShortcuts() -> Bool {
        var table = defaultShortcuts.mapValues { Optional($0) }
        let imported = Spectacle.importedShortcuts()
        if let imported { table.merge(imported) { _, new in new } }
        preferences.storedShortcuts = table
        hotKeys.setBindings(shortcuts)
        log.notice("raccourcis initiaux, import Spectacle : \(imported != nil)")
        return imported != nil
    }

    private func announceSpectacle(imported: Bool) {
        let running = !Spectacle.runningInstances.isEmpty
        guard imported || running else { return }
        let alert = NSAlert()
        alert.messageText = running ? String(localized: "Spectacle is running") : String(localized: "Spectacle shortcuts imported")
        var text: [String] = []
        if imported { text.append(String(localized: "Your Spectacle shortcuts have been imported.")) }
        if running {
            text.append(String(localized: "Spectacle and Pestacle use the same shortcuts, so only one of them can respond. Quit Spectacle so that Pestacle can take over?"))
            alert.addButton(withTitle: String(localized: "Quit Spectacle"))
            alert.addButton(withTitle: String(localized: "Keep Spectacle Open"))
        }
        alert.informativeText = text.joined(separator: "\n\n")
        NSApp.activate()
        if alert.runModal() == .alertFirstButtonReturn && running {
            Spectacle.quit()
        }
    }

    // MARK: - Réglages

    func showSettings() {
        settingsWindow.show()
    }

    /// Relancer l'app alors que l'icône est masquée ouvre les réglages.
    func handleReopen() {
        showSettings()
    }

    private func refreshSettings() {
        let m = settingsModel
        m.shortcuts = shortcuts
        m.inactive = hotKeys.inactiveActions
        m.cyclesSizes = preferences.cyclesSizes
        m.showsMenuBarIcon = preferences.showsMenuBarIcon
        m.canImportFromSpectacle = FileManager.default.isReadableFile(atPath: Spectacle.shortcutsFile.path)
    }

    private func applyShortcuts() {
        hotKeys.setBindings(shortcuts)
        refreshSettings()
    }

    private func bindSettings() {
        let m = settingsModel
        m.assign = { [unowned self] shortcut, action in
            if let shortcut {
                let assignments = shortcuts.compactMapValues { $0 }
                let result = ShortcutValidator.validate(shortcut, for: action, assignments: assignments,
                                                        systemShortcuts: SystemShortcuts.active())
                guard result == .valid else { return result }
            }
            preferences.setShortcut(shortcut, for: action)
            applyShortcuts()
            return .valid
        }
        m.resetDefaults = { [unowned self] in
            preferences.storedShortcuts = defaultShortcuts.mapValues { Optional($0) }
            applyShortcuts()
        }
        m.importFromSpectacle = { [unowned self] in
            guard let imported = Spectacle.importedShortcuts() else { return false }
            var stored = defaultShortcuts.mapValues { Optional($0) }
            stored.merge(imported) { _, new in new }
            preferences.storedShortcuts = stored
            applyShortcuts()
            return true
        }
        m.setCyclesSizes = { [unowned self] in
            preferences.cyclesSizes = $0
            refreshSettings()
        }
        m.setShowsMenuBarIcon = { [unowned self] in
            preferences.showsMenuBarIcon = $0
            statusMenu.isVisible = $0
            refreshSettings()
        }
        m.setLoginItem = { LoginItem.setEnabled($0) }
        m.openLoginItemsSettings = { LoginItem.openSystemSettings() }
        m.suspendShortcuts = { [unowned self] in hotKeys.suspendAll() }
        m.resumeShortcuts = { [unowned self] in hotKeys.resumeAll() }
        settingsWindow.onOpen = { [unowned self] in
            hotKeys.retryInactive()
            settingsModel.loginItem = LoginItem.state
            settingsModel.notice = nil
            refreshSettings()
        }
        refreshSettings()
    }

    // MARK: - ActionFeedback

    func beep() { NSSound.beep() }

    func explainPermission() { permissionWindow.show() }
}
