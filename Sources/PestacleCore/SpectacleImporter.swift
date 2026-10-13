import Foundation

/// Lecture du fichier de raccourcis de Spectacle
/// (`~/Library/Application Support/Spectacle/Shortcuts.json`).
///
/// Format : tableau d'objets `{"shortcut_name": "MoveToLeftHalf", "shortcut_key_binding": "alt+cmd+left"}`,
/// liaison `null` pour un raccourci effacé. Les touches sont des codes ANSI physiques, comme dans Spectacle.
public enum SpectacleImporter {
    /// Raccourcis importés (`nil` = effacé), ou `nil` si le fichier n'est pas un JSON exploitable.
    /// Les actions et touches inconnues sont ignorées.
    public static func shortcuts(from data: Data) -> [WindowAction: Shortcut?]? {
        guard let entries = (try? JSONSerialization.jsonObject(with: data)) as? [[String: Any]] else { return nil }
        var result: [WindowAction: Shortcut?] = [:]
        for entry in entries {
            guard let name = entry["shortcut_name"] as? String, let action = WindowAction(rawValue: name) else { continue }
            guard let binding = entry["shortcut_key_binding"] as? String,
                  !binding.trimmingCharacters(in: .whitespaces).isEmpty else {
                result[action] = .some(nil)
                continue
            }
            if let shortcut = shortcut(fromBinding: binding) {
                result[action] = shortcut
            }
        }
        return result
    }

    /// « ctrl+alt+shift+cmd+left » → raccourci, selon la table de `SpectacleShortcutKeyBindings.m`.
    public static func shortcut(fromBinding binding: String) -> Shortcut? {
        let parts = binding.split(separator: "+", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespaces).uppercased() }
        guard let key = parts.last, let keyCode = namedKeys[key] ?? KeyCode.ansi[key] else { return nil }
        var modifiers: Modifiers = []
        for part in parts.dropLast() {
            switch part {
            case "CMD", "COMMAND": modifiers.insert(.command)
            case "ALT", "OPTION": modifiers.insert(.option)
            case "CTRL", "CONTROL": modifiers.insert(.control)
            case "SHIFT": modifiers.insert(.shift)
            default: break
            }
        }
        return Shortcut(keyCode: keyCode, modifiers: modifiers)
    }

    static let namedKeys: [String: UInt32] = {
        var keys: [String: UInt32] = [
            "KEYPADDECIMAL": 65, "KEYPADMULTIPLY": 67, "KEYPADPLUS": 69, "KEYPADCLEAR": 71,
            "KEYPADDIVIDE": 75, "KEYPADENTER": 76, "KEYPADMINUS": 78, "KEYPADEQUALS": 81,
            "KEYPAD0": 82, "KEYPAD1": 83, "KEYPAD2": 84, "KEYPAD3": 85, "KEYPAD4": 86,
            "KEYPAD5": 87, "KEYPAD6": 88, "KEYPAD7": 89, "KEYPAD8": 91, "KEYPAD9": 92,
            "RETURN": 36, "TAB": 48, "SPACE": 49, "DELETE": 51, "ESCAPE": 53,
            "COMMAND": 55, "SHIFT": 56, "CAPSLOCK": 57, "OPTION": 58, "CONTROL": 59,
            "RIGHTSHIFT": 60, "RIGHTOPTION": 61, "RIGHTCONTROL": 62, "FUNCTION": 63,
            "VOLUMEUP": 72, "VOLUMEDOWN": 73, "MUTE": 74, "HELP": 114, "HOME": 115,
            "PAGEUP": 116, "FORWARDDELETE": 117, "END": 119, "PAGEDOWN": 121,
            "LEFT": KeyCode.leftArrow, "RIGHT": KeyCode.rightArrow,
            "DOWN": KeyCode.downArrow, "UP": KeyCode.upArrow,
        ]
        for (i, code) in KeyCode.functionKeys.enumerated() { keys["F\(i + 1)"] = code }
        return keys
    }()
}
