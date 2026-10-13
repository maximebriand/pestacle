import Carbon.HIToolbox
import PestacleCore

/// Raccourcis réservés par macOS (Mission Control, Spotlight, captures d'écran…).
/// `RegisterEventHotKey` les accepte sans erreur alors qu'ils ne se déclencheront jamais :
/// il faut donc les refuser à la saisie, comme le fait Spectacle.
enum SystemShortcuts {
    /// Raccourcis système actuellement actifs.
    static func active() -> Set<Shortcut> {
        var unmanaged: Unmanaged<CFArray>?
        guard CopySymbolicHotKeys(&unmanaged) == noErr, let array = unmanaged?.takeRetainedValue() as? [[String: Any]] else {
            return []
        }
        var result = Set<Shortcut>()
        for entry in array {
            guard (entry[kHISymbolicHotKeyEnabled as String] as? Bool) == true,
                  let code = entry[kHISymbolicHotKeyCode as String] as? Int,
                  let modifiers = entry[kHISymbolicHotKeyModifiers as String] as? Int else { continue }
            result.insert(Shortcut(keyCode: UInt32(code), modifiers: Modifiers(rawValue: UInt32(modifiers))))
        }
        return result
    }

    /// Désactive les raccourcis système le temps d'enregistrer un raccourci, pour que
    /// ⌃↑ ou ⌘Espace parviennent au champ de saisie au lieu d'ouvrir Mission Control ou Spotlight.
    /// À équilibrer par `endRecording(token:)`.
    static func beginRecording() -> UnsafeMutableRawPointer? {
        PushSymbolicHotKeyMode(OptionBits(kHIHotKeyModeAllDisabled))
    }

    static func endRecording(token: UnsafeMutableRawPointer?) {
        guard let token else { return }
        PopSymbolicHotKeyMode(token)
    }
}
