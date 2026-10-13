import ApplicationServices
import Testing
import PestacleCore
@testable import Pestacle

/// Fenêtre simulée ; `constrain` reproduit les tailles imposées par une app.
@MainActor
final class FakeWindow: ManagedWindow {
    let key: WindowKey
    var current: Rect
    var constrain: (Rect) -> Rect = { $0 }
    var failure: WindowFailure?
    private(set) var writes = 0

    init(pid: pid_t = 4242, frame: Rect) {
        key = WindowKey(pid: pid, element: AXUIElementCreateApplication(pid))
        current = frame
    }

    func frame() throws(WindowFailure) -> Rect {
        if let failure { throw failure }
        return current
    }

    func setFrame(_ frame: Rect) throws(WindowFailure) -> Rect {
        if let failure { throw failure }
        writes += 1
        current = constrain(frame)
        return current
    }

    func setOrigin(_ origin: Point) throws(WindowFailure) -> Rect {
        writes += 1
        current.x = origin.x
        current.y = origin.y
        return current
    }
}

@MainActor
final class FakeEnvironment: WindowSource, ScreenSource, ActionFeedback {
    var focused: Result<any ManagedWindow, WindowFailure>
    var screens: [Screen] = [Screen(id: 1, frame: Rect(x: 0, y: 0, width: 1600, height: 1000),
                                     visibleFrame: Rect(x: 0, y: 0, width: 1600, height: 1000))]
    var pointer = Point(x: 10, y: 10)
    var trusted = true
    var cycles = true
    private(set) var beeps = 0
    private(set) var explanations = 0

    init(window: FakeWindow?) {
        focused = window.map { .success($0) } ?? .failure(.noFocusedWindow)
    }

    func focusedWindow() -> Result<any ManagedWindow, WindowFailure> { focused }
    func beep() { beeps += 1 }
    func explainPermission() { explanations += 1 }

    func coordinator() -> ActionCoordinator {
        ActionCoordinator(windows: self, screens: self, isTrusted: { [unowned self] in trusted },
                          feedback: self, options: { [unowned self] in LayoutOptions(cyclesSizes: cycles) })
    }
}

@Suite("Orchestration des actions")
@MainActor
struct ActionCoordinatorTests {
    let start = Rect(x: 100, y: 100, width: 700, height: 500)
    let leftHalf = Rect(x: 0, y: 0, width: 800, height: 1000)
    let full = Rect(x: 0, y: 0, width: 1600, height: 1000)

    @Test("Succès : la fenêtre est placée et l'action est annulable")
    func success() {
        let window = FakeWindow(frame: start)
        let env = FakeEnvironment(window: window)
        let c = env.coordinator()
        #expect(c.perform(.leftHalf) == .moved(leftHalf))
        #expect(c.perform(.undo) == .moved(start))
        #expect(env.beeps == 0)
    }

    @Test("Pas de fenêtre : son d'alerte")
    func noWindow() {
        let env = FakeEnvironment(window: nil)
        #expect(env.coordinator().perform(.leftHalf) == .failed(.noFocusedWindow))
        #expect(env.beeps == 1)
    }

    @Test("Fenêtre refusée (feuille, fenêtre de Pestacle) : son d'alerte, rien n'est écrit", arguments: [
        WindowFailure.sheet, .systemDialog, .minimized, .nativeFullscreen, .ownWindow,
    ])
    func refused(failure: WindowFailure) {
        let env = FakeEnvironment(window: nil)
        env.focused = .failure(failure)
        #expect(env.coordinator().perform(.fullscreen) == .failed(failure))
        #expect(env.beeps == 1)
    }

    @Test("Déjà en place : pas d'écriture, pas d'historique, son d'alerte")
    func unchanged() {
        let window = FakeWindow(frame: full)
        let env = FakeEnvironment(window: window)
        let c = env.coordinator()
        #expect(c.perform(.fullscreen) == .unchanged)
        #expect(window.writes == 0)
        #expect(!c.history.canUndo(window.key))
        #expect(env.beeps == 1)
    }

    @Test("Sans autorisation : rien ne bouge, l'explication s'affiche, pas de son")
    func notTrusted() {
        let window = FakeWindow(frame: start)
        let env = FakeEnvironment(window: window)
        env.trusted = false
        #expect(env.coordinator().perform(.leftHalf) == .failed(.notTrusted))
        #expect(window.writes == 0)
        #expect(env.explanations == 1 && env.beeps == 0)
    }

