import Testing
@testable import PestacleCore

@Suite("Historique des déplacements")
struct WindowHistoryTests {
    let start = rect(100, 100, 700, 500)
    let left = rect(0, 0, 800, 1000)
    let full = rect(0, 0, 1600, 1000)

    @Test("Action enregistrée : annuler restaure le cadre d'avant")
    func undoRestores() {
        var h = WindowHistory<String>()
        h.record(start, for: "A")
        #expect(h.undo(for: "A", current: left) == start)
    }

    @Test("Moitié gauche puis plein écran, annuler : retour en moitié gauche")
    func undoTwoSteps() {
        var h = WindowHistory<String>()
        h.record(start, for: "A")
        h.record(left, for: "A")
        #expect(h.undo(for: "A", current: full) == left)
        #expect(h.undo(for: "A", current: left) == start)
    }

    @Test("Déplacement à la souris entre deux actions : annuler revient à la position souris")
    func mouseMoveBetweenActions() {
        var h = WindowHistory<String>()
        let byMouse = rect(300, 250, 800, 1000)
        h.record(start, for: "A")       // moitié gauche
        h.record(byMouse, for: "A")     // déplacée à la souris, puis plein écran
        #expect(h.undo(for: "A", current: full) == byMouse)
    }

    @Test("Historique vide : rien à annuler ni à rétablir")
    func empty() {
        var h = WindowHistory<String>()
        #expect(h.undo(for: "A", current: start) == nil)
        #expect(h.redo(for: "A", current: start) == nil)
    }

    @Test("Rétablir : restaure le cadre d'avant l'annulation")
    func redoAfterUndo() {
        var h = WindowHistory<String>()
        h.record(left, for: "A")
        _ = h.undo(for: "A", current: full)
        #expect(h.redo(for: "A", current: left) == full)
        #expect(h.undo(for: "A", current: full) == left)
    }

    @Test("Rétablir utilise le cadre réel, même si l'app l'avait contraint")
    func redoUsesActualFrame() {
        var h = WindowHistory<String>()
        let constrained = rect(0, 0, 1597, 990)
        h.record(left, for: "A")
        _ = h.undo(for: "A", current: constrained)
        #expect(h.redo(for: "A", current: left) == constrained)
    }

    @Test("Un nouveau déplacement vide « rétablir »")
    func newMoveClearsRedo() {
        var h = WindowHistory<String>()
        h.record(left, for: "A")
        _ = h.undo(for: "A", current: full)
        h.record(left, for: "A")
        #expect(h.redo(for: "A", current: start) == nil)
    }

    @Test("Historiques indépendants : annuler sur B ne touche pas A")
    func independent() {
        var h = WindowHistory<String>()
        h.record(start, for: "A")
        h.record(left, for: "B")
        #expect(h.undo(for: "B", current: full) == left)
        #expect(h.canUndo("A"))
    }

    @Test("25 déplacements : 20 annulations au plus")
    func limit() {
        var h = WindowHistory<String>()
        for i in 0..<25 { h.record(rect(Double(i), 0, 100, 100), for: "A") }
        var count = 0
        while h.undo(for: "A", current: start) != nil { count += 1 }
        #expect(count == 20)
    }

    @Test("Purge : fenêtre fermée et app quittée")
    func purge() {
        var h = WindowHistory<String>()
        h.record(start, for: "safari-1")
        h.record(start, for: "safari-2")
        h.record(start, for: "notes-1")
        h.remove("notes-1")
        #expect(!h.canUndo("notes-1"))
        h.removeAll { $0.hasPrefix("safari") }
        #expect(h.trackedWindowCount == 0)
    }
}
