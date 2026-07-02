package com.privatepensieve.app.voice

import android.content.Context
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import com.privatepensieve.app.providers.TTSProvider
import kotlinx.coroutines.suspendCancellableCoroutine
import java.util.Locale
import java.util.UUID
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

/**
 * Real on-device text-to-speech using Android's TextToSpeech API.
 * No network. No cloud. Fully local synthesis.
 */
class AndroidTTS(context: Context) : TTSProvider {

    private var tts: TextToSpeech? = null
    private var isInitialized = false

    override val isAvailable: Boolean get() = isInitialized

    init {
        tts = TextToSpeech(context) { status ->
            if (status == TextToSpeech.SUCCESS) {
                tts?.language = Locale.US
                tts?.setSpeechRate(0.9f) // Slightly slower for warmth
                tts?.setPitch(1.0f)
                isInitialized = true
            }
        }
    }

    override suspend fun speak(text: String) {
        if (!isInitialized) throw RuntimeException("TTS not initialized")

        return suspendCancellableCoroutine { continuation ->
            val utteranceId = UUID.randomUUID().toString()

            tts?.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
                override fun onStart(id: String?) {}
                override fun onDone(id: String?) {
                    if (id == utteranceId) continuation.resume(Unit)
                }
                override fun onError(id: String?) {
                    if (id == utteranceId) continuation.resumeWithException(
                        RuntimeException("TTS error for utterance $id")
                    )
                }
            })

            tts?.speak(text, TextToSpeech.QUEUE_FLUSH, null, utteranceId)

            continuation.invokeOnCancellation { tts?.stop() }
        }
    }

    override fun stop() {
        tts?.stop()
    }

    fun shutdown() {
        tts?.shutdown()
        tts = null
        isInitialized = false
    }
}
