import AppKit
import PestacleCore
import SwiftUI

@MainActor
final class SettingsWindow: NSObject, NSWindowDelegate {
    private var window: NSWindow?
    private let model: SettingsModel
    /// Appelé à chaque ouverture : relire l'ouverture de session, retenter les raccourcis inactifs.
    var onOpen: (() -> Void)?

    init(model: SettingsModel) {
        self.model = model
    }

    func show() {
        if window == nil {
            let window = NSWindow(contentViewController: NSHostingController(rootView: SettingsView(model: model)))
            window.title = String(localized: "Pestacle Settings")
            window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
            window.setContentSize(NSSize(width: 520, height: 680))
            window.isReleasedWhenClosed = false
            window.delegate = self
            window.center()
            self.window = window
        }
        onOpen?()
        NSApp.activate()
        window?.makeKeyAndOrderFront(nil)
    }

    func windowWillClose(_ notification: Notification) {
        model.stopRecording()
    }

    func windowDidResignKey(_ notification: Notification) {
        model.stopRecording()
    }
}

private struct SettingsView: View {
    @Bindable var model: SettingsModel
    @State private var confirmHidingIcon = false

    var body: some View {
        Form {
            ForEach(Array(WindowAction.groups.enumerated()), id: \.offset) { index, group in
                Section {
                    ForEach(group, id: \.self) { action in
                        ShortcutRow(model: model, action: action)
                    }
                } header: {
                    if index == 0 { Text("Shortcuts") }
                }
            }
            Section {
                HStack {
                    Button("Restore Default Shortcuts") { model.resetDefaults() }
                    Spacer()
                    Button("Import from Spectacle") {
                        model.notice = model.importFromSpectacle()
                            ? String(localized: "Your Spectacle shortcuts have been imported.")
                            : String(localized: "Spectacle's shortcuts file could not be read.")
                    }
                    .disabled(!model.canImportFromSpectacle)
                }
                if let notice = model.notice {
                    Text(notice).font(.callout).foregroundStyle(.secondary)
                }
            }

            Section("General") {
                Toggle("Cycle sizes when repeating a half or quarter", isOn: Binding(
                    get: { model.cyclesSizes },
                    set: { model.setCyclesSizes($0) }))
                Toggle("Show icon in menu bar", isOn: Binding(
                    get: { model.showsMenuBarIcon },
                    set: { show in
                        if show { model.setShowsMenuBarIcon(true) } else { confirmHidingIcon = true }
                    }))
                LoginItemRow(model: model)
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 460, minHeight: 400)
        .alert("Hide the menu bar icon?", isPresented: $confirmHidingIcon) {
            Button("Hide Icon") { model.setShowsMenuBarIcon(false) }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Pestacle keeps running in the background. To open Settings again, launch Pestacle again from the Finder or Spotlight.")
        }
    }
}

private struct ShortcutRow: View {
    @Bindable var model: SettingsModel
    let action: WindowAction

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(action.title)
                Spacer()
                if model.inactive.contains(action) {
                    Label("Inactive", systemImage: "exclamationmark.triangle.fill")
                        .labelStyle(.titleAndIcon)
                        .font(.caption)
                        .foregroundStyle(.orange)
                        .help(Text("Another app is using this shortcut. Pestacle will try again when that app quits."))
                }
                Button {
                    model.recording == action ? model.stopRecording() : model.startRecording(action)
                } label: {
                    Text(buttonTitle)
                        .monospacedDigit()
                        .frame(minWidth: 110)
                }
                if model.label(for: action) != nil && model.recording != action {
                    Button {
                        _ = model.assign(nil, action)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                    .buttonStyle(.borderless)
                    .foregroundStyle(.secondary)
                    .help(Text("Clear Shortcut"))
                }
            }
            if let error = model.errors[action] {
                Text(error).font(.caption).foregroundStyle(.red)
            }
        }
    }

    private var buttonTitle: String {
        if model.recording == action { return String(localized: "Type Shortcut…") }
        return model.label(for: action) ?? String(localized: "Record Shortcut")
    }
}

private struct LoginItemRow: View {
    @Bindable var model: SettingsModel

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Toggle("Launch at login", isOn: Binding(
                get: { model.loginItem != .disabled },
                set: { model.loginItem = model.setLoginItem($0) }))
            if model.loginItem == .requiresApproval {
                HStack {
                    Text("Waiting for approval in System Settings.")
                        .font(.caption).foregroundStyle(.secondary)
                    Button("Open Login Items Settings") { model.openLoginItemsSettings() }
                        .controlSize(.small)
                }
            }
        }
    }
}
