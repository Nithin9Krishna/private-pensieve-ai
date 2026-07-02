package com.privatepensieve.app.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.privatepensieve.app.models.MemoryCard
import com.privatepensieve.app.recall.RecallEngine
import com.privatepensieve.app.ui.theme.PensieveColors
import kotlinx.coroutines.launch
import java.time.ZoneId
import java.time.format.DateTimeFormatter

/**
 * Enhanced Recall Screen — Ask Anything + evidence-bound answers.
 * Matches Stitch screens 06 (Ask) and 14 (Answer).
 */

sealed class RecallState {
    data object Idle : RecallState()
    data object Searching : RecallState()
    data class Answered(val result: RecallEngine.RecallResult) : RecallState()
    data class Error(val message: String) : RecallState()
}

@Composable
fun RecallScreen(modifier: Modifier = Modifier) {
    var questionText by remember { mutableStateOf("") }
    var state by remember { mutableStateOf<RecallState>(RecallState.Idle) }
    val scope = rememberCoroutineScope()
    val engine = remember { RecallEngine() }

    val suggestedQuestions = listOf(
        "What did I say about my goals?",
        "How was I feeling last week?",
        "Did I mention any career plans?",
        "What people did I talk about?",
        "What patterns do I notice?"
    )

    fun askQuestion(q: String) {
        if (q.isBlank()) return
        state = RecallState.Searching
        scope.launch {
            try {
                val result = engine.recall(q, emptyList()) // V1: empty candidates
                state = RecallState.Answered(result)
            } catch (e: Exception) {
                state = RecallState.Error("Recall failed: ${e.message}")
            }
        }
    }

    Column(
        modifier = modifier
            .fillMaxSize()
            .background(PensieveColors.background)
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Spacer(Modifier.height(24.dp))

        // Header
        Text("Ask Anything", fontSize = 28.sp, fontWeight = FontWeight.Bold,
            color = PensieveColors.textPrimary)
        Spacer(Modifier.height(4.dp))
        Text("I'll search only what you saved.", fontSize = 14.sp,
            color = PensieveColors.textSecondary)

        Spacer(Modifier.height(24.dp))

        // Search input
        OutlinedTextField(
            value = questionText,
            onValueChange = { questionText = it },
            placeholder = { Text("What would you like to remember?", color = PensieveColors.textMuted) },
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(20.dp),
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = PensieveColors.accentLavender,
                unfocusedBorderColor = PensieveColors.border,
                focusedTextColor = PensieveColors.textPrimary,
                unfocusedTextColor = PensieveColors.textPrimary,
                cursorColor = PensieveColors.accentLavender,
                focusedContainerColor = PensieveColors.surfaceElevated,
                unfocusedContainerColor = PensieveColors.surfaceElevated
            ),
            trailingIcon = {
                IconButton(onClick = { askQuestion(questionText) }) {
                    Icon(Icons.Default.ArrowUpward, null, tint = PensieveColors.accentLavender)
                }
            },
            singleLine = true
        )

        Spacer(Modifier.height(24.dp))

        when (val s = state) {
            is RecallState.Idle -> {
                Text("Suggested", fontSize = 12.sp, fontWeight = FontWeight.Medium,
                    color = PensieveColors.textMuted,
                    modifier = Modifier.fillMaxWidth())
                Spacer(Modifier.height(8.dp))

                suggestedQuestions.forEach { q ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 4.dp)
                            .clip(RoundedCornerShape(12.dp))
                            .background(PensieveColors.surfaceSecondary)
                            .clickable { questionText = q; askQuestion(q) }
                            .padding(14.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(Icons.Default.AutoAwesome, null, Modifier.size(14.dp),
                            tint = PensieveColors.accentLavender)
                        Spacer(Modifier.width(10.dp))
                        Text(q, fontSize = 14.sp, color = PensieveColors.textPrimary,
                            modifier = Modifier.weight(1f))
                        Icon(Icons.Default.ChevronRight, null, Modifier.size(14.dp),
                            tint = PensieveColors.textMuted)
                    }
                }
            }

            is RecallState.Searching -> {
                Spacer(Modifier.height(32.dp))
                CircularProgressIndicator(color = PensieveColors.accentLavender, modifier = Modifier.size(32.dp))
                Spacer(Modifier.height(12.dp))
                Text("Searching your memories…", fontSize = 14.sp, color = PensieveColors.textSecondary)
            }

            is RecallState.Answered -> {
                RecallAnswerContent(s.result) { state = RecallState.Idle; questionText = "" }
            }

            is RecallState.Error -> {
                Spacer(Modifier.height(32.dp))
                Icon(Icons.Default.Warning, null, Modifier.size(36.dp), tint = PensieveColors.accentAmber)
                Spacer(Modifier.height(8.dp))
                Text(s.message, fontSize = 14.sp, color = PensieveColors.textSecondary,
                    textAlign = TextAlign.Center)
                TextButton(onClick = { state = RecallState.Idle }) {
                    Text("Try Again", color = PensieveColors.accentLavender)
                }
            }
        }

        Spacer(Modifier.height(32.dp))
    }
}

@Composable
private fun RecallAnswerContent(result: RecallEngine.RecallResult, onNewQuestion: () -> Unit) {
    // AI Answer card
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(14.dp),
        colors = CardDefaults.cardColors(containerColor = PensieveColors.surfaceElevated)
    ) {
        Column(Modifier.padding(16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.Default.AutoAwesome, null, Modifier.size(14.dp),
                    tint = PensieveColors.accentLavender)
                Spacer(Modifier.width(6.dp))
                Text("Pensieve's Answer", fontSize = 12.sp, fontWeight = FontWeight.SemiBold,
                    color = PensieveColors.accentLavender)
            }
            Spacer(Modifier.height(8.dp))
            Text(result.answer, fontSize = 14.sp, color = PensieveColors.textPrimary)
        }
    }

    // Source evidence
    if (result.evidence.isNotEmpty()) {
        Spacer(Modifier.height(16.dp))
        Text("Source Evidence", fontSize = 12.sp, fontWeight = FontWeight.Medium,
            color = PensieveColors.textMuted, modifier = Modifier.fillMaxWidth())
        Spacer(Modifier.height(8.dp))

        result.evidence.forEach { card ->
            val dateStr = card.createdAt.atZone(ZoneId.systemDefault())
                .format(DateTimeFormatter.ofPattern("MMM d, yyyy"))
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 2.dp)
                    .background(PensieveColors.surfaceSecondary, RoundedCornerShape(8.dp))
                    .padding(10.dp),
                verticalAlignment = Alignment.Top
            ) {
                Box(
                    Modifier.padding(top = 4.dp).size(6.dp).clip(CircleShape)
                        .background(PensieveColors.accentTeal)
                )
                Spacer(Modifier.width(10.dp))
                Column {
                    Text(card.title, fontSize = 12.sp, fontWeight = FontWeight.Medium,
                        color = PensieveColors.textPrimary)
                    Text(dateStr, fontSize = 10.sp, color = PensieveColors.textMuted)
                }
            }
        }
    }

    Spacer(Modifier.height(16.dp))

    // New question button
    OutlinedButton(
        onClick = onNewQuestion,
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp),
        colors = ButtonDefaults.outlinedButtonColors(contentColor = PensieveColors.accentLavender)
    ) {
        Icon(Icons.Default.Refresh, null, Modifier.size(16.dp))
        Spacer(Modifier.width(8.dp))
        Text("Ask another question")
    }
}
