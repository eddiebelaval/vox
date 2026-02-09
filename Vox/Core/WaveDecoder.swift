import Foundation
import AVFoundation

/// Decodes a WAV/audio file into float32 samples at 16kHz mono (what Whisper expects).
/// Uses AVAudioFile for robust format handling — supports any format macOS can read.
func decodeWaveFile(_ url: URL) throws -> [Float] {
    let audioFile = try AVAudioFile(forReading: url)

    // Target format: 16kHz, mono, float32 (what Whisper expects)
    guard let targetFormat = AVAudioFormat(
        commonFormat: .pcmFormatFloat32,
        sampleRate: 16000.0,
        channels: 1,
        interleaved: false
    ) else {
        throw WaveError.unsupportedFormat("Could not create target audio format")
    }

    let sourceFormat = audioFile.processingFormat
    let sourceFrameCount = AVAudioFrameCount(audioFile.length)

    print("[Vox] Audio file: \(sourceFormat.sampleRate)Hz, \(sourceFormat.channelCount)ch, \(sourceFrameCount) frames")

    // Read source audio into a buffer
    guard let sourceBuffer = AVAudioPCMBuffer(
        pcmFormat: sourceFormat,
        frameCapacity: sourceFrameCount
    ) else {
        throw WaveError.unsupportedFormat("Could not create source buffer")
    }
    try audioFile.read(into: sourceBuffer)

    // If already 16kHz mono float32, return directly
    if sourceFormat.sampleRate == 16000.0 && sourceFormat.channelCount == 1 {
        guard let channelData = sourceBuffer.floatChannelData else {
            throw WaveError.unsupportedFormat("Could not read float channel data")
        }
        let frameCount = Int(sourceBuffer.frameLength)
        return Array(UnsafeBufferPointer(start: channelData[0], count: frameCount))
    }

    // Convert to 16kHz mono
    guard let converter = AVAudioConverter(from: sourceFormat, to: targetFormat) else {
        throw WaveError.unsupportedFormat("Could not create audio converter from \(sourceFormat) to \(targetFormat)")
    }

    // Calculate output frame count based on sample rate ratio
    let ratio = 16000.0 / sourceFormat.sampleRate
    let outputFrameCount = AVAudioFrameCount(Double(sourceFrameCount) * ratio)

    guard let outputBuffer = AVAudioPCMBuffer(
        pcmFormat: targetFormat,
        frameCapacity: outputFrameCount
    ) else {
        throw WaveError.unsupportedFormat("Could not create output buffer")
    }

    var error: NSError?
    let inputBlock: AVAudioConverterInputBlock = { _, outStatus in
        outStatus.pointee = .haveData
        return sourceBuffer
    }

    converter.convert(to: outputBuffer, error: &error, withInputFrom: inputBlock)

    if let error = error {
        throw WaveError.unsupportedFormat("Conversion error: \(error.localizedDescription)")
    }

    guard let channelData = outputBuffer.floatChannelData else {
        throw WaveError.unsupportedFormat("Could not read converted channel data")
    }

    let frameCount = Int(outputBuffer.frameLength)
    print("[Vox] Converted to \(frameCount) samples at 16kHz mono")
    return Array(UnsafeBufferPointer(start: channelData[0], count: frameCount))
}

enum WaveError: Error, LocalizedError {
    case invalidFile
    case unsupportedFormat(String)

    var errorDescription: String? {
        switch self {
        case .invalidFile: return "Invalid audio file"
        case .unsupportedFormat(let msg): return msg
        }
    }
}
