# Architecture

## Architectural principle
Native-first, local-first, layered memory, offline by default.

## Platform stacks
### iOS
- Swift
- SwiftUI
- LocalAuthentication
- Keychain
- AVAudioEngine / AVFoundation
- Speech abstraction with native/provider implementation
- AVSpeechSynthesizer
- Foundation Models abstraction when supported
- Encrypted SQLite/SQLCipher-compatible vault abstraction

### Android
- Kotlin
- Jetpack Compose
- BiometricPrompt
- Android Keystore
- AudioRecord / MediaRecorder abstraction
- Speech abstraction with native/provider implementation
- TextToSpeech
- Gemini Nano / AICore abstraction when supported
- Room + encrypted SQLite/SQLCipher-compatible vault abstraction

## Modules
1. **Presentation** — UI state, navigation, accessibility.
2. **Voice Engine** — recording, silence state, transcription interface, transcript editing, TTS.
3. **AI Brain Router** — selects an available on-device provider; never calls remote inference.
4. **Memory Ingestion** — transcript to structured memory card, deduplication, daily summaries, stable fact candidates.
5. **Recall Engine** — query classification, candidate retrieval, ranking, context compression, evidence-bound answer.
6. **Vault** — encrypted persistence, key handling, migrations, deletion, retention.
7. **Backup** — encrypted export/import and integrity checks.
8. **Privacy Guard** — network guard tests, audit events stored locally only, privacy dashboard state.

## Request flow: save a voice thought
Voice recording → local transcription → transcript preview → AI brain extracts `MemoryCard` JSON → dedupe → persist conversation + card → update daily summary/facts → UI confirmation.

## Request flow: recall
Voice/text query → classify `MEMORY_RECALL | REFLECTION | GENERAL_FRIEND` → retrieve local evidence → rank → compress to 3–5 evidence items → local AI response → source-aware UI answer.

## Never do this
- Send raw transcript to a remote endpoint
- Put full life history into prompt/context
- Directly expose raw DB files
- Save audio by default without consent
