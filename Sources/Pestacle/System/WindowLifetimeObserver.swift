import AppKit
import ApplicationServices
import OSLog

/// Prévient quand une fenêtre suivie est détruite ou que son app quitte, pour libérer son historique.
/// Chrome et les apps Electron émettent mal la destruction : l'orchestrateur purge aussi à l'usage.
@MainActor
final class WindowLifetimeObserver {
    private let log = Logger(subsystem: "fr.maximebriand.Pestacle", category: "lifetime")
    private var observers: [pid_t: AXObserver] = [:]
    private var tracked: Set<WindowKey> = []
    private var terminationObserver: NSObjectProtocol?

    var onWindowClosed: ((WindowKey) -> Void)?
    var onAppTerminated: ((pid_t) -> Void)?

    init() {
        terminationObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didTerminateApplicationNotification, object: nil, queue: .main
        ) { [weak self] note in
            guard let app = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else { return }
            let pid = app.processIdentifier
            MainActor.assumeIsolated { self?.appTerminated(pid) }
        }
    }

    func track(_ key: WindowKey) {
        guard !tracked.contains(key), let observer = observer(for: key.pid) else { return }
        let refcon = Unmanaged.passUnretained(self).toOpaque()
        let status = AXObserverAddNotification(observer, key.element, kAXUIElementDestroyedNotification as CFString, refcon)
        if status == .success || status == .notificationAlreadyRegistered { tracked.insert(key) }
    }

    var trackedCount: Int { tracked.count }

    private func observer(for pid: pid_t) -> AXObserver? {
        if let existing = observers[pid] { return existing }
        var observer: AXObserver?
        let status = AXObserverCreate(pid, { _, element, _, refcon in
            guard let refcon else { return }
            let me = Unmanaged<WindowLifetimeObserver>.fromOpaque(refcon).takeUnretainedValue()
            nonisolated(unsafe) let element = element
            MainActor.assumeIsolated { me.destroyed(element) }
        }, &observer)
        guard status == .success, let observer else { return nil }
        CFRunLoopAddSource(CFRunLoopGetMain(), AXObserverGetRunLoopSource(observer), .defaultMode)
        observers[pid] = observer
        return observer
    }

    private func destroyed(_ element: AXUIElement) {
        guard let key = tracked.first(where: { CFEqual($0.element, element) }) else { return }
        tracked.remove(key)
        log.info("fenêtre fermée, historique libéré (pid \(key.pid))")
        onWindowClosed?(key)
    }

    private func appTerminated(_ pid: pid_t) {
        tracked = tracked.filter { $0.pid != pid }
        if let observer = observers.removeValue(forKey: pid) {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), AXObserverGetRunLoopSource(observer), .defaultMode)
        }
        onAppTerminated?(pid)
    }
}
