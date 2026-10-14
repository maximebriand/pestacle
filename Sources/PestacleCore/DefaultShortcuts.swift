/// Raccourcis par défaut de Pestacle : ceux de Spectacle, sauf agrandir / réduire, passés sur
/// ⌃⌥⇧⌘ + flèches (⌃⌥⇧ + flèches est intercepté par macOS 27). Les lettres sont décrites par
/// caractère et résolues selon la disposition clavier active : en AZERTY, « Annuler » est la
/// touche étiquetée Z.
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
        .makeLarger: (.code(KeyCode.rightArrow), [.control, .option, .shift, .command]),
        .makeSmaller: (.code(KeyCode.leftArrow), [.control, .option, .shift, .command]),
        .undo: (.character("z"), [.option, .command]),
        .redo: (.character("z"), [.option, .shift, .command]),
    ]

    /// Défauts de Spectacle lui-même, tels qu'il les enregistrait : sert à reconnaître, à l'import,
    /// un raccourci que l'utilisateur n'avait pas personnalisé. Ne change jamais.
    static let spectacleBuiltInTable: [WindowAction: (key: Key, modifiers: Modifiers)] = {
        var t = table
        t[.makeLarger] = (.code(KeyCode.rightArrow), [.control, .option, .shift])
        t[.makeSmaller] = (.code(KeyCode.leftArrow), [.control, .option, .shift])
        return t
    }()

    /// Anciens défauts de Pestacle 0.1.0 remplacés depuis, pour la migration des préférences.
    public static let replacedDefaults: [WindowAction: Shortcut] = [
        .makeLarger: Shortcut(keyCode: KeyCode.rightArrow, modifiers: [.control, .option, .shift]),
        .makeSmaller: Shortcut(keyCode: KeyCode.leftArrow, modifiers: [.control, .option, .shift]),
    ]

    /// Raccourcis par défaut, lettres résolues par `keyCode(for:)` (disposition active), à défaut
    /// par la position ANSI.
    public static func resolved(keyCode: (String) -> UInt32?) -> [WindowAction: Shortcut] {
        resolve(table, keyCode: keyCode)
    }

    private static func resolve(_ table: [WindowAction: (key: Key, modifiers: Modifiers)], keyCode: (String) -> UInt32?) -> [WindowAction: Shortcut] {
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
    public static var spectacle: [WindowAction: Shortcut] { resolve(spectacleBuiltInTable) { _ in nil } }

    /// Ne garde d'un import Spectacle que les raccourcis personnalisés : une valeur identique au
    /// défaut de Spectacle n'est pas un choix de l'utilisateur et reçoit le défaut adapté à la disposition.
    public static func customizations(in imported: [WindowAction: Shortcut?]) -> [WindowAction: Shortcut?] {
        let builtIn = spectacle
        return imported.filter { action, shortcut in shortcut != builtIn[action] }
    }
}
