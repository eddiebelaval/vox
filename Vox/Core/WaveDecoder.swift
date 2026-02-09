import Foundation

/// Decodes a WAV file into float32 samples at 16kHz mono (what Whisper expects).
func decodeWaveFile(_ url: URL) throws -> [Float] {
    let data = try Data(contentsOf: url)

    // WAV header is 44 bytes
    guard data.count > 44 else {
        throw WaveError.invalidFile
    }

    // Read WAV header fields
    let channels = data.subdata(in: 22..<24).withUnsafeBytes { $0.load(as: UInt16.self) }
    let sampleRate = data.subdata(in: 24..<28).withUnsafeBytes { $0.load(as: UInt32.self) }
    let bitsPerSample = data.subdata(in: 34..<36).withUnsafeBytes { $0.load(as: UInt16.self) }

    guard bitsPerSample == 16 else {
        throw WaveError.unsupportedFormat("Expected 16-bit PCM, got \(bitsPerSample)-bit")
    }

    // Extract raw PCM data (skip 44-byte header)
    let pcmData = data.subdata(in: 44..<data.count)
    let sampleCount = pcmData.count / (Int(channels) * 2) // 2 bytes per 16-bit sample

    // Convert Int16 PCM to Float32, take first channel if stereo
    var floatSamples = [Float](repeating: 0, count: sampleCount)

    pcmData.withUnsafeBytes { rawBuffer in
        let int16Buffer = rawBuffer.bindMemory(to: Int16.self)
        for i in 0..<sampleCount {
            let sampleIndex = i * Int(channels) // Skip extra channels
            if sampleIndex < int16Buffer.count {
                floatSamples[i] = Float(int16Buffer[sampleIndex]) / 32768.0
            }
        }
    }

    return floatSamples
}

enum WaveError: Error {
    case invalidFile
    case unsupportedFormat(String)
}
