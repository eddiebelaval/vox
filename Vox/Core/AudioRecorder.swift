import Foundation
import AVFoundation

/// Records audio from the default microphone to a WAV file.
/// Whisper expects: 16kHz, mono, 16-bit PCM.
class AudioRecorder {
    private var recorder: AVAudioRecorder?
    private var outputURL: URL?

    enum RecorderError: Error {
        case couldNotStartRecording
        case noOutputFile
    }

    func startRecording(to url: URL) throws {
        // Clean up any previous recording
        recorder?.stop()
        recorder = nil

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16000.0,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        recorder = try AVAudioRecorder(url: url, settings: settings)
        outputURL = url

        guard recorder?.record() == true else {
            throw RecorderError.couldNotStartRecording
        }
    }

    /// Stops recording and returns the URL of the recorded file.
    func stopRecording() -> URL? {
        recorder?.stop()
        recorder = nil
        return outputURL
    }

    var isRecording: Bool {
        recorder?.isRecording ?? false
    }
}
