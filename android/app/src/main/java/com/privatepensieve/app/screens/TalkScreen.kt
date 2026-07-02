package com.privatepensieve.app.screens

import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.privatepensieve.app.ui.theme.PensieveColors

/**
 * Talk Screen — main voice-first interaction screen.
 * States: Idle → Recording → Transcribing → Preview → Saving → Saved
 */
@Composable
fun TalkScreen(modifier: Modifier = Modifier, vm: TalkViewModel = viewModel()) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .background(PensieveColors.background)
            .padding(horizontal = 16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Top status pills
        Row(
            modifier = Modifier.fillMaxWidth().padding(top = 16.dp),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            StatusPill("Local-only", isPrimary = true)
            when (vm.state) {
                is TalkViewModel.TalkState.Recording ->
                    StatusPill("RECORDING", isPrimary = false, isRecording = true)
                else -> StatusPill("Offline ready", isPrimary = false)
            }
        }

        Spacer(Modifier.weight(1f))

        // Center content
        when (val state = vm.state) {
            is TalkViewModel.TalkState.Idle -> IdleContent()
            is TalkViewModel.TalkState.Recording -> RecordingContent(vm.formattedDuration, vm.liveTranscript)
            is TalkViewModel.TalkState.Transcribing -> TranscribingContent()
            is TalkViewModel.TalkState.Preview ->
                TranscriptReviewScreen(
                    transcript = state.transcript,
                    aiReply = state.aiReply,
                    onSave = { vm.saveTranscript(it) },
                    onDiscard = { vm.discard() }
                )
            is TalkViewModel.TalkState.Saving -> SavingContent()
            is TalkViewModel.TalkState.Saved -> SavedContent()
            is TalkViewModel.TalkState.Error -> ErrorContent(state.message) { vm.discard() }
        }

        Spacer(Modifier.weight(1f))

        // Bottom action
        when (vm.state) {
            is TalkViewModel.TalkState.Idle -> {
                MicButton(onClick = { vm.startRecording() }, label = "Hold to Speak")
            }
            is TalkViewModel.TalkState.Recording -> {
                StopButton(onClick = { vm.stopRecording() })
            }
            else -> Spacer(Modifier.height(96.dp))
        }

        Text("Your memories stay on this device.", fontSize = 12.sp,
            color = PensieveColors.textMuted, modifier = Modifier.padding(bottom = 16.dp))
    }
}

@Composable
private fun IdleContent() {
    val infiniteTransition = rememberInfiniteTransition(label = "orb")
    val scale by infiniteTransition.animateFloat(
        initialValue = 0.95f, targetValue = 1.05f,
        animationSpec = infiniteRepeatable(tween(2000), RepeatMode.Reverse),
        label = "orbScale"
    )
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Box(
            modifier = Modifier.size(160.dp).scale(scale).clip(CircleShape)
                .background(Brush.radialGradient(listOf(
                    PensieveColors.accentViolet,
                    PensieveColors.accentLavender.copy(0.3f),
                    PensieveColors.background
                )))
                .semantics { contentDescription = "Pensieve orb — idle" }
        )
        Spacer(Modifier.height(24.dp))
        Text("I'm here.", fontSize = 24.sp, fontWeight = FontWeight.SemiBold,
            color = PensieveColors.textPrimary)
        Spacer(Modifier.height(8.dp))
        Text("Talk freely. I'll remember what matters.", fontSize = 16.sp,
            color = PensieveColors.textSecondary, textAlign = TextAlign.Center)
    }
}

