package com.privatepensieve.app.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.privatepensieve.app.ui.theme.PensieveColors

/**
 * Recall Screen — ask your past self.
 * Critical: no-results fallback must be EXACT text from AGENTS.md.
 */
@Composable
fun RecallScreen(modifier: Modifier = Modifier) {
    val suggestedQuestions = listOf(
        "What did I say about my goals?",
        "When was I feeling stressed?",
        "What made me happy recently?",
        "What did I promise myself?",
        "What has been on my mind lately?"
    )

    Column(
        modifier = modifier
            .fillMaxSize()
            .background(PensieveColors.background)
            .padding(horizontal = 16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Header
        Text(
            text = "Ask your past self",
            fontSize = 28.sp,
            fontWeight = FontWeight.Bold,
            color = PensieveColors.textPrimary,
            modifier = Modifier.padding(top = 24.dp)
        )

        Text(
            text = "I'll search only what you saved.",
            fontSize = 14.sp,
            color = PensieveColors.textSecondary,
            modifier = Modifier.padding(top = 4.dp)
        )

        Spacer(modifier = Modifier.height(32.dp))

        // Suggested questions
        suggestedQuestions.forEach { question ->
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 6.dp)
                    .clip(RoundedCornerShape(20.dp))
                    .background(PensieveColors.surfaceSecondary)
                    .clickable { /* TODO: Execute recall query (RECALL-001) */ }
                    .padding(16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = question,
                    fontSize = 16.sp,
                    color = PensieveColors.textPrimary,
                    modifier = Modifier.weight(1f)
                )
            }
        }

        Spacer(modifier = Modifier.weight(1f))

        // No-results state (shown when recall returns empty)
        // Text shown here for layout reference — in production this
        // appears conditionally based on RecallState
        /*
        Text(
            text = "I don't remember you telling me that yet.",
            fontSize = 18.sp,
            fontWeight = FontWeight.Medium,
            color = PensieveColors.textPrimary,
            textAlign = TextAlign.Center
        )
        */
    }
}
