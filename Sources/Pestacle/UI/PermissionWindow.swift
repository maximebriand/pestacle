import AppKit
import SwiftUI

/// Explique pourquoi l'autorisation Accessibilité est nécessaire et ouvre le bon panneau.
@MainActor
final class PermissionWindow {
    private var window: NSWindow?
    private let openSettings: () -> Void

    init(openSettings: @escaping () -> Void) {
        self.openSettings = openSettings
    }

    var isVisible: Bool { window?.isVisible ?? false }

    func show() {
        if window == nil {
            let view = PermissionView(openSettings: openSettings, quit: { NSApp.terminate(nil) })
            let window = NSWindow(contentViewController: NSHostingController(rootView: view))
            window.title = String(localized: "Accessibility Access")
            window.styleMask = [.titled, .closable]
            window.isReleasedWhenClosed = false
            window.center()
            self.window = window
        }
        NSApp.activate()
        window?.makeKeyAndOrderFront(nil)
    }

    func close() {
        window?.close()
    }
}

private struct PermissionView: View {
    let openSettings: () -> Void
    let quit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: "rectangle.split.2x1")
                    .font(.system(size: 32))
                    .foregroundStyle(.tint)
                Text("Pestacle needs Accessibility access")
                    .font(.title3.bold())
            }
            Text("To move and resize the windows of other apps, Pestacle uses the macOS Accessibility features. Pestacle only changes window positions and sizes; it does not read their contents.")
                .fixedSize(horizontal: false, vertical: true)
            Text("In System Settings, turn on Pestacle in the list. This window closes by itself as soon as access is granted.")
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                Button("Quit Pestacle", action: quit)
                Spacer()
                Button("Open System Settings", action: openSettings)
                    .keyboardShortcut(.defaultAction)
            }
            .padding(.top, 6)
        }
        .padding(24)
        .frame(width: 440)
    }
}
