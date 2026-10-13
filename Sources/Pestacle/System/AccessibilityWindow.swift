import AppKit
import ApplicationServices
import PestacleCore

/// Raisons pour lesquelles aucune fenêtre ne peut être déplacée.
enum WindowFailure: Error, Equatable {
    case notTrusted
    case noFocusedWindow
    case ownWindow
    case sheet
    case systemDialog
    case minimized
    case nativeFullscreen
    /// L'app n'a pas répondu dans le délai imparti.
    case timedOut
    /// La fenêtre n'existe plus.
    case invalidElement
    case writeFailed
}

/// Identité d'une fenêtre pour l'historique : l'élément Accessibility, comparé avec `CFEqual`.
struct WindowKey: Hashable, @unchecked Sendable {
    let pid: pid_t
    let element: AXUIElement

    static func == (a: WindowKey, b: WindowKey) -> Bool {
        a.pid == b.pid && CFEqual(a.element, b.element)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(pid)
        hasher.combine(CFHash(element))
    }
}

/// Une fenêtre manipulable. Implémentée par `AccessibilityWindow`, et par des doubles dans les tests.
@MainActor
protocol ManagedWindow: AnyObject {
    var key: WindowKey { get }
    func frame() throws(WindowFailure) -> Rect
    /// Écrit taille et position, puis renvoie le cadre réellement obtenu.
    func setFrame(_ frame: Rect) throws(WindowFailure) -> Rect
    /// Déplace sans redimensionner, puis renvoie le cadre réellement obtenu.
    func setOrigin(_ origin: Point) throws(WindowFailure) -> Rect
}

/// Fournit la fenêtre cible des actions.
@MainActor
protocol WindowSource {
    func focusedWindow() -> Result<any ManagedWindow, WindowFailure>
}

/// Délai maximal accordé à une app pour répondre à une requête Accessibility.
private let messagingTimeout: Float = 1.0

@MainActor
struct AccessibilityWindowSource: WindowSource {
    func focusedWindow() -> Result<any ManagedWindow, WindowFailure> {
        guard AXIsProcessTrusted() else { return .failure(.notTrusted) }
        guard let app = NSWorkspace.shared.frontmostApplication else { return .failure(.noFocusedWindow) }
        let pid = app.processIdentifier
        if pid == ProcessInfo.processInfo.processIdentifier { return .failure(.ownWindow) }

        let appElement = AXUIElementCreateApplication(pid)
        AXUIElementSetMessagingTimeout(appElement, messagingTimeout)
        do {
            guard let ref = try AX.copy(appElement, kAXFocusedWindowAttribute),
                  CFGetTypeID(ref) == AXUIElementGetTypeID() else { return .failure(.noFocusedWindow) }
            let window = ref as! AXUIElement
            AXUIElementSetMessagingTimeout(window, messagingTimeout)
            try Self.checkEligibility(window)
            return .success(AccessibilityWindow(pid: pid, element: window, appElement: appElement))
        } catch {
            return .failure(error)
        }
    }

    private static func checkEligibility(_ window: AXUIElement) throws(WindowFailure) {
        if try AX.string(window, kAXRoleAttribute) == kAXSheetRole { throw .sheet }
        if try AX.string(window, kAXSubroleAttribute) == kAXSystemDialogSubrole { throw .systemDialog }
        if try AX.bool(window, kAXMinimizedAttribute) == true { throw .minimized }
        if try isNativeFullscreen(window) { throw .nativeFullscreen }
    }

    /// Best-effort : attribut non documenté `AXFullScreen`, à défaut le bouton plein écran
    /// qui prend le sous-rôle « zoom » en plein écran (méthode de Rectangle).
    private static func isNativeFullscreen(_ window: AXUIElement) throws(WindowFailure) -> Bool {
        if let flag = try AX.bool(window, "AXFullScreen") { return flag }
        guard let ref = try AX.copy(window, kAXFullScreenButtonAttribute),
              CFGetTypeID(ref) == AXUIElementGetTypeID() else { return false }
        return try AX.string(ref as! AXUIElement, kAXSubroleAttribute) == kAXZoomButtonSubrole
    }
}

@MainActor
final class AccessibilityWindow: ManagedWindow {
    let key: WindowKey
    private let appElement: AXUIElement

    init(pid: pid_t, element: AXUIElement, appElement: AXUIElement) {
        key = WindowKey(pid: pid, element: element)
        self.appElement = appElement
    }

    private var element: AXUIElement { key.element }

    func frame() throws(WindowFailure) -> Rect {
        guard let origin = try AX.point(element, kAXPositionAttribute),
              let size = try AX.size(element, kAXSizeAttribute) else { throw .invalidElement }
        return Rect(x: origin.x, y: origin.y, width: size.width, height: size.height)
    }

