package com.privatepensieve.app.onboarding

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
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
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.privatepensieve.app.ui.theme.PensieveColors

enum class AIModelOption(
    val displayName: String,
    val description: String,
    val icon: ImageVector,
    val badge: String,
    val isAvailable: Boolean = true
) {
    DEFAULT(
        "Pensieve Default",
        "Works on all devices. Deterministic responses. Great for getting started.",
        Icons.Default.Memory,
        "ALWAYS AVAILABLE"
    ),
    GEMINI_NANO(
        "Gemini Nano",
        "Advanced on-device AI. Requires compatible hardware and AICore.",
        Icons.Default.AutoAwesome,
        "ON-DEVICE",
        isAvailable = true // Will check at runtime in production
    )
}

@Composable
fun AIModelScreen(onContinue: () -> Unit) {
    var selectedModel by remember { mutableStateOf(AIModelOption.DEFAULT) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(PensieveColors.background)
            .padding(horizontal = 24.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Spacer(Modifier.height(60.dp))

        Icon(Icons.Default.Memory, null, Modifier.size(48.dp), tint = PensieveColors.accentLavender)

        Spacer(Modifier.height(24.dp))

        Text("Choose your\nAI companion.", fontSize = 28.sp, fontWeight = FontWeight.SemiBold,
            color = PensieveColors.textPrimary, textAlign = TextAlign.Center)

        Spacer(Modifier.height(12.dp))

        Text("All AI runs locally on your device.\nYou can change this later in settings.",
            fontSize = 16.sp, color = PensieveColors.textSecondary, textAlign = TextAlign.Center)

        Spacer(Modifier.height(32.dp))

        AIModelOption.entries.forEach { model ->
            ModelCard(
                model = model,
                isSelected = selectedModel == model,
                onClick = { if (model.isAvailable) selectedModel = model }
            )
            Spacer(Modifier.height(12.dp))
        }

        Spacer(Modifier.weight(1f))

        Button(onClick = onContinue, modifier = Modifier.fillMaxWidth().height(54.dp),
            shape = RoundedCornerShape(16.dp),
            colors = ButtonDefaults.buttonColors(
                containerColor = PensieveColors.accentLavender, contentColor = PensieveColors.background
            )
        ) { Text("Begin →", fontSize = 16.sp, fontWeight = FontWeight.SemiBold) }

        Spacer(Modifier.height(32.dp))
    }
}

@Composable
private fun ModelCard(model: AIModelOption, isSelected: Boolean, onClick: () -> Unit) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(enabled = model.isAvailable, onClick = onClick),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = PensieveColors.surfaceSecondary),
        border = if (isSelected) BorderStroke(1.dp, PensieveColors.accentLavender.copy(alpha = 0.5f))
                 else null
    ) {
        Row(Modifier.padding(16.dp), verticalAlignment = Alignment.Top) {
            Icon(model.icon, null, Modifier.size(24.dp),
                tint = if (isSelected) PensieveColors.accentLavender else PensieveColors.textMuted)
            Spacer(Modifier.width(14.dp))
            Column(Modifier.weight(1f)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(model.displayName, fontSize = 14.sp, fontWeight = FontWeight.Medium,
                        color = PensieveColors.textPrimary)
                    Spacer(Modifier.width(8.dp))
                    Text(model.badge, fontSize = 9.sp, fontWeight = FontWeight.SemiBold,
                        color = PensieveColors.accentTeal,
                        modifier = Modifier
                            .background(PensieveColors.accentTeal.copy(alpha = 0.15f), RoundedCornerShape(20.dp))
                            .padding(horizontal = 6.dp, vertical = 2.dp))
                }
                Spacer(Modifier.height(4.dp))
                Text(model.description, fontSize = 12.sp, color = PensieveColors.textSecondary)
            }
            Spacer(Modifier.width(8.dp))
            // Radio indicator
            Box(
                modifier = Modifier
                    .size(22.dp)
                    .clip(CircleShape)
                    .background(
                        if (isSelected) PensieveColors.accentLavender.copy(alpha = 0.2f)
                        else PensieveColors.surfaceSecondary
                    ),
                contentAlignment = Alignment.Center
            ) {
                if (isSelected) {
                    Box(Modifier.size(12.dp).clip(CircleShape).background(PensieveColors.accentLavender))
                }
            }
        }
    }
}
