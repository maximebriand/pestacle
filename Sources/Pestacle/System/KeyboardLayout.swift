import Carbon.HIToolbox
import Foundation
import OSLog
import PestacleCore

/// Disposition clavier : résolution caractère → touche physique, et libellé d'une touche.
@MainActor
final class KeyboardLayout {
    /// Données `uchr` d'une disposition.
    struct Layout: @unchecked Sendable {
        let data: CFData

        /// Caractère produit par la touche sans modificateur, ou `nil`.
        func character(for keyCode: UInt32) -> String? {
            let bytes = CFDataGetBytePtr(data)!
            return bytes.withMemoryRebound(to: UCKeyboardLayout.self, capacity: 1) { layout in
                var deadKeys: UInt32 = 0
                var length = 0
                var chars = [UniChar](repeating: 0, count: 4)
                let status = UCKeyTranslate(layout, UInt16(keyCode), UInt16(kUCKeyActionDisplay), 0,
                                            UInt32(LMGetKbdType()), OptionBits(kUCKeyTranslateNoDeadKeysMask),
                                            &deadKeys, chars.count, &length, &chars)
                guard status == noErr, length > 0 else { return nil }
                let s = String(utf16CodeUnits: chars, count: length)
                return s.trimmingCharacters(in: .whitespacesAndNewlines.union(.controlCharacters)).isEmpty ? nil : s
            }
        }

        /// Touche physique qui produit `character` sans modificateur.
        func keyCode(for character: String) -> UInt32? {
            let target = character.lowercased()
            return (0..<128).map(UInt32.init).first { self.character(for: $0)?.lowercased() == target }
        }
    }

    private let log = Logger(subsystem: "fr.maximebriand.Pestacle", category: "keyboard")
    private var observer: NSObjectProtocol?
    /// Appelé quand l'utilisateur change de disposition.
    var onChange: (() -> Void)?

    init() {
        observer = DistributedNotificationCenter.default().addObserver(
            forName: Notification.Name(kTISNotifySelectedKeyboardInputSourceChanged as String), object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.log.info("disposition clavier changée")
                self?.onChange?()
            }
        }
    }

    /// Disposition active ; pour une méthode de saisie sans disposition propre (japonais…),
    /// la disposition ASCII associée.
    static func current() -> Layout? {
        for copy in [TISCopyCurrentKeyboardLayoutInputSource, TISCopyCurrentASCIICapableKeyboardLayoutInputSource] {
            if let source = copy()?.takeRetainedValue(), let layout = layout(of: source) { return layout }
        }
        return nil
    }

    /// Disposition installée d'identifiant `id` (« com.apple.keylayout.French »), active ou non.
    static func layout(id: String) -> Layout? {
        let filter = [kTISPropertyInputSourceID as String: id] as CFDictionary
        guard let list = TISCreateInputSourceList(filter, true)?.takeRetainedValue() as? [TISInputSource],
              let source = list.first else { return nil }
        return layout(of: source)
    }

    private static func layout(of source: TISInputSource) -> Layout? {
        guard let raw = TISGetInputSourceProperty(source, kTISPropertyUnicodeKeyLayoutData) else { return nil }
        return Layout(data: Unmanaged<CFData>.fromOpaque(raw).takeUnretainedValue())
    }

    // MARK: - Libellés

    private static let namedKeys: [UInt32: String] = {
        var names: [UInt32: String] = [
            KeyCode.leftArrow: "←", KeyCode.rightArrow: "→", KeyCode.upArrow: "↑", KeyCode.downArrow: "↓",
            36: "↩", 48: "⇥", 49: "␣", 51: "⌫", 53: "⎋", 117: "⌦", 115: "↖", 119: "↘", 116: "⇞", 121: "⇟", 76: "⌤",
        ]
        for (i, code) in KeyCode.functionKeys.enumerated() { names[code] = "F\(i + 1)" }
        return names
    }()

    /// Libellé d'un raccourci dans la disposition `layout` : « ⌥⌘Z », « ⌃⌥⌘→ », « F13 ».
    static func label(for shortcut: Shortcut, layout: Layout? = current()) -> String {
        shortcut.modifiers.symbols + keyLabel(shortcut.keyCode, layout: layout)
    }

    static func keyLabel(_ keyCode: UInt32, layout: Layout?) -> String {
        if let name = namedKeys[keyCode] { return name }
        if let c = layout?.character(for: keyCode) { return c.uppercased() }
        return KeyCode.ansi.first { $0.value == keyCode }?.key ?? "#\(keyCode)"
    }
}
