/// Modificateurs d'un raccourci, aux valeurs des masques Carbon (`cmdKey`, `shiftKey`…).
public struct Modifiers: OptionSet, Hashable, Codable, Sendable {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue & Self.all.rawValue
    }

    public static let command = Modifiers(rawValue: 1 << 8)
    public static let shift = Modifiers(rawValue: 1 << 9)
    public static let option = Modifiers(rawValue: 1 << 11)
    public static let control = Modifiers(rawValue: 1 << 12)

    private static let all = Modifiers(uncheckedRawValue: (1 << 8) | (1 << 9) | (1 << 11) | (1 << 12))
    private init(uncheckedRawValue: UInt32) { rawValue = uncheckedRawValue }

    /// Symboles dans l'ordre d'affichage de macOS : ⌃⌥⇧⌘.
    public var symbols: String {
        (contains(.control) ? "⌃" : "") + (contains(.option) ? "⌥" : "")
            + (contains(.shift) ? "⇧" : "") + (contains(.command) ? "⌘" : "")
    }
}

/// Un raccourci : une touche physique (code de touche virtuel) et des modificateurs.
public struct Shortcut: Hashable, Codable, Sendable, CustomStringConvertible {
    public var keyCode: UInt32
    public var modifiers: Modifiers

    public init(keyCode: UInt32, modifiers: Modifiers) {
        self.keyCode = keyCode
        self.modifiers = modifiers
    }

    public var description: String { "\(modifiers.symbols)#\(keyCode)" }
}

/// Codes de touche virtuels (valeurs de `kVK_*` dans Carbon/HIToolbox/Events.h).
public enum KeyCode {
    public static let leftArrow: UInt32 = 123
    public static let rightArrow: UInt32 = 124
    public static let downArrow: UInt32 = 125
    public static let upArrow: UInt32 = 126
    public static let escape: UInt32 = 53

    /// F1 à F20, dans l'ordre.
    public static let functionKeys: [UInt32] = [
        122, 120, 99, 118, 96, 97, 98, 100, 101, 109, 103, 111, 105, 107, 113, 106, 64, 79, 80, 90,
    ]

    /// Touches alphanumériques et de ponctuation en disposition ANSI (US).
    public static let ansi: [String: UInt32] = [
        "A": 0, "S": 1, "D": 2, "F": 3, "H": 4, "G": 5, "Z": 6, "X": 7, "C": 8, "V": 9,
        "B": 11, "Q": 12, "W": 13, "E": 14, "R": 15, "Y": 16, "T": 17, "1": 18, "2": 19,
        "3": 20, "4": 21, "6": 22, "5": 23, "=": 24, "9": 25, "7": 26, "-": 27, "8": 28,
        "0": 29, "]": 30, "O": 31, "U": 32, "[": 33, "I": 34, "P": 35, "L": 37, "J": 38,
        "'": 39, "K": 40, ";": 41, "\\": 42, ",": 43, "/": 44, "N": 45, "M": 46, ".": 47,
        "`": 50,
    ]
}

/// Résultat de la validation d'un raccourci saisi par l'utilisateur.
public enum ShortcutValidation: Equatable, Sendable {
    case valid
    /// Ni ⌘, ni ⌥, ni ⌃, et ce n'est pas une touche de fonction.
    case missingModifier
    /// Déjà attribué à une autre action de Pestacle.
    case conflict(WindowAction)
    /// Identique à un raccourci système actif.
    case reservedBySystem
}

public enum ShortcutValidator {
    public static func validate(
        _ shortcut: Shortcut,
        for action: WindowAction,
        assignments: [WindowAction: Shortcut],
        systemShortcuts: Set<Shortcut>
    ) -> ShortcutValidation {
        let hasModifier = !shortcut.modifiers.isDisjoint(with: [.command, .option, .control])
        if !hasModifier && !KeyCode.functionKeys.contains(shortcut.keyCode) {
            return .missingModifier
        }
        if let other = WindowAction.allCases.first(where: { $0 != action && assignments[$0] == shortcut }) {
            return .conflict(other)
        }
        if systemShortcuts.contains(shortcut) {
            return .reservedBySystem
        }
        return .valid
    }
}
