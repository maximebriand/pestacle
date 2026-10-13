import AppKit
import PestacleCore

/// Icône de barre des menus et menu des actions.
@MainActor
final class StatusMenu: NSObject, NSMenuDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let menu = NSMenu()
    private let perform: (WindowAction) -> Void
    private let shortcuts: () -> [WindowAction: Shortcut?]
    private let inactive: () -> Set<WindowAction>
    var onShowSettings: (() -> Void)?

    init(perform: @escaping (WindowAction) -> Void,
         shortcuts: @escaping () -> [WindowAction: Shortcut?],
         inactive: @escaping () -> Set<WindowAction>) {
        self.perform = perform
        self.shortcuts = shortcuts
        self.inactive = inactive
        super.init()
        statusItem.button?.image = NSImage(systemSymbolName: "rectangle.split.2x1", accessibilityDescription: "Pestacle")
        menu.delegate = self
        menu.autoenablesItems = false
        statusItem.menu = menu
    }

    var isVisible: Bool {
        get { statusItem.isVisible }
        set { statusItem.isVisible = newValue }
    }

    /// Reconstruit le menu à chaque ouverture : raccourcis et disposition clavier toujours à jour.
    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        let current = shortcuts()
        let inactive = inactive()
        let layout = KeyboardLayout.current()
        for group in WindowAction.groups {
            for action in group {
                let item = NSMenuItem(title: action.title, action: #selector(choose(_:)), keyEquivalent: "")
                item.target = self
                item.representedObject = action.rawValue
                if let shortcut = current[action] ?? nil {
                    if inactive.contains(action) {
                        item.badge = NSMenuItemBadge(string: String(localized: "Inactive"))
                        item.toolTip = String(localized: "Another app is using this shortcut.")
                    } else {
                        Self.apply(shortcut, to: item, layout: layout)
                    }
                }
                menu.addItem(item)
            }
            menu.addItem(.separator())
        }
        menu.addItem(item(String(localized: "Settings…"), #selector(showSettings), key: ","))
        menu.addItem(item(String(localized: "About Pestacle"), #selector(showAbout)))
        menu.addItem(.separator())
        menu.addItem(item(String(localized: "Quit Pestacle"), #selector(quit), key: "q"))
    }

    private func item(_ title: String, _ selector: Selector, key: String = "") -> NSMenuItem {
        let item = NSMenuItem(title: title, action: selector, keyEquivalent: key)
        item.target = self
        return item
    }

    @objc private func choose(_ sender: NSMenuItem) {
        guard let raw = sender.representedObject as? String, let action = WindowAction(rawValue: raw) else { return }
        perform(action)
    }

    @objc private func showSettings() { onShowSettings?() }

    @objc private func showAbout() {
        NSApp.activate()
        NSApp.orderFrontStandardAboutPanel(nil)
    }

    @objc private func quit() { NSApp.terminate(nil) }

    // MARK: - Équivalents clavier affichés

    private static func apply(_ shortcut: Shortcut, to item: NSMenuItem, layout: KeyboardLayout.Layout?) {
        guard let key = keyEquivalent(for: shortcut.keyCode, layout: layout) else { return }
        item.keyEquivalent = key
        var flags: NSEvent.ModifierFlags = []
        if shortcut.modifiers.contains(.command) { flags.insert(.command) }
        if shortcut.modifiers.contains(.option) { flags.insert(.option) }
        if shortcut.modifiers.contains(.control) { flags.insert(.control) }
        if shortcut.modifiers.contains(.shift) { flags.insert(.shift) }
        item.keyEquivalentModifierMask = flags
    }

    private static func keyEquivalent(for keyCode: UInt32, layout: KeyboardLayout.Layout?) -> String? {
        let special: [UInt32: Int] = [
            KeyCode.leftArrow: NSLeftArrowFunctionKey, KeyCode.rightArrow: NSRightArrowFunctionKey,
            KeyCode.upArrow: NSUpArrowFunctionKey, KeyCode.downArrow: NSDownArrowFunctionKey,
            117: NSDeleteFunctionKey, 115: NSHomeFunctionKey, 119: NSEndFunctionKey,
            116: NSPageUpFunctionKey, 121: NSPageDownFunctionKey,
            36: 0x0D, 48: 0x09, 49: 0x20, 51: 0x08, 53: 0x1B,
        ]
        if let code = special[keyCode] ?? KeyCode.functionKeys.firstIndex(of: keyCode).map({ NSF1FunctionKey + $0 }),
           let scalar = UnicodeScalar(code) {
            return String(Character(scalar))
        }
        return layout?.character(for: keyCode)?.lowercased()
    }
}
