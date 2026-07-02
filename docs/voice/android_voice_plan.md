# Android Voice Plan

- Add RECORD_AUDIO permission only; do not add INTERNET.
- Use AudioRecord for local recording.
- Use Android SpeechRecognizer through a `LocalSpeechTranscriber` interface.
- If transcription fails, allow editable mock/fallback transcript.
- Use Android TextToSpeech for local voice reply.
- Keep audio local and delete temporary audio after transcript confirmation when possible.
