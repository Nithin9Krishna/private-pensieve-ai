package com.privatepensieve.app.voice

/**
 * Voice state machine for the recording flow.
 * Transitions: Idle → Recording → Transcribing → Preview → Idle
 *                                                → Failed → Idle
 */
sealed class VoiceState {
    data object Idle : VoiceState()
    data object Recording : VoiceState()
    data object Transcribing : VoiceState()
    data class Preview(val transcript: String) : VoiceState()
    data class Failed(val message: String) : VoiceState()
}

/**
 * On-device speech-to-text abstraction.
 * Implementations: Android SpeechRecognizer (real), MockSpeechTranscriber (test)
 */
interface LocalSpeechTranscriber {
    suspend fun transcribeLocalAudio(path: String): String
}

/**
 * On-device text-to-speech abstraction.
 * Implementations: Android TextToSpeech (real), MockVoiceReplySpeaker (test)
 */
interface VoiceReplySpeaker {
    fun speak(text: String)
    fun stop()
}

/**
 * Deterministic mock for tests — no microphone or model required.
 */
class MockSpeechTranscriber : LocalSpeechTranscriber {
    var nextTranscript = "Mock local transcript from recorded audio."

    override suspend fun transcribeLocalAudio(path: String): String {
        return nextTranscript
    }
}

/**
 * Deterministic mock TTS for tests — no audio output.
 */
class MockVoiceReplySpeaker : VoiceReplySpeaker {
    var lastSpokenText: String? = null
        private set
    var isSpeaking: Boolean = false
        private set

    override fun speak(text: String) {
        lastSpokenText = text
        isSpeaking = true
    }

    override fun stop() {
        isSpeaking = false
    }
}