    /// Taille → position → taille : la première taille évite qu'une grande fenêtre déborde
    /// sur l'écran cible, la seconde corrige la taille si le changement d'écran l'a altérée.
    func setFrame(_ target: Rect) throws(WindowFailure) -> Rect {
        try withEnhancedUserInterfaceDisabled { () throws(WindowFailure) in
            let size = CGSize(width: target.width, height: target.height)
            try AX.setSize(element, size)
            try AX.setPoint(element, CGPoint(x: target.x, y: target.y))
            try AX.setSize(element, size)
        }
        return try frame()
    }

    func setOrigin(_ origin: Point) throws(WindowFailure) -> Rect {
        try withEnhancedUserInterfaceDisabled { () throws(WindowFailure) in
            try AX.setPoint(element, CGPoint(x: origin.x, y: origin.y))
        }
        return try frame()
    }

    /// Chrome, les apps Electron et d'autres animent ou ignorent les écritures tant que
    /// `AXEnhancedUserInterface` est actif. On le coupe le temps de l'écriture, sauf si une
    /// technologie d'assistance du système en a besoin, et on restaure sa valeur.
    private func withEnhancedUserInterfaceDisabled(_ body: () throws(WindowFailure) -> Void) throws(WindowFailure) {
        let assistive = NSWorkspace.shared.isVoiceOverEnabled || NSWorkspace.shared.isSwitchControlEnabled
        let wasEnabled = !assistive && ((try? AX.bool(appElement, "AXEnhancedUserInterface")) ?? nil) == true
        if wasEnabled { AXUIElementSetAttributeValue(appElement, "AXEnhancedUserInterface" as CFString, kCFBooleanFalse) }
        defer {
            if wasEnabled { AXUIElementSetAttributeValue(appElement, "AXEnhancedUserInterface" as CFString, kCFBooleanTrue) }
        }
        try body()
    }
}

/// Accès typés aux attributs Accessibility, avec traduction des erreurs.
enum AX {
    static func copy(_ element: AXUIElement, _ attribute: String) throws(WindowFailure) -> CFTypeRef? {
        var value: CFTypeRef?
        try check(AXUIElementCopyAttributeValue(element, attribute as CFString, &value))
        return value
    }

    static func string(_ element: AXUIElement, _ attribute: String) throws(WindowFailure) -> String? {
        try copy(element, attribute) as? String
    }

    static func bool(_ element: AXUIElement, _ attribute: String) throws(WindowFailure) -> Bool? {
        try copy(element, attribute) as? Bool
    }

    static func point(_ element: AXUIElement, _ attribute: String) throws(WindowFailure) -> CGPoint? {
        guard let value = try axValue(element, attribute) else { return nil }
        var point = CGPoint.zero
        return AXValueGetValue(value, .cgPoint, &point) ? point : nil
    }

    static func size(_ element: AXUIElement, _ attribute: String) throws(WindowFailure) -> CGSize? {
        guard let value = try axValue(element, attribute) else { return nil }
        var size = CGSize.zero
        return AXValueGetValue(value, .cgSize, &size) ? size : nil
    }

    static func setPoint(_ element: AXUIElement, _ point: CGPoint) throws(WindowFailure) {
        var p = point
        guard let value = AXValueCreate(.cgPoint, &p) else { throw .writeFailed }
        try check(AXUIElementSetAttributeValue(element, kAXPositionAttribute as CFString, value))
    }

    static func setSize(_ element: AXUIElement, _ size: CGSize) throws(WindowFailure) {
        var s = size
        guard let value = AXValueCreate(.cgSize, &s) else { throw .writeFailed }
        try check(AXUIElementSetAttributeValue(element, kAXSizeAttribute as CFString, value))
    }

    private static func axValue(_ element: AXUIElement, _ attribute: String) throws(WindowFailure) -> AXValue? {
        guard let ref = try copy(element, attribute), CFGetTypeID(ref) == AXValueGetTypeID() else { return nil }
        return (ref as! AXValue)
    }

    /// Les attributs absents ou non pris en charge ne sont pas des erreurs en lecture : la valeur vaut `nil`.
    /// En écriture, une fenêtre qui refuse (non redimensionnable) n'est pas une erreur non plus :
    /// le cadre relu dira ce qui a été obtenu.
    private static func check(_ error: AXError) throws(WindowFailure) {
        switch error {
        case .cannotComplete: throw .timedOut
        case .apiDisabled: throw .notTrusted
        case .invalidUIElement: throw .invalidElement
        default: return
        }
    }
}
