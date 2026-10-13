/// Historique annuler / rétablir, propre à chaque fenêtre. `Key` identifie une fenêtre
/// (élément Accessibility dans l'app, simple valeur dans les tests).
public struct WindowHistory<Key: Hashable> {
    public static var defaultLimit: Int { 20 }

    public let limit: Int
    private var stacks: [Key: (undo: [Rect], redo: [Rect])] = [:]

    public init(limit: Int = Self.defaultLimit) {
        self.limit = limit
    }

    /// À appeler juste avant un déplacement : mémorise le cadre actuel et vide « rétablir ».
    public mutating func record(_ frame: Rect, for key: Key) {
        var s = stacks[key] ?? ([], [])
        s.undo.append(frame)
        if s.undo.count > limit { s.undo.removeFirst(s.undo.count - limit) }
        s.redo.removeAll()
        stacks[key] = s
    }

    /// Cadre à restaurer pour annuler, ou `nil` sans historique. `current` devient rétablissable.
    public mutating func undo(for key: Key, current: Rect) -> Rect? {
        guard var s = stacks[key], let previous = s.undo.popLast() else { return nil }
        s.redo.append(current)
        stacks[key] = s
        return previous
    }

    /// Cadre qu'avait la fenêtre juste avant la dernière annulation, ou `nil`.
    public mutating func redo(for key: Key, current: Rect) -> Rect? {
        guard var s = stacks[key], let next = s.redo.popLast() else { return nil }
        s.undo.append(current)
        stacks[key] = s
        return next
    }

    public func canUndo(_ key: Key) -> Bool { !(stacks[key]?.undo.isEmpty ?? true) }
    public func canRedo(_ key: Key) -> Bool { !(stacks[key]?.redo.isEmpty ?? true) }

    /// Libère l'historique d'une fenêtre disparue.
    public mutating func remove(_ key: Key) {
        stacks[key] = nil
    }

    /// Libère l'historique de toutes les fenêtres qui vérifient `shouldRemove` (app quittée…).
    public mutating func removeAll(where shouldRemove: (Key) -> Bool) {
        for key in stacks.keys where shouldRemove(key) { stacks[key] = nil }
    }

    public var trackedWindowCount: Int { stacks.count }
}
