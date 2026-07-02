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
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.privatepensieve.app.ui.theme.PensieveColors

@Composable
fun PrivacyInfoScreen(onContinue: () -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(PensieveColors.background)
            .padding(horizontal = 24.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Spacer(Modifier.height(60.dp))

        Icon(Icons.Default.Shield, null, Modifier.size(48.dp), tint = PensieveColors.accentTeal)

        Spacer(Modifier.height(24.dp))

        Text("Your privacy,\nby design.", fontSize = 28.sp, fontWeight = FontWeight.SemiBold,
            color = PensieveColors.textPrimary, textAlign = TextAlign.Center)

        Spacer(Modifier.height(32.dp))

        FeatureRow(Icons.Default.PhoneAndroid, "On-device only",
            "Your memories never leave this phone. No servers. No cloud sync.")
        Spacer(Modifier.height(20.dp))
        FeatureRow(Icons.Default.Lock, "Encrypted vault",
            "All data is encrypted with a key only your device holds.")
        Spacer(Modifier.height(20.dp))
        FeatureRow(Icons.Default.Psychology, "Local AI",
            "Speech recognition and AI run entirely on your device.")
        Spacer(Modifier.height(20.dp))
        FeatureRow(Icons.Default.Delete, "You own deletion",
            "Delete any memory instantly. No backups retained without your consent.")

        Spacer(Modifier.weight(1f))

        Button(onClick = onContinue, modifier = Modifier.fillMaxWidth().height(54.dp),
            shape = RoundedCornerShape(16.dp),
            colors = ButtonDefaults.buttonColors(
                containerColor = PensieveColors.accentLavender, contentColor = PensieveColors.background
            )
        ) { Text("Continue →", fontSize = 16.sp, fontWeight = FontWeight.SemiBold) }

        Spacer(Modifier.height(32.dp))
    }
}

@Composable
private fun FeatureRow(icon: ImageVector, title: String, description: String) {
    Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.Top) {
        Icon(icon, null, Modifier.size(24.dp).padding(top = 2.dp), tint = PensieveColors.accentLavender)
        Spacer(Modifier.width(16.dp))
        Column {
            Text(title, fontSize = 14.sp, fontWeight = FontWeight.Medium, color = PensieveColors.textPrimary)
            Spacer(Modifier.height(4.dp))
            Text(description, fontSize = 12.sp, color = PensieveColors.textSecondary)
        }
    }
}
