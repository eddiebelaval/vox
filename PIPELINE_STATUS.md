# Vox - Pipeline Status

**Project:** Vox - Local Speech-to-Text for macOS
**Repo:** `github.com/eddiebelaval/vox`
**Current Stage:** 10 (Ship)
**Last Updated:** 2026-02-09

---

## Stage 1: Concept Lock [CLEARED]

**One-liner:** Local Whisper-based speech-to-text menu bar app for macOS that replaces native dictation with zero API costs.

**Who it's for:** Developers and power users who want fast, private, local dictation on Apple Silicon Macs.

**Checkpoint cleared:** 2026-02-09

---

## Stage 2: Scope Fence [CLEARED]

### V1 Core Features (max 5)
1. Record from microphone via menu bar UI
2. Transcribe locally using whisper.cpp on Metal GPU
3. Auto-copy to clipboard + auto-paste into active app
4. Settings for model selection, auto-paste toggle, silence threshold
5. launchd auto-start (runs at login, restarts on crash)

### "Not Yet" List
- Built-in global hotkey (using Karabiner externally for now)
- Factory-inspired design system (dark theme, orange accent)
- Model download/management UI
- CoreML encoder support (Metal-only for V1)
- Auto-silence detection in recording
- Language selection (English-only for V1)
- Model quantization UI (q5_0, q8_0)
- Notification sound on transcription complete

**Agent-Native:** N/A (utility app, no agent features)

**Checkpoint cleared:** 2026-02-09

---

## Stage 3: Architecture Sketch [CLEARED]

### Stack
- **Language:** Swift 5.9+ / SwiftUI
- **Engine:** whisper.cpp (C/C++) via XCFramework
- **GPU:** Metal (Apple Silicon)
- **Audio:** AVFoundation (AVAudioRecorder + AVAudioConverter)
- **UI:** SwiftUI MenuBarExtra (macOS 13+)
- **Package:** Swift Package Manager (binary target for XCFramework)

### Component Map
```
VoxApp (SwiftUI @main)
  |
  +-- VoxEngine (@MainActor ObservableObject)
  |     |-- AudioRecorder (AVAudioRecorder wrapper)
  |     |-- WhisperContext (Swift actor, wraps whisper.cpp C API)
  |     |-- WaveDecoder (AVAudioFile -> Float32 samples)
  |     +-- Clipboard + CGEvent paste
  |
  +-- VoxMenuView (menu bar popup)
  +-- SettingsView (General, Model, About tabs)
```

### Data Flow
```
Mic -> AVAudioRecorder -> WAV (16kHz mono) -> WaveDecoder -> [Float]
  -> WhisperContext.fullTranscribe() -> Text -> Clipboard -> Cmd+V paste
```

**Checkpoint cleared:** 2026-02-09

---

## Stage 4: Foundation Pour [CLEARED]

- [x] GitHub repo created: `eddiebelaval/vox` (public, MIT)
- [x] SPM package with binary target for whisper.xcframework
- [x] XCFramework built (macOS arm64, Metal + Accelerate)
- [x] Release binary installs to `~/.local/bin/Vox`
- [x] launchd plist: `com.id8labs.vox` (RunAtLoad, KeepAlive on crash)
- [x] Install script: `scripts/install.sh` (build + install + restart)
- [x] Log output: `~/Library/Logs/claude-automation/vox/`

**Checkpoint cleared:** 2026-02-09

---

## Stage 5: Feature Blocks [CLEARED]

### Feature: Core Transcription
- [x] Record from default microphone
- [x] Decode any audio format to 16kHz mono float32
- [x] Transcribe via whisper.cpp Metal GPU
- [x] Copy result to clipboard
- [x] Auto-paste via CGEvent (Cmd+V simulation)
- [x] Menu bar icon changes during recording (mic -> mic.fill)

### Feature: Settings
- [x] Auto-paste toggle (persisted via @AppStorage)
- [x] Model selection (persisted via @AppStorage)
- [x] Silence threshold slider
- [x] Model reload button
- [x] About view with id8Labs branding

### Feature: Model Loading
- [x] Load model from Application Support directory
- [x] Fallback to ~/Development/whisper.cpp/models/
- [x] Async model loading (non-blocking UI)
- [x] Status indicator (loaded/not loaded)

**Checkpoint cleared:** 2026-02-09

---

## Stage 6: Integration Pass [CLEARED]

- [x] HYDRA integration: Replaced Deepgram Nova-2 STT with local whisper-cli in telegram-listener.sh
- [x] Pipeline: Telegram OGG -> ffmpeg 16kHz WAV -> whisper-cli (Metal GPU) -> text
- [x] Zero API cost, zero latency for HYDRA voice commands
- [x] Deepgram Aura preserved as TTS fallback (different concern)
- [x] CLI dictation script at ~/.local/bin/dictate (independent tool)
- [x] Karabiner double-command hotkey configured (needs manual enable)

**Checkpoint cleared:** 2026-02-09

---

## Stage 7: Test Coverage [CLEARED - ADAPTED]

**Adaptation note:** Vox is a single-purpose utility app (7 source files, ~400 lines of Swift). Full test pyramid is disproportionate. Testing strategy adapted to match scope.

- [x] Manual smoke test: model loads, records, transcribes, pastes (confirmed working 2026-02-09)
- [x] HYDRA integration test: OGG->WAV->whisper pipeline verified with JFK sample
- [x] Build verification: `swift build -c release` succeeds clean

**Checkpoint cleared:** 2026-02-09 (adapted for utility app scope)

---

## Stage 8: Polish & Harden [CLEARED]

- [x] Microphone permission request on first use
- [x] Model not found: actionable error message with path guidance
- [x] Recording too short: graceful handling (< 100 bytes)
- [x] Empty transcription: "No speech detected" status
- [x] Transcription errors: logged with full error description
- [x] Temp file cleanup on app exit
- [x] Menu bar icon state management (recording/transcribing/ready)

**Checkpoint cleared:** 2026-02-09

---

## Stage 9: Launch Prep [CLEARED]

- [x] README.md with accurate build instructions (SPM, not Xcode)
- [x] LICENSE file (MIT)
- [x] .gitignore covers .build/, Models/, whisper.xcframework internals
- [x] Install script documented
- [x] GitHub repo public and accessible

**Checkpoint cleared:** 2026-02-09

---

## Stage 10: Ship [CLEARED]

- [x] Running in production locally (launchd managed)
- [x] Available on GitHub: github.com/eddiebelaval/vox
- [x] Tagged v0.1.0
- [x] HYDRA using local Whisper for all voice transcription

**Checkpoint cleared:** 2026-02-09

---

## Stage 11: Listen & Iterate [ACTIVE]

### Planned V2 Features
- Built-in global hotkey (remove Karabiner dependency)
- Factory-inspired dark theme UI
- Model download/management from within the app
- Auto-silence detection (auto-stop recording)
- Multiple language support
- Model quantization (q5_0 for faster inference)
- Notification sound on transcription complete

### Metrics to Watch
- Transcription accuracy (manual spot checks)
- Time-to-transcribe for typical voice memos (target: <2s for 30s audio)
- Memory usage after model load (target: <2GB resident)

---

## Overrides
- Stage 7 adapted: Full test pyramid replaced with manual + integration smoke tests (utility app, 7 files, 400 LOC)
