package com.privatepensieve.app.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Mic
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.privatepensieve.app.ui.theme.PensieveColors

/**
 * Talk Screen — main voice-first interaction screen.
 * Primary action: Hold to Speak.
 */
@Composable
fun TalkScreen(modifier: Modifier = Modifier) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .background(PensieveColors.background)
            .padding(horizontal = 16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Top status pills
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 16.dp),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            StatusPill(text = "Local-only", isPrimary = true)
            StatusPill(text = "Offline ready", isPrimary = false)
        }

        Spacer(modifier = Modifier.weight(1f))

        // Orb placeholder
        Box(
            modifier = Modifier
                .size(160.dp)
                .clip(CircleShape)
                .background(
                    Brush.radialGradient(
                        colors = listOf(
                            PensieveColors.accentViolet,
                            PensieveColors.accentLavender.copy(alpha = 0.3f),
                            PensieveColors.background
                        )
                    )
                )
                .semantics { contentDescription = "Pensieve orb — idle" }
        )

        Spacer(modifier = Modifier.height(24.dp))

        Text(
            text = "I'm here.",
            fontSize = 24.sp,
            fontWeight = FontWeight.SemiBold,
            color = PensieveColors.textPrimary
        )

        Spacer(modifier = Modifier.height(8.dp))

        Text(
            text = "Talk freely. I'll remember what matters.",
            fontSize = 16.sp,
            color = PensieveColors.textSecondary,
            textAlign = TextAlign.Center
        )

        Spacer(modifier = Modifier.weight(1f))

        // Microphone button
        IconButton(
            onClick = { /* TODO: Voice recording integration (VOICE-001) */ },
            modifier = Modifier
                .size(72.dp)
                .clip(CircleShape)
                .background(PensieveColors.accentLavender)
                .semantics { contentDescription = "Hold to speak" }
        ) {
            Icon(
                Icons.Filled.Mic,
                contentDescription = null,
                tint = PensieveColors.background,
                modifier = Modifier.size(28.dp)
            )
        }

        Spacer(modifier = Modifier.height(8.dp))

        Text(
            text = "Hold to Speak",
            fontSize = 13.sp,
            color = PensieveColors.textMuted
        )

        Spacer(modifier = Modifier.height(24.dp))

        Text(
            text = "Your memories stay on this device.",
            fontSize = 12.sp,
            color = PensieveColors.textMuted
        )

        Spacer(modifier = Modifier.height(16.dp))
    }
}

@Composable
fun StatusPill(text: String, isPrimary: Boolean) {
    Text(
        text = text,
        fontSize = 12.sp,
        color = if (isPrimary) PensieveColors.accentTeal else PensieveColors.accentBlue,
        modifier = Modifier
            .background(
                PensieveColors.surfaceSecondary,
                shape = RoundedCornerShape(10.dp)
            )
            .padding(horizontal = 8.dp, vertical = 4.dp)
    )
}
