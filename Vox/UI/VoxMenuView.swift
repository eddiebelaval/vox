import SwiftUI

/// The popup view that appears when clicking the menu bar icon.
struct VoxMenuView: View {
    @ObservedObject var engine: VoxEngine

    var body: some View {
        VStack(spacing: 12) {
            // Status indicator
            HStack(spacing: 8) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)

                Text(engine.statusMessage)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)

                Spacer()
            }

            // Record button
            Button(action: { engine.toggleRecording() }) {
                HStack {
                    Image(systemName: engine.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.title2)
                    Text(engine.isRecording ? "Stop" : "Record")
                        .font(.system(.body, design: .rounded, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .tint(engine.isRecording ? .red : .orange)
            .disabled(!engine.isModelLoaded || engine.isTranscribing || !engine.hasMicPermission)

            // Last transcription
            if !engine.lastTranscription.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Last transcription")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)

                    Text(engine.lastTranscription)
                        .font(.system(.caption, design: .default))
                        .lineLimit(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                        .background(.quaternary)
                        .cornerRadius(6)
                }
            }

            Divider()

            // Actions
            HStack {
                Button("Settings...") {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                }
                .font(.caption)

                Spacer()

                Button("Quit Vox") {
                    NSApplication.shared.terminate(nil)
                }
                .font(.caption)
            }
        }
        .padding(16)
        .frame(width: 280)
    }

    private var statusColor: Color {
        if engine.isRecording { return .red }
        if engine.isTranscribing { return .orange }
        if engine.isModelLoaded { return .green }
        return .gray
    }
}