@Composable
private fun RecordingContent(duration: String, liveTranscript: String) {
    val infiniteTransition = rememberInfiniteTransition(label = "recording")
    val scale by infiniteTransition.animateFloat(
        initialValue = 0.90f, targetValue = 1.15f,
        animationSpec = infiniteRepeatable(tween(800), RepeatMode.Reverse),
        label = "recordScale"
    )
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Box(
            modifier = Modifier.size(180.dp).scale(scale).clip(CircleShape)
                .background(Brush.radialGradient(listOf(
                    PensieveColors.accentViolet,
                    PensieveColors.accentLavender.copy(0.5f),
                    PensieveColors.background
                )))
                .semantics { contentDescription = "Pensieve orb — listening" }
        )
        Spacer(Modifier.height(16.dp))
        Text(duration, fontSize = 24.sp, fontWeight = FontWeight.Medium,
            color = PensieveColors.accentLavender, fontFamily = androidx.compose.ui.text.font.FontFamily.Monospace)
        Spacer(Modifier.height(8.dp))
        Text("Listening...", fontSize = 16.sp, color = PensieveColors.textSecondary)

        if (liveTranscript.isNotBlank()) {
            Spacer(Modifier.height(16.dp))
            Text(liveTranscript, fontSize = 14.sp, color = PensieveColors.textPrimary,
                modifier = Modifier.background(PensieveColors.surfaceSecondary, RoundedCornerShape(12.dp))
                    .padding(12.dp).fillMaxWidth())
        }

        Spacer(Modifier.height(12.dp))
        Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(Icons.Default.Lock, null, Modifier.size(12.dp), tint = PensieveColors.accentTeal)
            Spacer(Modifier.width(4.dp))
            Text("LOCAL-ONLY ENCRYPTION", fontSize = 10.sp, fontWeight = FontWeight.SemiBold,
                color = PensieveColors.accentTeal)
        }
    }
}

@Composable
private fun TranscribingContent() {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        CircularProgressIndicator(color = PensieveColors.accentLavender, modifier = Modifier.size(48.dp))
        Spacer(Modifier.height(16.dp))
        Text("Transcribing...", fontSize = 16.sp, color = PensieveColors.textSecondary)
    }
}

@Composable
private fun SavingContent() {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        CircularProgressIndicator(color = PensieveColors.accentLavender, modifier = Modifier.size(32.dp))
        Spacer(Modifier.height(16.dp))
        Text("Saving to your vault...", fontSize = 16.sp, color = PensieveColors.textSecondary)
    }
}

@Composable
private fun SavedContent() {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Icon(Icons.Default.CheckCircle, null, Modifier.size(48.dp), tint = PensieveColors.accentTeal)
        Spacer(Modifier.height(16.dp))
        Text("Memory saved", fontSize = 20.sp, fontWeight = FontWeight.SemiBold,
            color = PensieveColors.textPrimary)
        Text("Stored safely in your vault.", fontSize = 16.sp, color = PensieveColors.textSecondary)
    }
}

@Composable
private fun ErrorContent(message: String, onRetry: () -> Unit) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Icon(Icons.Default.Warning, null, Modifier.size(36.dp), tint = PensieveColors.accentAmber)
        Spacer(Modifier.height(12.dp))
        Text(message, fontSize = 14.sp, color = PensieveColors.textSecondary, textAlign = TextAlign.Center)
        Spacer(Modifier.height(12.dp))
        TextButton(onClick = onRetry) { Text("Try Again", color = PensieveColors.accentLavender) }
    }
}

@Composable
private fun MicButton(onClick: () -> Unit, label: String) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        IconButton(onClick = onClick,
            modifier = Modifier.size(72.dp).clip(CircleShape).background(PensieveColors.accentLavender)
                .semantics { contentDescription = label }
        ) {
            Icon(Icons.Filled.Mic, null, tint = PensieveColors.background, modifier = Modifier.size(28.dp))
        }
        Spacer(Modifier.height(8.dp))
        Text(label, fontSize = 13.sp, color = PensieveColors.textMuted)
        Spacer(Modifier.height(24.dp))
    }
}

@Composable
private fun StopButton(onClick: () -> Unit) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        IconButton(onClick = onClick,
            modifier = Modifier.size(72.dp).clip(CircleShape).background(PensieveColors.accentRed)
                .semantics { contentDescription = "Stop recording" }
        ) {
            Icon(Icons.Filled.Stop, null, tint = PensieveColors.background, modifier = Modifier.size(28.dp))
        }
        Spacer(Modifier.height(8.dp))
        Text("Tap to Stop", fontSize = 13.sp, color = PensieveColors.textMuted)
        Spacer(Modifier.height(24.dp))
    }
}

@Composable
fun StatusPill(text: String, isPrimary: Boolean, isRecording: Boolean = false) {
    Text(
        text = text,
        fontSize = 12.sp,
        color = when {
            isRecording -> PensieveColors.accentRed
            isPrimary -> PensieveColors.accentTeal
            else -> PensieveColors.accentBlue
        },
        modifier = Modifier
            .background(PensieveColors.surfaceSecondary, shape = RoundedCornerShape(10.dp))
            .padding(horizontal = 8.dp, vertical = 4.dp)
    )
}
