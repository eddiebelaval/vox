import Foundation
import whisper

enum WhisperError: Error {
    case couldNotInitializeContext
}

/// Swift wrapper around the whisper.cpp C library.
/// Thread-safe via Swift actor isolation — only one transcription at a time.
actor WhisperContext {
    private var context: OpaquePointer

    init(context: OpaquePointer) {
        self.context = context
    }

    deinit {
        whisper_free(context)
    }

    /// Run full transcription on audio samples (16kHz float32 mono).
    func fullTranscribe(samples: [Float]) {
        let maxThreads = max(1, min(8, cpuCount() - 2))
        var params = whisper_full_default_params(WHISPER_SAMPLING_GREEDY)

        "en".withCString { en in
            params.print_realtime   = false
            params.print_progress   = false
            params.print_timestamps = false
            params.print_special    = false
            params.translate        = false
            params.language         = en
            params.n_threads        = Int32(maxThreads)
            params.offset_ms        = 0
            params.no_context       = true
            params.single_segment   = false

            whisper_reset_timings(context)

            samples.withUnsafeBufferPointer { samples in
                if whisper_full(context, params, samples.baseAddress, Int32(samples.count)) != 0 {
                    print("[Vox] Failed to run whisper_full")
                }
            }
        }
    }

    /// Extract transcription text from all segments.
    func getTranscription() -> String {
        var transcription = ""
        for i in 0..<whisper_full_n_segments(context) {
            transcription += String(cString: whisper_full_get_segment_text(context, i))
        }
        return transcription
    }

    /// Create a new WhisperContext from a model file path.
    static func createContext(path: String) throws -> WhisperContext {
        var params = whisper_context_default_params()
        params.flash_attn = true

        guard let context = whisper_init_from_file_with_params(path, params) else {
            print("[Vox] Could not load model at \(path)")
            throw WhisperError.couldNotInitializeContext
        }

        return WhisperContext(context: context)
    }
}

fileprivate func cpuCount() -> Int {
    ProcessInfo.processInfo.processorCount
}
