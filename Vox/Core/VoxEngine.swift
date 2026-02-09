import Foundation
import SwiftUI
import AVFoundation

/// Central coordinator for Vox: manages recording, transcription, and clipboard.
@MainActor
class VoxEngine: ObservableObject {
    @Published var isRecording = false
    @Published var isTranscribing = false
    @Published var lastTranscription = ""
    @Published var statusMessage = "Ready"
    @Published var isModelLoaded = false

    private var whisperContext: WhisperContext?
    private let recorder = AudioRecorder()

    // User preferences
    @AppStorage("selectedModel") var selectedModel = "ggml-large-v3-turbo.bin"
    @AppStorage("autoPaste") var autoPaste = true
    @AppStorage("silenceThreshold") var silenceThreshold = 1.5

    private var modelsDirectory: URL {
        // Look for models in the app's Models directory or a shared location
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let modelsDir = appSupport.appendingPathComponent("Vox/Models")
        try? FileManager.default.createDirectory(at: modelsDir, withIntermediateDirectories: true)
        return modelsDir
    }

    init() {
        loadModel()
    }

    func loadModel() {
        statusMessage = "Loading model..."

        let modelPath = modelsDirectory.appendingPathComponent(selectedModel)

        // Also check the whisper.cpp models directory as fallback
        let fallbackPath = URL(fileURLWithPath: NSHomeDirectory())
            .appendingPathComponent("Development/whisper.cpp/models")
            .appendingPathComponent(selectedModel)

        let pathToUse = FileManager.default.fileExists(atPath: modelPath.path)
            ? modelPath
            : fallbackPath

        guard FileManager.default.fileExists(atPath: pathToUse.path) else {
            statusMessage = "Model not found: \(selectedModel)"
            isModelLoaded = false
            return
        }

        Task.detached { [weak self] in
            do {
                let context = try WhisperContext.createContext(path: pathToUse.path)
                await MainActor.run {
                    self?.whisperContext = context
                    self?.isModelLoaded = true
                    self?.statusMessage = "Ready"
                }
            } catch {
                await MainActor.run {
                    self?.statusMessage = "Failed to load model"
                    self?.isModelLoaded = false
                }
            }
        }
    }

    func toggleRecording() {
        if isRecording {
            stopAndTranscribe()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        guard isModelLoaded else {
            statusMessage = "No model loaded"
            return
        }

        do {
            let outputURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("vox-recording.wav")
            try recorder.startRecording(to: outputURL)
            isRecording = true
            statusMessage = "Listening..."
        } catch {
            statusMessage = "Mic error: \(error.localizedDescription)"
        }
    }

    private func stopAndTranscribe() {
        guard let recordingURL = recorder.stopRecording() else {
            isRecording = false
            statusMessage = "No recording"
            return
        }

        isRecording = false
        isTranscribing = true
        statusMessage = "Transcribing..."

        Task.detached { [weak self] in
            guard let self = self else { return }
            let context = await self.whisperContext

            guard let context = context else {
                await MainActor.run {
                    self.isTranscribing = false
                    self.statusMessage = "No model loaded"
                }
                return
            }

            do {
                let samples = try decodeWaveFile(recordingURL)
                await context.fullTranscribe(samples: samples)
                let text = await context.getTranscription()
                let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

                await MainActor.run {
                    self.lastTranscription = trimmed
                    self.isTranscribing = false
                    self.statusMessage = "Done"

                    if !trimmed.isEmpty {
                        self.copyToClipboard(trimmed)
                        if self.autoPaste {
                            self.pasteFromClipboard()
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    self.isTranscribing = false
                    self.statusMessage = "Transcription error"
                }
            }
        }
    }

    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }

    private func pasteFromClipboard() {
        // Simulate Cmd+V to paste into active app
        let source = CGEventSource(stateID: .hidSystemState)

        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true) // 'v'
        keyDown?.flags = .maskCommand

        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        keyUp?.flags = .maskCommand

        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }
}
