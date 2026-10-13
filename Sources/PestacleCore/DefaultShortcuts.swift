/// Raccourcis par défaut de Spectacle. Les lettres sont décrites par caractère et résolues
/// selon la disposition clavier active : en AZERTY, « Annuler » est la touche étiquetée Z.
public enum DefaultShortcuts {
    public enum Key: Hashable, Sendable {
        /// Touche indépendante de la disposition (flèches).
        case code(UInt32)
        /// Lettre à résoudre selon la disposition.
        case character(String)
    }

    public static let table: [WindowAction: (key: Key, modifiers: Modifiers)] = [
        .leftHalf: (.code(KeyCode.leftArrow), [.option, .command]),
        .rightHalf: (.code(KeyCode.rightArrow), [.option, .command]),
        .topHalf: (.code(KeyCode.upArrow), [.option, .command]),
        .bottomHalf: (.code(KeyCode.downArrow), [.option, .command]),
        .upperLeft: (.code(KeyCode.leftArrow), [.control, .command]),
        .lowerLeft: (.code(KeyCode.leftArrow), [.control, .shift, .command]),
        .upperRight: (.code(KeyCode.rightArrow), [.control, .command]),
        .lowerRight: (.code(KeyCode.rightArrow), [.control, .shift, .command]),
        .fullscreen: (.character("f"), [.option, .command]),
        .center: (.character("c"), [.option, .command]),
        .nextDisplay: (.code(KeyCode.rightArrow), [.control, .option, .command]),
        .previousDisplay: (.code(KeyCode.leftArrow), [.control, .option, .command]),
        .nextThird: (.code(KeyCode.rightArrow), [.control, .option]),
        .previousThird: (.code(KeyCode.leftArrow), [.control, .option]),
        .makeLarger: (.code(KeyCode.rightArrow), [.control, .option, .shift]),
        .makeSmaller: (.code(KeyCode.leftArrow), [.control, .option, .shift]),
        .undo: (.character("z"), [.option, .command]),
        .redo: (.character("z"), [.option, .shift, .command]),
    ]

    /// Raccourcis par défaut, lettres résolues par `keyCode(for:)` (disposition active), à défaut
    /// par la position ANSI.
    public static func resolved(keyCode: (String) -> UInt32?) -> [WindowAction: Shortcut] {
        table.mapValues { entry in
            switch entry.key {
            case .code(let code):
                return Shortcut(keyCode: code, modifiers: entry.modifiers)
            case .character(let c):
                return Shortcut(keyCode: keyCode(c) ?? KeyCode.ansi[c.uppercased()]!, modifiers: entry.modifiers)
            }
        }
    }

    /// Défauts tels que Spectacle les enregistre : codes de touche ANSI, quelle que soit la disposition.
    public static var spectacle: [WindowAction: Shortcut] { resolved { _ in nil } }

    /// Ne garde d'un import Spectacle que les raccourcis personnalisés : une valeur identique au
    /// défaut de Spectacle n'est pas un choix de l'utilisateur et reçoit le défaut adapté à la disposition.
    public static func customizations(in imported: [WindowAction: Shortcut?]) -> [WindowAction: Shortcut?] {
        let builtIn = spectacle
        return imported.filter { action, shortcut in shortcut != builtIn[action] }
    }
}
