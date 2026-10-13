import Foundation
import Testing
@testable import PestacleCore

@Suite("Import depuis Spectacle")
struct SpectacleImporterTests {
    func importing(_ json: String) -> [WindowAction: Shortcut?]? {
        SpectacleImporter.shortcuts(from: Data(json.utf8))
    }

    @Test("Format réel : nom d'action et liaison")
    func realFormat() throws {
        let result = try #require(importing("""
            [
              { "shortcut_key_binding" : "alt+shift+cmd+z", "shortcut_name" : "RedoLastMove" },
              { "shortcut_key_binding" : "ctrl+alt+shift+left", "shortcut_name" : "MakeSmaller" },
              { "shortcut_key_binding" : "ctrl+alt+c", "shortcut_name" : "MoveToCenter" }
            ]
            """))
        #expect(result[.redo] == Shortcut(keyCode: 6, modifiers: [.option, .shift, .command]))
        #expect(result[.makeSmaller] == Shortcut(keyCode: KeyCode.leftArrow, modifiers: [.control, .option, .shift]))
        #expect(result[.center] == Shortcut(keyCode: 8, modifiers: [.control, .option]))
        #expect(result[.leftHalf] == nil)
    }

    @Test("Liaison null : raccourci effacé")
    func clearedShortcut() throws {
        let result = try #require(importing(#"[{ "shortcut_key_binding" : null, "shortcut_name" : "MoveToNextThird" }]"#))
        #expect(result[.nextThird] == .some(nil))
    }

    @Test("Liaison vide : traitée comme effacée")
    func emptyBinding() throws {
        let result = try #require(importing(#"[{ "shortcut_key_binding" : "", "shortcut_name" : "MoveToNextThird" }]"#))
        #expect(result[.nextThird] == .some(nil))
    }

    @Test("Nom d'action ou touche inconnus : entrée ignorée")
    func unknownEntries() throws {
        let result = try #require(importing("""
            [
              { "shortcut_key_binding" : "alt+cmd+left", "shortcut_name" : "MoveToMars" },
              { "shortcut_key_binding" : "alt+cmd+blah", "shortcut_name" : "MoveToLeftHalf" }
            ]
            """))
        #expect(result.isEmpty)
    }

    @Test("JSON invalide : import abandonné")
    func invalidJSON() {
        #expect(importing("{ pas du json") == nil)
        #expect(importing(#"{"shortcut_name": "MoveToCenter"}"#) == nil)
    }

    @Test("Touches nommées et touche de fonction seule")
    func namedKeys() {
        #expect(SpectacleImporter.shortcut(fromBinding: "f13") == Shortcut(keyCode: 105, modifiers: []))
        #expect(SpectacleImporter.shortcut(fromBinding: "ctrl+cmd+keypad5") == Shortcut(keyCode: 87, modifiers: [.control, .command]))
        #expect(SpectacleImporter.shortcut(fromBinding: "Alt + Cmd + Up") == Shortcut(keyCode: KeyCode.upArrow, modifiers: [.option, .command]))
    }

    @Test("Le fichier de ce Mac, s'il existe, s'importe entièrement")
    func localFile() throws {
        let url = FileManager.default.homeDirectoryForCurrentUser
            .appending(path: "Library/Application Support/Spectacle/Shortcuts.json")
        guard let data = try? Data(contentsOf: url) else { return }
        let result = try #require(SpectacleImporter.shortcuts(from: data))
        #expect(result.count == WindowAction.allCases.count)
    }
}
