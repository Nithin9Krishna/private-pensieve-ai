package com.privatepensieve.app.onboarding

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.privatepensieve.app.ui.theme.PensieveColors

@Composable
fun SecuritySetupScreen(onContinue: () -> Unit, onSkip: () -> Unit) {
    var biometricEnabled by remember { mutableStateOf(false) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(PensieveColors.background)
            .padding(horizontal = 24.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Spacer(Modifier.height(60.dp))

        Icon(Icons.Default.Fingerprint, null, Modifier.size(48.dp), tint = PensieveColors.accentLavender)

        Spacer(Modifier.height(24.dp))

        Text("Protect your\nmemories.", fontSize = 28.sp, fontWeight = FontWeight.SemiBold,
            color = PensieveColors.textPrimary, textAlign = TextAlign.Center)

        Spacer(Modifier.height(12.dp))

        Text("Add biometric lock so only you can access your vault.",
            fontSize = 16.sp, color = PensieveColors.textSecondary, textAlign = TextAlign.Center)

        Spacer(Modifier.height(40.dp))

        // Biometric toggle card
        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(12.dp),
            colors = CardDefaults.cardColors(containerColor = PensieveColors.surfaceSecondary)
        ) {
            Row(
                modifier = Modifier.padding(16.dp).fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(Icons.Default.Fingerprint, null, Modifier.size(24.dp),
                    tint = PensieveColors.accentLavender)
                Spacer(Modifier.width(14.dp))
                Column(Modifier.weight(1f)) {
                    Text("Biometric Lock", fontSize = 14.sp, fontWeight = FontWeight.Medium,
                        color = PensieveColors.textPrimary)
                    Text("Require fingerprint/face to open Pensieve",
                        fontSize = 12.sp, color = PensieveColors.textSecondary)
                }
                Switch(
                    checked = biometricEnabled,
                    onCheckedChange = { biometricEnabled = it },
                    colors = SwitchDefaults.colors(
                        checkedThumbColor = PensieveColors.background,
                        checkedTrackColor = PensieveColors.accentLavender
                    )
                )
            }
        }

        Spacer(Modifier.height(12.dp))

        Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(Icons.Default.Key, null, Modifier.size(14.dp), tint = PensieveColors.textMuted)
            Spacer(Modifier.width(8.dp))
            Text("Device passcode is used as fallback.", fontSize = 12.sp,
                color = PensieveColors.textMuted)
        }

        Spacer(Modifier.weight(1f))

        Button(onClick = onContinue, modifier = Modifier.fillMaxWidth().height(54.dp),
            shape = RoundedCornerShape(16.dp),
            colors = ButtonDefaults.buttonColors(
                containerColor = PensieveColors.accentLavender, contentColor = PensieveColors.background
            )
        ) {
            Text(
                if (biometricEnabled) "Enable Biometric →" else "Continue without lock →",
                fontSize = 16.sp, fontWeight = FontWeight.SemiBold
            )
        }

        Spacer(Modifier.height(12.dp))

        TextButton(onClick = onSkip) {
            Text("Skip for now", color = PensieveColors.textMuted)
        }

        Spacer(Modifier.height(32.dp))
    }
}
