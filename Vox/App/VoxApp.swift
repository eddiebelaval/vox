import SwiftUI

@main
struct VoxApp: App {
    @StateObject private var engine = VoxEngine()

    var body: some Scene {
        // Menu bar app — no main window
        MenuBarExtra {
            VoxMenuView(engine: engine)
        } label: {
            Image(systemName: engine.isRecording ? "mic.fill" : "mic")
                .symbolRenderingMode(.hierarchical)
        }
        .menuBarExtraStyle(.window)

        // Settings window
        Settings {
            SettingsView(engine: engine)
        }
    }
}
