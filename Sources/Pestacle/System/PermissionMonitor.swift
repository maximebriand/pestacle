import AppKit
import ApplicationServices
import OSLog

/// Suit l'autorisation Accessibilité : interrogation chaque seconde tant qu'elle manque,
/// et vérification à la demande avant chaque action.
@MainActor
final class PermissionMonitor {
    private let log = Logger(subsystem: "fr.maximebriand.Pestacle", category: "permission")
    private var timer: Timer?
    private(set) var isTrusted: Bool
    /// Appelé à chaque changement d'état.
    var onChange: ((Bool) -> Void)?

    init() {
        isTrusted = AXIsProcessTrusted()
    }

    /// Démarre le suivi. Aucune invite système : Pestacle montre sa propre explication.
    func start() {
        log.info("autorisation au démarrage : \(self.isTrusted)")
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { _ = self?.refresh() }
        }
    }

    /// Relit l'état réel et notifie s'il a changé.
    @discardableResult
    func refresh() -> Bool {
        let now = AXIsProcessTrusted()
        if now != isTrusted {
            isTrusted = now
            log.info("autorisation : \(now)")
            onChange?(now)
        }
        return now
    }

    static let settingsURL = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!

    func openSystemSettings() {
        NSWorkspace.shared.open(Self.settingsURL)
    }
}
