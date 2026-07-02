package com.privatepensieve.app.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.privatepensieve.app.ui.theme.PensieveColors

/**
 * Privacy Screen — product differentiator.
 * Shows all privacy status items and action buttons.
 */
@Composable
fun PrivacyScreen(modifier: Modifier = Modifier) {
    val scrollState = rememberScrollState()

    Column(
        modifier = modifier
            .fillMaxSize()
            .background(PensieveColors.background)
            .verticalScroll(scrollState)
            .padding(horizontal = 16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Header
        Text(
            text = "Privacy, by design",
            fontSize = 28.sp,
            fontWeight = FontWeight.Bold,
            color = PensieveColors.textPrimary,
            modifier = Modifier.padding(top = 24.dp)
        )

        Text(
            text = "Your memories do not leave this device.",
            fontSize = 14.sp,
            color = PensieveColors.textSecondary,
            modifier = Modifier.padding(top = 4.dp)
        )

        Spacer(modifier = Modifier.height(24.dp))

        // Status list
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(20.dp))
                .background(PensieveColors.surfacePrimary)
        ) {
            PrivacyStatusRow("Account", "Not required")
            HorizontalDivider(color = PensieveColors.border)
            PrivacyStatusRow("Server", "Not used")
            HorizontalDivider(color = PensieveColors.border)
            PrivacyStatusRow("Cloud", "Not used")
            HorizontalDivider(color = PensieveColors.border)
            PrivacyStatusRow("Internet", "Not required")
            HorizontalDivider(color = PensieveColors.border)
            PrivacyStatusRow("AI", "On-device")
            HorizontalDivider(color = PensieveColors.border)
            PrivacyStatusRow("Memories", "Encrypted locally")
            HorizontalDivider(color = PensieveColors.border)
            PrivacyStatusRow("Backup", "Manual encrypted export only")
            HorizontalDivider(color = PensieveColors.border)
            PrivacyStatusRow("Tracking", "None")
        }

        Spacer(modifier = Modifier.height(24.dp))

        // Action buttons
        val actions = listOf(
            "Export encrypted backup",
            "Import backup",
            "Manage offline brain pack",
            "Delete audio recordings",
            "Delete all memories",
            "View privacy promise",
            "View open-source code"
        )

        actions.forEach { action ->
            val isDestructive = action.startsWith("Delete")
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 4.dp)
                    .clip(RoundedCornerShape(16.dp))
                    .background(PensieveColors.surfacePrimary)
                    .padding(16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = action,
                    fontSize = 16.sp,
                    color = if (isDestructive) PensieveColors.accentRed else PensieveColors.textPrimary,
                    modifier = Modifier.weight(1f)
                )
            }
        }

        Spacer(modifier = Modifier.height(32.dp))
    }
}

@Composable
private fun PrivacyStatusRow(label: String, value: String) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 14.dp)
            .semantics { contentDescription = "$label: $value" },
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = label,
            fontSize = 16.sp,
            color = PensieveColors.textPrimary,
            modifier = Modifier.weight(1f)
        )
        Text(
            text = value,
            fontSize = 14.sp,
            color = PensieveColors.textSecondary
        )
    }
}
