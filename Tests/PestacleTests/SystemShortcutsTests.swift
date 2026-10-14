import Testing
import PestacleCore
@testable import Pestacle

@Suite("Raccourcis système")
struct SystemShortcutsTests {
    @Test("⌃↑ (Mission Control) fait partie des raccourcis système actifs")
    func missionControl() {
        let active = SystemShortcuts.active()
        #expect(!active.isEmpty)
        #expect(active.contains(Shortcut(keyCode: KeyCode.upArrow, modifiers: .control)), "\(active.sorted { $0.keyCode < $1.keyCode }.prefix(40))")
    }
}

@Suite("Raccourcis système non appliqués")
struct UnenforcedSystemShortcutsTests {
    @Test("⌃⇧← n'est plus compté comme réservé, ⌃↑ l'est toujours")
    func phantomVariants() {
        let active = SystemShortcuts.active()
        #expect(!active.contains(Shortcut(keyCode: KeyCode.leftArrow, modifiers: [.control, .shift])))
        #expect(!active.contains(Shortcut(keyCode: KeyCode.rightArrow, modifiers: [.control, .shift])))
        #expect(active.contains(Shortcut(keyCode: KeyCode.upArrow, modifiers: .control)))
    }

    @Test("Lecture des identifiants dans un plist d'exemple")
    func parsing() {
        let plist: [String: Any] = [
            "80": ["enabled": true, "value": ["parameters": [65535, 123, 8_781_824], "type": "standard"]],
            "32": ["enabled": true, "value": ["parameters": [65535, 126, 8_650_752], "type": "standard"]],
        ]
        #expect(SystemShortcuts.unenforced(from: plist) == [Shortcut(keyCode: 123, modifiers: [.control, .shift])])
    }

    @Test("⌃⇧← est accepté par la validation")
    func validatorAccepts() {
        let s = Shortcut(keyCode: KeyCode.leftArrow, modifiers: [.control, .shift])
        #expect(ShortcutValidator.validate(s, for: .center, assignments: [:], systemShortcuts: SystemShortcuts.active()) == .valid)
    }
}
