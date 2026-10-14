import Carbon.HIToolbox
import Foundation
import PestacleCore

/// Raccourcis réservés par macOS (Mission Control, Spotlight, captures d'écran…).
/// `RegisterEventHotKey` les accepte sans erreur alors qu'ils ne se déclencheront jamais :
/// il faut donc les refuser à la saisie, comme le fait Spectacle.
enum SystemShortcuts {
    /// Variantes ⌃⇧ de Mission Control (déplacer d'un bureau, Mission Control, fenêtres de l'app) :
    /// déclarées actives dans `com.apple.symbolichotkeys`, mais macOS ne les applique pas
    /// (essai au clavier réel sur macOS 27 : ⌃⇧ + flèches parvient aux apps).
    static let unenforcedIdentifiers = ["34", "35", "80", "82"]

    /// Combinaisons déclarées par ces identifiants.
    static func unenforced(from plist: [String: Any]? = UserDefaults(suiteName: "com.apple.symbolichotkeys")?
        .dictionary(forKey: "AppleSymbolicHotKeys")) -> Set<Shortcut> {
        guard let plist else { return [] }
        var out = Set<Shortcut>()
        for id in unenforcedIdentifiers {
            guard let entry = plist[id] as? [String: Any], let value = entry["value"] as? [String: Any],
                  let parameters = value["parameters"] as? [Int], parameters.count == 3 else { continue }
            out.insert(Shortcut(keyCode: UInt32(parameters[1]), modifiers: modifiers(cocoa: parameters[2])))
        }
        return out
    }

    /// Masque de modificateurs Cocoa (`NSEvent.ModifierFlags`) → modificateurs Carbon.
    static func modifiers(cocoa flags: Int) -> Modifiers {
        var m: Modifiers = []
        if flags & (1 << 17) != 0 { m.insert(.shift) }
        if flags & (1 << 18) != 0 { m.insert(.control) }
        if flags & (1 << 19) != 0 { m.insert(.option) }
        if flags & (1 << 20) != 0 { m.insert(.command) }
        return m
    }

    /// Raccourcis système actuellement actifs et réellement appliqués par macOS.
    static func active() -> Set<Shortcut> {
        declared().subtracting(unenforced())
    }

    /// Raccourcis système déclarés actifs, tels que les liste `CopySymbolicHotKeys`.
    static func declared() -> Set<Shortcut> {
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
