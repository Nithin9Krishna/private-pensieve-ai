package com.privatepensieve.app.screens

import androidx.compose.runtime.*
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.privatepensieve.app.models.Conversation
import com.privatepensieve.app.models.MemoryCard
import com.privatepensieve.app.providers.FakeAIBrain
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.time.Instant
import java.util.UUID

/**
 * Talk screen ViewModel — state machine for voice flow.
 * idle → recording → transcribing → preview → saved
 */
class TalkViewModel : ViewModel() {

    sealed class TalkState {
        data object Idle : TalkState()
        data class Recording(val durationMs: Long = 0) : TalkState()
        data object Transcribing : TalkState()
        data class Preview(val transcript: String, val aiReply: String?) : TalkState()
        data object Saving : TalkState()
        data object Saved : TalkState()
        data class Error(val message: String) : TalkState()
    }

    var state by mutableStateOf<TalkState>(TalkState.Idle)
        private set

    var liveTranscript by mutableStateOf("")
        private set

    var recordingDurationMs by mutableLongStateOf(0L)
        private set

    private val aiBrain = FakeAIBrain()

    // MARK: - Actions

    fun startRecording() {
        if (state !is TalkState.Idle) return
        state = TalkState.Recording()
        recordingDurationMs = 0
        liveTranscript = ""

        // Simulate recording timer
        viewModelScope.launch {
            while (state is TalkState.Recording) {
                delay(100)
                recordingDurationMs += 100
                state = TalkState.Recording(recordingDurationMs)
            }
        }
    }

    fun stopRecording() {
        state = TalkState.Transcribing

        viewModelScope.launch {
            try {
                // Simulate transcription delay (V1: FakeSTT)
                delay(500)
                val transcript = "I was nervous today about whether this app can work, but I still feel it can help people keep their thoughts private."
                liveTranscript = transcript

                val reply = aiBrain.generateFriendReply(transcript, emptyList())
                state = TalkState.Preview(transcript, reply)
            } catch (e: Exception) {
                state = TalkState.Error("Transcription failed: ${e.message}")
            }
        }
    }

    fun saveTranscript(editedTranscript: String) {
        state = TalkState.Saving

        viewModelScope.launch {
            try {
                // 1. Create conversation
                val conversationId = UUID.randomUUID().toString()

                // 2. Extract memory cards
                val cards = aiBrain.extractMemory(editedTranscript)

                // 3. Generate friend reply
                val reply = aiBrain.generateFriendReply(editedTranscript, cards)

                // TODO: Persist to vault via DAOs when Context is available

                state = TalkState.Saved

                // Return to idle after delay
                delay(2000)
                state = TalkState.Idle
                liveTranscript = ""
            } catch (e: Exception) {
                state = TalkState.Error("Save failed: ${e.message}")
            }
        }
    }

    fun discard() {
        state = TalkState.Idle
        liveTranscript = ""
        recordingDurationMs = 0
    }

    val formattedDuration: String
        get() {
            val seconds = (recordingDurationMs / 1000).toInt()
            val mins = seconds / 60
            val secs = seconds % 60
            return "%02d:%02d".format(mins, secs)
        }
}