    @Test("App qui ne répond pas : action abandonnée avec le son d'alerte")
    func timeout() {
        let window = FakeWindow(frame: start)
        window.failure = .timedOut
        let env = FakeEnvironment(window: window)
        #expect(env.coordinator().perform(.leftHalf) == .failed(.timedOut))
        #expect(env.beeps == 1)
    }

    @Test("Action impossible (un seul écran) : son d'alerte")
    func unavailable() {
        let env = FakeEnvironment(window: FakeWindow(frame: start))
        #expect(env.coordinator().perform(.nextDisplay) == .unavailable)
        #expect(env.beeps == 1)
    }

    @Test("Taille minimale imposée : la fenêtre est recalée contre les bords visés")
    func reanchorsConstrainedWindow() {
        let window = FakeWindow(frame: start)
        window.constrain = { Rect(x: $0.x, y: $0.y, width: max($0.width, 900), height: $0.height) }
        let env = FakeEnvironment(window: window)
        #expect(env.coordinator().perform(.upperRight) == .moved(Rect(x: 700, y: 0, width: 900, height: 500)))
    }

    @Test("Annuler sans historique : son d'alerte")
    func undoEmpty() {
        let env = FakeEnvironment(window: FakeWindow(frame: start))
        #expect(env.coordinator().perform(.undo) == .unavailable)
        #expect(env.beeps == 1)
    }

    @Test("Rétablir après annuler")
    func redo() {
        let window = FakeWindow(frame: start)
        let env = FakeEnvironment(window: window)
        let c = env.coordinator()
        c.perform(.leftHalf)
        c.perform(.fullscreen)
        #expect(c.perform(.undo) == .moved(leftHalf))
        #expect(c.perform(.redo) == .moved(full))
    }

    @Test("Fenêtre disparue pendant l'action : historique purgé")
    func invalidElementPurges() {
        let window = FakeWindow(frame: start)
        let env = FakeEnvironment(window: window)
        let c = env.coordinator()
        c.perform(.leftHalf)
        window.failure = .invalidElement
        #expect(c.perform(.undo) == .failed(.invalidElement))
        #expect(!c.history.canUndo(window.key))
    }

    @Test("Fenêtre suivie pour la purge, oubli par app")
    func trackingAndForgetByPid() {
        let window = FakeWindow(pid: 77, frame: start)
        let env = FakeEnvironment(window: window)
        let c = env.coordinator()
        var tracked: [WindowKey] = []
        c.onTrack = { tracked.append($0) }
        c.perform(.leftHalf)
        #expect(tracked == [window.key])
        c.forget(pid: 77)
        #expect(!c.history.canUndo(window.key))
    }

    @Test("Rattrapage différé : une app qui n'applique la taille qu'à la seconde écriture finit au bon cadre")
    func settlesLateSize() {
        let window = FakeWindow(frame: start)
        var writes = 0
        window.constrain = { f in
            writes += 1
            return writes <= 1 ? Rect(x: f.x, y: f.y, width: f.width, height: f.height - 4) : f
        }
        let env = FakeEnvironment(window: window)
        let c = env.coordinator()
        var pending: [() -> Void] = []
        c.later = { pending.append($0) }
        _ = c.perform(.leftHalf)
        #expect(window.current.height == 996)
        pending.forEach { $0() }
        #expect(window.current == leftHalf)
    }

    @Test("Pas de rattrapage quand le cadre est déjà juste")
    func noSettleWhenExact() {
        let env = FakeEnvironment(window: FakeWindow(frame: start))
        let c = env.coordinator()
        var scheduled = 0
        c.later = { _ in scheduled += 1 }
        _ = c.perform(.leftHalf)
        #expect(scheduled == 0)
    }

    @Test("Arrondi au-delà de la zone utile : taille redemandée diminuée du dépassement")
    func gridRoundingOverflow() {
        let window = FakeWindow(frame: start)
        // Grille de 15 pt en hauteur, arrondie au plus proche.
        window.constrain = { f in Rect(x: f.x, y: f.y, width: f.width, height: ((f.height - 4) / 15).rounded() * 15 + 4) }
        let env = FakeEnvironment(window: window)
        let c = env.coordinator()
        c.later = { _ in }
        guard case .moved(let frame) = c.perform(.leftHalf) else { Issue.record("pas déplacée"); return }
        #expect(frame.maxY <= 1000)
        #expect(frame.height == 994)
    }
}
