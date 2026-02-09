# Vox

Local-first speech-to-text for macOS, powered by [whisper.cpp](https://github.com/ggml-org/whisper.cpp).

Vox is a native macOS menu bar app that replaces system dictation with a locally-running Whisper model. No API calls, no subscriptions, no data leaving your machine.

## Features

- **Fully local** -- All transcription runs on-device via Metal GPU acceleration
- **Menu bar app** -- Lives in your menu bar, one click to record
- **Auto-paste** -- Transcription copies to clipboard and pastes into the active app
- **Large model support** -- Runs `large-v3-turbo` (809M params) at 7x realtime on Apple Silicon
- **Always running** -- launchd managed, starts at login, restarts on crash

## Requirements

- macOS 14.0+
- Apple Silicon (M1/M2/M3/M4)
- Xcode 15+ (for building from source)
- A whisper.cpp model file (see below)

## Getting Started

### 1. Clone

```bash
git clone https://github.com/eddiebelaval/vox.git
cd vox
```

### 2. Build whisper.xcframework

Vox ships with a pre-built XCFramework, but if you need to rebuild it:

```bash
# Clone whisper.cpp
git clone https://github.com/ggml-org/whisper.cpp.git ~/whisper.cpp
cd ~/whisper.cpp

# Build for macOS
cmake -B build -DWHISPER_METAL=ON -DWHISPER_COREML=OFF
cmake --build build --config Release
```

### 3. Download a Model

```bash
# Download the recommended model (~1.5GB)
./scripts/download-model.sh large-v3-turbo
```

Or manually download from [Hugging Face](https://huggingface.co/ggerganov/whisper.cpp/tree/main) and place in:
- `~/Library/Application Support/Vox/Models/` (primary)
- `~/Development/whisper.cpp/models/` (fallback)

### 4. Build & Run

```bash
# Build and run directly
swift run Vox

# Or build release and install
./scripts/install.sh
```

The install script builds a release binary, copies it to `~/.local/bin/Vox`, and sets up a launchd agent so Vox starts at login.

## Architecture

```
Vox/
  App/              # SwiftUI app lifecycle (MenuBarExtra)
  UI/               # Views (VoxMenuView, SettingsView)
  Core/             # VoxEngine, AudioRecorder, WhisperContext, WaveDecoder
  Resources/        # Assets (reserved)
whisper.xcframework # Pre-built whisper.cpp static library (macOS arm64)
scripts/            # Build helpers, model download, install
```

### Data Flow

```
Microphone -> AVAudioRecorder -> WAV (16kHz mono)
  -> WaveDecoder (AVAudioConverter) -> [Float32]
  -> WhisperContext (whisper.cpp via Metal GPU) -> Text
  -> NSPasteboard -> CGEvent Cmd+V paste
```

## Tech Stack

- **Language:** Swift 5.9+ / SwiftUI
- **Engine:** whisper.cpp (C/C++) via XCFramework
- **GPU:** Metal (Apple Silicon)
- **Audio:** AVFoundation
- **UI:** SwiftUI MenuBarExtra
- **Package:** Swift Package Manager

## License

MIT -- see [LICENSE](LICENSE)

## Credits

Built by [id8Labs](https://id8labs.app). Powered by [whisper.cpp](https://github.com/ggml-org/whisper.cpp) by Georgi Gerganov.
