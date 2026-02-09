# Vox

Local-first speech-to-text for macOS, powered by [whisper.cpp](https://github.com/ggml-org/whisper.cpp).

Vox is a native macOS menu bar app that replaces system dictation with a locally-running Whisper model. No API calls, no subscriptions, no data leaving your machine.

## Features

- **Fully local** — All transcription runs on-device via Metal GPU acceleration
- **Menu bar app** — Lives in your menu bar, triggered by global hotkey
- **Auto-silence detection** — Stops recording when you stop talking
- **Paste anywhere** — Transcription auto-pastes into the active app
- **Large model support** — Runs `large-v3-turbo` (809M params) at 7x realtime on Apple Silicon

## Requirements

- macOS 14.0+
- Apple Silicon (M1/M2/M3/M4)
- Xcode 15+ (for building)

## Getting Started

### 1. Clone

```bash
git clone https://github.com/id8labs/vox.git
cd vox
```

### 2. Download a Model

```bash
# Download the recommended model (~1.5GB)
./scripts/download-model.sh large-v3-turbo

# Or a smaller model for faster inference
./scripts/download-model.sh base.en
```

### 3. Build & Run

Open `Vox.xcodeproj` in Xcode, select the Vox scheme, and run.

## Architecture

```
Vox/
  App/              # SwiftUI app lifecycle
  UI/               # Views (MenuBar, RecordingPill, Settings)
  Core/             # WhisperEngine, AudioRecorder, HotkeyManager
  Models/           # Downloaded .bin model files (gitignored)
  Resources/        # Assets, sounds
whisper.cpp/        # Git submodule — the C/C++ engine
scripts/            # Build helpers, model download
```

Vox wraps whisper.cpp as a static XCFramework and uses Swift/C interop to call the transcription engine directly. The UI is pure SwiftUI with `MenuBarExtra` for the menu bar integration.

## Tech Stack

- **Language:** Swift 5.9+ / SwiftUI
- **Engine:** whisper.cpp (C/C++) via XCFramework
- **GPU:** Metal (Apple Silicon)
- **Audio:** AVFoundation
- **UI:** SwiftUI `MenuBarExtra`

## License

MIT

## Credits

Built by [id8Labs](https://id8labs.app). Powered by [whisper.cpp](https://github.com/ggml-org/whisper.cpp) by Georgi Gerganov.
