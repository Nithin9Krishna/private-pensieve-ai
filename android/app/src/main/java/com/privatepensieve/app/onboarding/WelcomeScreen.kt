package com.privatepensieve.app.onboarding

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.privatepensieve.app.ui.theme.PensieveColors

@Composable
fun WelcomeScreen(onContinue: () -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(PensieveColors.background)
            .padding(horizontal = 24.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Spacer(Modifier.weight(1f))

        // Orb
        Box(
            modifier = Modifier
                .size(140.dp)
                .clip(CircleShape)
                .background(
                    Brush.radialGradient(
                        colors = listOf(
                            PensieveColors.accentViolet,
                            PensieveColors.accentLavender.copy(alpha = 0.4f),
                            PensieveColors.background
                        )
                    )
                )
        )

        Spacer(Modifier.height(32.dp))

        Text(
            "Your thoughts,\nkept for you.",
            fontSize = 28.sp,
            fontWeight = FontWeight.SemiBold,
            color = PensieveColors.textPrimary,
            textAlign = TextAlign.Center
        )

        Spacer(Modifier.height(12.dp))

        Text(
            "An offline, private memory companion\nthat stays entirely on your device.",
            fontSize = 16.sp,
            color = PensieveColors.textSecondary,
            textAlign = TextAlign.Center
        )

        Spacer(Modifier.height(24.dp))

        // Privacy badges
        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            PrivacyBadge("LOCAL-ONLY")
            PrivacyBadge("OFFLINE")
        }

        Spacer(Modifier.weight(1f))

        // Continue button
        Button(
            onClick = onContinue,
            modifier = Modifier
                .fillMaxWidth()
                .height(54.dp),
            shape = RoundedCornerShape(16.dp),
            colors = ButtonDefaults.buttonColors(
                containerColor = PensieveColors.accentLavender,
                contentColor = PensieveColors.background
            )
        ) {
            Text("Continue →", fontSize = 16.sp, fontWeight = FontWeight.SemiBold)
        }

        Spacer(Modifier.height(16.dp))

        Text(
            "By continuing, you acknowledge that your data never\nleaves this device.",
            fontSize = 11.sp,
            color = PensieveColors.textMuted,
            textAlign = TextAlign.Center
        )

        Spacer(Modifier.height(32.dp))
    }
}

@Composable
fun PrivacyBadge(text: String) {
    Text(
        text = text,
        fontSize = 11.sp,
        fontWeight = FontWeight.Medium,
        color = PensieveColors.accentTeal,
        modifier = Modifier
            .background(PensieveColors.surfaceSecondary, RoundedCornerShape(20.dp))
            .padding(horizontal = 12.dp, vertical = 6.dp)
    )
}
