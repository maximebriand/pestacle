import Testing
import PestacleCore
@testable import Pestacle

@Suite("Disposition clavier")
@MainActor
struct KeyboardLayoutTests {
    @Test("« z » : touche 13 en Français (AZERTY), touche 6 en US")
    func zByLayout() throws {
        let french = try #require(KeyboardLayout.layout(id: "com.apple.keylayout.French"))
        let us = try #require(KeyboardLayout.layout(id: "com.apple.keylayout.US"))
        #expect(french.keyCode(for: "z") == 13)
        #expect(us.keyCode(for: "z") == 6)
        #expect(french.keyCode(for: "c") == 8 && french.keyCode(for: "f") == 3)
    }

    @Test("Défauts résolus en AZERTY : le menu affiche ⌥⌘Z pour « Annuler »")
    func azertyDefaults() throws {
        let french = try #require(KeyboardLayout.layout(id: "com.apple.keylayout.French"))
        let defaults = DefaultShortcuts.resolved { french.keyCode(for: $0) }
        #expect(KeyboardLayout.label(for: defaults[.undo]!, layout: french) == "⌥⌘Z")
        #expect(KeyboardLayout.label(for: defaults[.redo]!, layout: french) == "⌥⇧⌘Z")
    }

    @Test("Libellé après changement de disposition : la touche Z d'AZERTY s'affiche W en US")
    func labelFollowsLayout() throws {
        let us = try #require(KeyboardLayout.layout(id: "com.apple.keylayout.US"))
        #expect(KeyboardLayout.label(for: Shortcut(keyCode: 13, modifiers: [.option, .command]), layout: us) == "⌥⌘W")
    }

    @Test("Touches nommées")
    func namedKeys() {
        #expect(KeyboardLayout.label(for: Shortcut(keyCode: KeyCode.rightArrow, modifiers: [.control, .option, .command]), layout: nil) == "⌃⌥⌘→")
        #expect(KeyboardLayout.label(for: Shortcut(keyCode: 105, modifiers: []), layout: nil) == "F13")
    }
}
