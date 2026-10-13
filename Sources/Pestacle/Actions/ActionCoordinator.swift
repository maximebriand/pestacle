import AppKit
import OSLog
import PestacleCore

@MainActor
protocol ScreenSource {
    var screens: [Screen] { get }
    var pointer: Point { get }
}

extension ScreenProvider: ScreenSource {}

/// Retours visibles d'une action : son d'alerte, explication de l'autorisation.
@MainActor
protocol ActionFeedback {
    func beep()
    func explainPermission()
}

/// Enchaîne une action : autorisation → fenêtre → écrans → calcul → écriture → historique.
@MainActor
final class ActionCoordinator {
    enum Outcome: Equatable {
        case moved(Rect)
        /// Le cadre calculé est celui de la fenêtre : rien n'est écrit.
        case unchanged
        /// Action impossible : un seul écran, taille plancher, rien à annuler…
        case unavailable
        case failed(WindowFailure)
    }

    private let windows: any WindowSource
    private let screens: any ScreenSource
    private let isTrusted: () -> Bool
    private let feedback: any ActionFeedback
    private let options: () -> LayoutOptions
    private(set) var history = WindowHistory<WindowKey>()
    /// Exécute la passe de rattrapage un peu plus tard (remplaçable dans les tests).
    var later: (@escaping @MainActor () -> Void) -> Void = { work in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { MainActor.assumeIsolated(work) }
    }
    /// Appelé quand une fenêtre entre dans l'historique, pour surveiller sa disparition.
    var onTrack: ((WindowKey) -> Void)?

    private let log = Logger(subsystem: "fr.maximebriand.Pestacle", category: "actions")
    /// Durée entre le début de la dernière action et sa première écriture AX (mesure du surcoût propre).
    private(set) var lastTimeToFirstWrite: Duration?
    private var actionStart = ContinuousClock.now
    private let signposter = OSSignposter(subsystem: "fr.maximebriand.Pestacle", category: .pointsOfInterest)

    init(windows: any WindowSource, screens: any ScreenSource, isTrusted: @escaping () -> Bool,
         feedback: any ActionFeedback, options: @escaping () -> LayoutOptions) {
        self.windows = windows
        self.screens = screens
        self.isTrusted = isTrusted
        self.feedback = feedback
        self.options = options
    }

    @discardableResult
    func perform(_ action: WindowAction) -> Outcome {
        let interval = signposter.beginInterval("action", "\(action.rawValue)")
        actionStart = .now
        lastTimeToFirstWrite = nil
        defer { signposter.endInterval("action", interval) }

        let outcome = run(action)
        switch outcome {
        case .moved(let frame):
            log.info("\(action.rawValue, privacy: .public) → \(frame.description, privacy: .public)")
        case .failed(.notTrusted):
            log.info("\(action.rawValue, privacy: .public) : autorisation manquante")
            feedback.explainPermission()
        default:
            log.info("\(action.rawValue, privacy: .public) : \(String(describing: outcome), privacy: .public)")
            feedback.beep()
        }
        return outcome
    }

    /// Libère l'historique d'une fenêtre fermée ou d'une app quittée.
    func forget(_ key: WindowKey) { history.remove(key) }
    func forget(pid: pid_t) { history.removeAll { $0.pid == pid } }

    private func run(_ action: WindowAction) -> Outcome {
        guard isTrusted() else { return .failed(.notTrusted) }
        let window: any ManagedWindow
        switch windows.focusedWindow() {
        case .success(let w): window = w
        case .failure(let failure): return .failed(failure)
        }
        do {
            let current = try window.frame()
            if action.isHistory { return try restore(action, window: window, current: current) }

            guard let placement = LayoutEngine.placement(
                for: action, window: current, screens: screens.screens, pointer: screens.pointer, options: options())
            else { return .unavailable }
            if LayoutEngine.isUnchanged(action, current: current, target: placement.frame) { return .unchanged }

            signposter.emitEvent("first-write")
            lastTimeToFirstWrite = ContinuousClock.now - actionStart
            let actual = try write(placement.frame, to: window, visible: placement.visibleFrame)
            history.record(current, for: window.key)
            onTrack?(window.key)
            return .moved(actual)
        } catch {
            if error == .invalidElement { history.remove(window.key) }
            return .failed(error)
        }
    }

    private func restore(_ action: WindowAction, window: any ManagedWindow, current: Rect) throws(WindowFailure) -> Outcome {
        let target = action == .undo
            ? history.undo(for: window.key, current: current)
            : history.redo(for: window.key, current: current)
        guard let target else { return .unavailable }
        let actual = try window.setFrame(target)
        settleLater(window, target: target, visible: nil)
        return .moved(actual)
    }

    /// Écrit le cadre, puis replace la fenêtre si l'app a imposé une autre taille.
    private func write(_ target: Rect, to window: any ManagedWindow, visible: Rect) throws(WindowFailure) -> Rect {
        let actual = try reanchoring(window.setFrame(target), target: target, to: window, visible: visible)
        settleLater(window, target: target, visible: visible)
        return actual
    }

    private static func sizeDiffers(_ a: Rect, _ b: Rect) -> Bool {
        abs(a.width - b.width) > 1 || abs(a.height - b.height) > 1
    }

    /// Certaines apps (Safari, parti d'une petite fenêtre basse) n'appliquent la dernière taille
    /// qu'après avoir traité leur boucle d'événements : si la taille ne correspond pas, le cadre
    /// est réécrit une fois peu après. Une taille réellement imposée par l'app reste inchangée.
    private func settleLater(_ window: any ManagedWindow, target: Rect, visible: Rect?) {
        guard let actual = try? window.frame(), Self.sizeDiffers(actual, target) else { return }
        later { [weak self] in
            guard let self, let now = try? window.frame(), Self.sizeDiffers(now, target) else { return }
            let fixed = try? window.setFrame(target)
            if let visible, let fixed {
                _ = try? reanchoring(fixed, target: target, to: window, visible: visible)
            }
            log.info("rattrapage : \(now.description, privacy: .public) → \(((try? window.frame())?.description ?? "?"), privacy: .public)")
        }
    }

    private func reanchoring(_ actual: Rect, target: Rect, to window: any ManagedWindow, visible: Rect) throws(WindowFailure) -> Rect {
        guard Self.sizeDiffers(actual, target) else { return actual }
        var actual = actual
        // Arrondi au-delà de la zone utile alors que la cible y tenait : redemander la taille
        // diminuée du dépassement, l'app arrondira au plus proche.
        let excessW = actual.width - visible.width, excessH = actual.height - visible.height
        if (excessW > 1 && target.width <= visible.width) || (excessH > 1 && target.height <= visible.height) {
            actual = try window.setFrame(Rect(
                x: target.x, y: target.y,
                width: excessW > 1 ? target.width - excessW : target.width,
                height: excessH > 1 ? target.height - excessH : target.height))
        }
        guard Self.sizeDiffers(actual, target) else { return actual }
        let anchored = LayoutEngine.reanchor(actualWidth: actual.width, actualHeight: actual.height, target: target, visible: visible)
        guard abs(anchored.x - actual.x) > 1 || abs(anchored.y - actual.y) > 1 else { return actual }
        return try window.setOrigin(Point(x: anchored.x, y: anchored.y))
    }
}
