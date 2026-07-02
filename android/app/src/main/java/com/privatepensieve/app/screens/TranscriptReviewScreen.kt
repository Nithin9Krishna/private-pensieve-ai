package com.privatepensieve.app.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.privatepensieve.app.ui.theme.PensieveColors

/**
 * Transcript Review Screen — post-recording editor with AI insight.
 * Matching Stitch design screen 12.
 */
@Composable
fun TranscriptReviewScreen(
    transcript: String,
    aiReply: String?,
    onSave: (String) -> Unit,
    onDiscard: () -> Unit
) {
    var editedTranscript by remember(transcript) { mutableStateOf(transcript) }
    var isEditing by remember { mutableStateOf(false) }

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 8.dp)
    ) {
        // Header
        Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Text("Review Transcript", fontSize = 20.sp, fontWeight = FontWeight.SemiBold,
                color = PensieveColors.textPrimary, modifier = Modifier.weight(1f))
            IconButton(onClick = { isEditing = !isEditing }) {
                Icon(if (isEditing) Icons.Default.Check else Icons.Default.Edit,
                    null, tint = PensieveColors.accentLavender)
            }
        }

        Spacer(Modifier.height(16.dp))

        // AI Insight card
        aiReply?.let { reply ->
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                colors = CardDefaults.cardColors(containerColor = PensieveColors.surfaceElevated)
            ) {
                Column(Modifier.padding(16.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.AutoAwesome, null, Modifier.size(14.dp),
                            tint = PensieveColors.accentLavender)
                        Spacer(Modifier.width(6.dp))
                        Text("AI Insight", fontSize = 12.sp, fontWeight = FontWeight.SemiBold,
                            color = PensieveColors.accentLavender)
                    }
                    Spacer(Modifier.height(8.dp))
                    Text(reply, fontSize = 14.sp, color = PensieveColors.textPrimary)
                }
            }
        }

        Spacer(Modifier.height(16.dp))

        // Transcript content
        Text("Your words", fontSize = 12.sp, fontWeight = FontWeight.Medium,
            color = PensieveColors.textMuted)
        Spacer(Modifier.height(8.dp))

        if (isEditing) {
            OutlinedTextField(
                value = editedTranscript,
                onValueChange = { editedTranscript = it },
                modifier = Modifier.fillMaxWidth().heightIn(min = 120.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = PensieveColors.accentLavender,
                    unfocusedBorderColor = PensieveColors.border,
                    focusedTextColor = PensieveColors.textPrimary,
                    unfocusedTextColor = PensieveColors.textPrimary,
                    cursorColor = PensieveColors.accentLavender,
                    focusedContainerColor = PensieveColors.surfaceSecondary,
                    unfocusedContainerColor = PensieveColors.surfaceSecondary
                ),
                shape = RoundedCornerShape(12.dp)
            )
        } else {
            Text(editedTranscript, fontSize = 14.sp, color = PensieveColors.textPrimary,
                modifier = Modifier
                    .fillMaxWidth()
                    .background(PensieveColors.surfaceSecondary, RoundedCornerShape(12.dp))
                    .padding(12.dp))
        }

        Spacer(Modifier.height(24.dp))

        // Save button
        Button(onClick = { onSave(editedTranscript) },
            modifier = Modifier.fillMaxWidth().height(50.dp),
            shape = RoundedCornerShape(14.dp),
            colors = ButtonDefaults.buttonColors(
                containerColor = PensieveColors.accentLavender, contentColor = PensieveColors.background
            )
        ) {
            Icon(Icons.Default.Download, null, Modifier.size(18.dp))
            Spacer(Modifier.width(8.dp))
            Text("Save to Vault", fontWeight = FontWeight.SemiBold)
        }

        Spacer(Modifier.height(12.dp))

        // Discard button
        OutlinedButton(onClick = onDiscard,
            modifier = Modifier.fillMaxWidth().height(44.dp),
            shape = RoundedCornerShape(14.dp),
            colors = ButtonDefaults.outlinedButtonColors(contentColor = PensieveColors.accentRed),
            border = null
        ) {
            Icon(Icons.Default.Delete, null, Modifier.size(16.dp))
            Spacer(Modifier.width(8.dp))
            Text("Discard")
        }
    }
}
