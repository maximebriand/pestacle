import Testing
@testable import PestacleCore

@Suite("Raccourcis par défaut")
struct DefaultShortcutsTests {
    @Test("Toutes les actions ont un raccourci par défaut, tous distincts")
    func complete() {
        let defaults = DefaultShortcuts.resolved { _ in nil }
        #expect(Set(defaults.keys) == Set(WindowAction.allCases))
        #expect(Set(defaults.values).count == defaults.count)
    }

    @Test("Disposition US (repli ANSI) : ⌥⌘Z sur la touche 6, ⌥⌘F, ⌃⇧⌘→")
    func ansiFallback() {
        let defaults = DefaultShortcuts.resolved { _ in nil }
        #expect(defaults[.undo] == Shortcut(keyCode: 6, modifiers: [.option, .command]))
        #expect(defaults[.fullscreen] == Shortcut(keyCode: 3, modifiers: [.option, .command]))
        #expect(defaults[.lowerRight] == Shortcut(keyCode: KeyCode.rightArrow, modifiers: [.control, .shift, .command]))
    }

    @Test("AZERTY : Z se résout sur la touche 13, les flèches ne changent pas")
    func azerty() {
        let azerty: [String: UInt32] = ["z": 13, "f": 3, "c": 8]
        let defaults = DefaultShortcuts.resolved { azerty[$0] }
        #expect(defaults[.undo]?.keyCode == 13)
        #expect(defaults[.redo] == Shortcut(keyCode: 13, modifiers: [.option, .shift, .command]))
        #expect(defaults[.leftHalf]?.keyCode == KeyCode.leftArrow)
    }

    @Test("Aucun défaut n'entre en conflit avec un autre selon le validateur")
    func noInternalConflict() {
        let defaults = DefaultShortcuts.resolved { _ in nil }
        for (action, shortcut) in defaults {
            #expect(ShortcutValidator.validate(shortcut, for: action, assignments: defaults, systemShortcuts: []) == .valid)
        }
    }

    @Test("Import : seuls les raccourcis personnalisés sont conservés")
    func customizationsOnly() {
        let spectacleDefaultUndo = Shortcut(keyCode: 6, modifiers: [.option, .command])
        let customCenter = Shortcut(keyCode: 8, modifiers: [.control, .option])
        let imported: [WindowAction: Shortcut?] = [
            .undo: spectacleDefaultUndo, .center: customCenter, .nextThird: nil,
        ]
        let kept = DefaultShortcuts.customizations(in: imported)
        #expect(kept.keys.contains(.undo) == false)
        #expect(kept[.center] == customCenter)
        #expect(kept[.nextThird] == .some(nil))
    }
}
