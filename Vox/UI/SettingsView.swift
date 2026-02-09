import SwiftUI

/// Settings window for Vox preferences.
struct SettingsView: View {
    @ObservedObject var engine: VoxEngine

    var body: some View {
        TabView {
            GeneralSettingsView(engine: engine)
                .tabItem {
                    Label("General", systemImage: "gear")
                }

            ModelSettingsView(engine: engine)
                .tabItem {
                    Label("Model", systemImage: "cpu")
                }

            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 450, height: 300)
    }
}

struct GeneralSettingsView: View {
    @ObservedObject var engine: VoxEngine

    var body: some View {
        Form {
            Toggle("Auto-paste after transcription", isOn: $engine.autoPaste)

            // TODO: Global hotkey picker
            LabeledContent("Hotkey") {
                Text("Coming soon")
                    .foregroundColor(.secondary)
            }

            LabeledContent("Silence detection") {
                Slider(value: $engine.silenceThreshold, in: 0.5...3.0, step: 0.5)
                Text("\(engine.silenceThreshold, specifier: "%.1f")s")
                    .monospacedDigit()
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

struct ModelSettingsView: View {
    @ObservedObject var engine: VoxEngine

    var body: some View {
        Form {
            LabeledContent("Current model") {
                Text(engine.selectedModel)
                    .font(.system(.body, design: .monospaced))
            }

            LabeledContent("Status") {
                HStack {
                    Circle()
                        .fill(engine.isModelLoaded ? .green : .red)
                        .frame(width: 8, height: 8)
                    Text(engine.isModelLoaded ? "Loaded" : "Not loaded")
                }
            }

            Button("Reload Model") {
                engine.loadModel()
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.orange)

            Text("Vox")
                .font(.system(.title, design: .rounded, weight: .light))

            Text("Local-first speech-to-text")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("Powered by whisper.cpp")
                .font(.caption)
                .foregroundColor(.tertiary)

            Link("id8Labs", destination: URL(string: "https://id8labs.app")!)
                .font(.caption)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
