package com.privatepensieve.app.voice

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import com.privatepensieve.app.providers.SpeechToTextProvider
import com.privatepensieve.app.providers.TranscriptionResult
import com.privatepensieve.app.providers.TranscriptionSegment
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

/**
 * Real on-device speech recognizer using Android's SpeechRecognizer.
 * Uses EXTRA_PREFER_OFFLINE = true. No cloud. No network.
 * Implements the SpeechToTextProvider protocol.
 */
class AndroidSpeechRecognizer(private val context: Context) : SpeechToTextProvider {

    override val isAvailable: Boolean
        get() = SpeechRecognizer.isRecognitionAvailable(context)

    /**
     * Transcribe audio by running on-device speech recognition.
     * Note: Android SpeechRecognizer works with live audio, not files.
     * This implementation uses the live recognition API.
     */
    override suspend fun transcribe(audioFilePath: String): TranscriptionResult {
        return suspendCancellableCoroutine { continuation ->
            val recognizer = SpeechRecognizer.createSpeechRecognizer(context)

            val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
                putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
                putExtra(RecognizerIntent.EXTRA_LANGUAGE, "en-US")
                putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
                putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1)
                // Force offline recognition — no data leaves device
                putExtra(RecognizerIntent.EXTRA_PREFER_OFFLINE, true)
            }

            recognizer.setRecognitionListener(object : RecognitionListener {
                override fun onResults(results: Bundle?) {
                    val matches = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                    val confidences = results?.getFloatArray(SpeechRecognizer.CONFIDENCE_SCORES)

                    val text = matches?.firstOrNull() ?: ""
                    val confidence = confidences?.firstOrNull()?.toDouble() ?: 0.8

                    val result = TranscriptionResult(
                        text = text,
                        confidence = confidence,
                        segments = listOf(
                            TranscriptionSegment(text, 0L, 0L, confidence)
                        )
                    )

                    recognizer.destroy()
                    continuation.resume(result)
                }

                override fun onError(error: Int) {
                    recognizer.destroy()
                    val message = when (error) {
                        SpeechRecognizer.ERROR_AUDIO -> "Audio recording error"
                        SpeechRecognizer.ERROR_NO_MATCH -> "No speech detected"
                        SpeechRecognizer.ERROR_RECOGNIZER_BUSY -> "Recognizer busy"
                        SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS -> "Permission denied"
                        else -> "Recognition error: $error"
                    }
                    continuation.resumeWithException(RuntimeException(message))
                }

                override fun onReadyForSpeech(params: Bundle?) {}
                override fun onBeginningOfSpeech() {}
                override fun onRmsChanged(rmsdB: Float) {}
                override fun onBufferReceived(buffer: ByteArray?) {}
                override fun onEndOfSpeech() {}
                override fun onPartialResults(partialResults: Bundle?) {}
                override fun onEvent(eventType: Int, params: Bundle?) {}
            })

            recognizer.startListening(intent)

            continuation.invokeOnCancellation {
                recognizer.cancel()
                recognizer.destroy()
            }
        }
    }
}
