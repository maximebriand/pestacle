import AppKit
import PestacleCore

/// Ce que Pestacle sait de Spectacle sur ce Mac.
@MainActor
enum Spectacle {
    static let bundleIdentifier = "com.divisiblebyzero.Spectacle"

    static var shortcutsFile: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appending(path: "Library/Application Support/Spectacle/Shortcuts.json")
    }

    /// Raccourcis personnalisés dans Spectacle (`nil` = effacé), ou `nil` si le fichier est absent
    /// ou illisible. Les valeurs par défaut de Spectacle sont écartées : elles reçoivent les
    /// défauts de Pestacle, adaptés à la disposition clavier.
    static func importedShortcuts() -> [WindowAction: Shortcut?]? {
        guard let data = try? Data(contentsOf: shortcutsFile),
              let all = SpectacleImporter.shortcuts(from: data) else { return nil }
        return DefaultShortcuts.customizations(in: all)
    }

    static var runningInstances: [NSRunningApplication] {
        NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier)
    }

    static func quit() {
        for app in runningInstances { app.terminate() }
    }
}
