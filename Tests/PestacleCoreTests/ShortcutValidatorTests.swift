import Testing
@testable import PestacleCore

@Suite("Validation des raccourcis")
struct ShortcutValidatorTests {
    let optCmdC = Shortcut(keyCode: KeyCode.ansi["C"]!, modifiers: [.option, .command])
    let ctrlUp = Shortcut(keyCode: KeyCode.upArrow, modifiers: .control)

    func validate(_ s: Shortcut, for action: WindowAction = .leftHalf, system: Set<Shortcut> = []) -> ShortcutValidation {
        ShortcutValidator.validate(s, for: action, assignments: [.center: optCmdC], systemShortcuts: system)
    }

    @Test("Touche F seule : refusée faute de modificateur")
    func letterWithoutModifier() {
        #expect(validate(Shortcut(keyCode: KeyCode.ansi["F"]!, modifiers: [])) == .missingModifier)
    }

    @Test("⇧ seul ne suffit pas")
    func shiftOnly() {
        #expect(validate(Shortcut(keyCode: KeyCode.ansi["F"]!, modifiers: .shift)) == .missingModifier)
    }

    @Test("F13 seule : acceptée")
    func functionKeyAlone() {
        #expect(validate(Shortcut(keyCode: 105, modifiers: [])) == .valid)
    }

    @Test("⌃⌥⌘M : accepté")
    func validCombination() {
        #expect(validate(Shortcut(keyCode: KeyCode.ansi["M"]!, modifiers: [.control, .option, .command])) == .valid)
    }

    @Test("⌥⌘C pour « Moitié gauche » alors qu'il est à « Centrer » : conflit nommé")
    func internalConflict() {
        #expect(validate(optCmdC) == .conflict(.center))
    }

    @Test("Réattribuer à une action son propre raccourci n'est pas un conflit")
    func sameActionIsNotConflict() {
        #expect(validate(optCmdC, for: .center) == .valid)
    }

    @Test("⌃↑, raccourci système actif : refusé")
    func systemShortcut() {
        #expect(validate(ctrlUp, system: [ctrlUp]) == .reservedBySystem)
    }

    @Test("Les bits inconnus des modificateurs sont ignorés")
    func modifierMasking() {
        #expect(Modifiers(rawValue: (1 << 8) | (1 << 17)) == .command)
        #expect(Modifiers([.control, .option, .shift, .command]).symbols == "⌃⌥⇧⌘")
    }
}
