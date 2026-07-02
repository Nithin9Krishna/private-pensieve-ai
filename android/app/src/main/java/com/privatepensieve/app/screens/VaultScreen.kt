package com.privatepensieve.app.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.privatepensieve.app.ui.theme.PensieveColors

/**
 * Vault Screen — calm collection of memory fragments.
 * Shows empty state when no memories exist.
 */
@Composable
fun VaultScreen(modifier: Modifier = Modifier) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .background(PensieveColors.background)
            .padding(horizontal = 16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Header
        Text(
            text = "Your Vault",
            fontSize = 28.sp,
            fontWeight = FontWeight.Bold,
            color = PensieveColors.textPrimary,
            modifier = Modifier.padding(top = 24.dp)
        )

        Text(
            text = "Private memories, stored on this device.",
            fontSize = 14.sp,
            color = PensieveColors.textSecondary,
            modifier = Modifier.padding(top = 4.dp)
        )

        Spacer(modifier = Modifier.weight(1f))

        // Empty state
        Text(
            text = "Your vault is waiting.",
            fontSize = 22.sp,
            fontWeight = FontWeight.SemiBold,
            color = PensieveColors.textPrimary
        )

        Spacer(modifier = Modifier.height(8.dp))

        Text(
            text = "The moments you choose to save will appear here.",
            fontSize = 16.sp,
            color = PensieveColors.textSecondary,
            textAlign = TextAlign.Center,
            modifier = Modifier.padding(horizontal = 32.dp)
        )

        Spacer(modifier = Modifier.height(24.dp))

        Button(
            onClick = { /* TODO: Navigate to Talk tab */ },
            colors = ButtonDefaults.buttonColors(
                containerColor = PensieveColors.accentLavender,
                contentColor = PensieveColors.background
            ),
            shape = RoundedCornerShape(50)
        ) {
            Text(
                text = "Talk to me",
                fontSize = 16.sp,
                fontWeight = FontWeight.SemiBold,
                modifier = Modifier.padding(horizontal = 16.dp, vertical = 4.dp)
            )
        }

        Spacer(modifier = Modifier.weight(1f))
    }
}
