import OSLog
import ServiceManagement

/// Lancement à l'ouverture de session via `SMAppService.mainApp`. L'état est toujours relu
/// auprès du système, pour refléter une modification faite dans Réglages Système.
@MainActor
enum LoginItem {
    enum State: Equatable {
        case enabled
        case disabled
        /// Activé par l'app, mais l'utilisateur doit l'approuver dans Réglages Système.
        case requiresApproval
    }

    private static let log = Logger(subsystem: "fr.maximebriand.Pestacle", category: "login-item")

    static var state: State {
        switch SMAppService.mainApp.status {
        case .enabled: .enabled
        case .requiresApproval: .requiresApproval
        default: .disabled
        }
    }

    /// Active ou désactive, puis renvoie l'état réel obtenu.
    @discardableResult
    static func setEnabled(_ enabled: Bool) -> State {
        do {
            if enabled { try SMAppService.mainApp.register() } else { try SMAppService.mainApp.unregister() }
        } catch {
            log.error("élément d'ouverture : \(error.localizedDescription, privacy: .public)")
        }
        return state
    }

    static func openSystemSettings() {
        SMAppService.openSystemSettingsLoginItems()
    }
}
