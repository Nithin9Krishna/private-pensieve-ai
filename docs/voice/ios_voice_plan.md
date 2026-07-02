# iOS Voice Plan

- Request microphone permission only when user taps Hold to Speak.
- Use AVAudioEngine for local recording.
- Use Apple Speech framework through `LocalSpeechTranscriber`.
- If local speech fails, show transcript preview with editable mock/fallback text.
- Use AVSpeechSynthesizer for local voice replies.
- Audio files stay local and may be deleted after transcript confirmation.
