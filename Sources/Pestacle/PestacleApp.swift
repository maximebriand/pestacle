import AppKit

@main
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var controller: AppController?

    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Les tests hébergés chargent l'app : ne rien démarrer dans ce cas.
        guard NSClassFromString("XCTestCase") == nil, ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil else { return }
        let controller = AppController()
        self.controller = controller
        controller.start()
        #if DEBUG
        DebugChannel.shared.attach(to: controller)
        #endif
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        controller?.handleReopen()
        return false
    }
}
