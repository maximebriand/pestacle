import AppKit
import OSLog
import PestacleCore

/// Écrans connectés, convertis dans le repère haut-gauche de Pestacle.
@MainActor
final class ScreenProvider {
    private let log = Logger(subsystem: "fr.maximebriand.Pestacle", category: "screens")
    private var observer: NSObjectProtocol?

    init() {
        observer = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.logScreens(reason: "changement d'écrans") }
        }
        logScreens(reason: "démarrage")
    }

    /// Relu à chaque appel : branchement, débranchement et réagencement sont pris en compte immédiatement.
    var screens: [Screen] {
        let all = NSScreen.screens
        guard let primary = all.first else { return [] }
        return all.map { Self.screen(from: $0, primaryHeight: primary.frame.height) }
    }

    /// Position du pointeur dans le repère haut-gauche.
    var pointer: Point {
        let p = NSEvent.mouseLocation
        let primaryHeight = NSScreen.screens.first?.frame.height ?? 0
        return Point(x: p.x, y: primaryHeight - p.y)
    }

    static func screen(from screen: NSScreen, primaryHeight: CGFloat) -> Screen {
        let id = (screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber)?.uint32Value ?? 0
        return Screen(
            id: id,
            frame: convert(screen.frame, primaryHeight: primaryHeight),
            visibleFrame: convert(screen.visibleFrame, primaryHeight: primaryHeight))
    }

    /// AppKit (origine en bas à gauche de l'écran principal, y vers le haut) → haut-gauche.
    nonisolated static func convert(_ r: CGRect, primaryHeight: CGFloat) -> Rect {
        Rect(x: r.minX, y: primaryHeight - r.maxY, width: r.width, height: r.height)
    }

    private func logScreens(reason: String) {
        for s in screens {
            log.info("\(reason, privacy: .public) : écran \(s.id) cadre \(s.frame.description, privacy: .public) zone utile \(s.visibleFrame.description, privacy: .public)")
        }
    }
}
