import Foundation
import Testing
import PestacleCore
@testable import Pestacle

@Suite("Migration des raccourcis")
@MainActor
struct PreferencesMigrationTests {
    func preferences() -> Preferences {
        Preferences(store: UserDefaults(suiteName: "fr.maximebriand.Pestacle.tests.\(UUID().uuidString)")!)
    }

    let defaults = DefaultShortcuts.resolved { _ in nil }
    let oldLarger = Shortcut(keyCode: KeyCode.rightArrow, modifiers: [.control, .option, .shift])

    @Test("Ancienne valeur par défaut : Agrandir passe sur ⌃⌥⇧⌘→")
    func oldDefault() {
        let p = preferences()
        p.storedShortcuts = [.makeLarger: oldLarger, .center: defaults[.center]]
        p.migrateShortcuts(defaults: defaults)
        #expect(p.shortcuts(defaults: defaults)[.makeLarger] == defaults[.makeLarger])
    }

    @Test("Valeur personnalisée : Agrandir reste sur ⌃⌥⌘=")
    func customValue() {
        let p = preferences()
        let custom = Shortcut(keyCode: KeyCode.ansi["="]!, modifiers: [.control, .option, .command])
        p.storedShortcuts = [.makeLarger: custom]
        p.migrateShortcuts(defaults: defaults)
        #expect(p.shortcuts(defaults: defaults)[.makeLarger] == custom)
    }

    @Test("Retour volontaire à l'ancienne valeur : respecté, la migration n'est jouée qu'une fois")
    func runsOnce() {
        let p = preferences()
        p.migrateShortcuts(defaults: defaults)
        p.setShortcut(oldLarger, for: .makeLarger)
        p.migrateShortcuts(defaults: defaults)
        #expect(p.shortcuts(defaults: defaults)[.makeLarger] == oldLarger)
    }
}
