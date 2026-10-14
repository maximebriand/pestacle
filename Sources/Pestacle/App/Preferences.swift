import Foundation
import PestacleCore

/// Préférences persistées dans `UserDefaults`.
///
/// Les raccourcis sont enregistrés en entier au premier lancement (défauts résolus selon la
/// disposition clavier du moment, ou import Spectacle) : changer de disposition ensuite ne
/// déplace pas un raccourci de touche physique. Une action absente de la table (ajoutée par
/// une version ultérieure) reçoit son défaut ; `null` signifie « effacé ».
@MainActor
final class Preferences {
    private let store: UserDefaults

    private enum Key {
        static let shortcuts = "shortcuts"
        static let cyclesSizes = "cyclesSizes"
        static let showsMenuBarIcon = "showsMenuBarIcon"
        static let didCompleteFirstLaunch = "didCompleteFirstLaunch"
        static let shortcutsSchema = "shortcutsSchema"
    }

    init(store: UserDefaults = .standard) {
        self.store = store
        store.register(defaults: [Key.cyclesSizes: true, Key.showsMenuBarIcon: true])
    }

    var cyclesSizes: Bool {
        get { store.bool(forKey: Key.cyclesSizes) }
        set { store.set(newValue, forKey: Key.cyclesSizes) }
    }

    var showsMenuBarIcon: Bool {
        get { store.bool(forKey: Key.showsMenuBarIcon) }
        set { store.set(newValue, forKey: Key.showsMenuBarIcon) }
    }

    var didCompleteFirstLaunch: Bool {
        get { store.bool(forKey: Key.didCompleteFirstLaunch) }
        set { store.set(newValue, forKey: Key.didCompleteFirstLaunch) }
    }

    /// Raccourcis enregistrés (`nil` = effacé), sans les défauts des actions absentes.
    var storedShortcuts: [WindowAction: Shortcut?] {
        get {
            guard let data = store.data(forKey: Key.shortcuts),
                  let raw = try? JSONDecoder().decode([String: Shortcut?].self, from: data) else { return [:] }
            return Dictionary(uniqueKeysWithValues: raw.compactMap { name, shortcut in
                WindowAction(rawValue: name).map { ($0, shortcut) }
            })
        }
        set {
            let raw = Dictionary(uniqueKeysWithValues: newValue.map { ($0.key.rawValue, $0.value) })
            store.set(try? JSONEncoder().encode(raw), forKey: Key.shortcuts)
        }
    }

    /// Raccourci effectif de chaque action.
    func shortcuts(defaults: [WindowAction: Shortcut]) -> [WindowAction: Shortcut?] {
        let stored = storedShortcuts
        return Dictionary(uniqueKeysWithValues: WindowAction.allCases.map { action in
            (action, stored[action] ?? defaults[action])
        })
    }

    /// Version du schéma des raccourcis enregistrés. 2 : agrandir / réduire sur ⌃⌥⇧⌘ + flèches.
    static let currentShortcutsSchema = 2

    /// Met à jour, une seule fois, les raccourcis enregistrés par une version antérieure : un
    /// raccourci resté à un ancien défaut remplacé reçoit le nouveau ; un raccourci personnalisé
    /// est conservé.
    func migrateShortcuts(defaults: [WindowAction: Shortcut]) {
        guard store.integer(forKey: Key.shortcutsSchema) < Self.currentShortcutsSchema else { return }
        var stored = storedShortcuts
        for (action, old) in DefaultShortcuts.replacedDefaults where stored[action] == .some(old) {
            stored[action] = .some(defaults[action])
        }
        storedShortcuts = stored
        store.set(Self.currentShortcutsSchema, forKey: Key.shortcutsSchema)
    }

    func setShortcut(_ shortcut: Shortcut?, for action: WindowAction) {
        var stored = storedShortcuts
        stored[action] = .some(shortcut)
        storedShortcuts = stored
    }
}
