package com.privatepensieve.app.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.privatepensieve.app.models.MemoryCard
import com.privatepensieve.app.ui.theme.PensieveColors
import java.time.Instant
import java.time.ZoneId
import java.time.format.DateTimeFormatter

/**
 * Enhanced Vault Screen — Memory list, filters, search, detail sheet.
 * Matches Stitch screens 04 (Vault) and 15 (Empty).
 */

enum class VaultFilter(val label: String) {
    ALL("All"), IMPORTANT("Important"), GOALS("Goals"),
    PEOPLE("People"), FAVORITES("Favorites")
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun VaultScreen(modifier: Modifier = Modifier) {
    var activeFilter by remember { mutableStateOf(VaultFilter.ALL) }
    var selectedMemory by remember { mutableStateOf<MemoryCard?>(null) }
    // V1: Demo data — in production this comes from VaultDatabase DAO
    val memories = remember { mutableStateListOf<MemoryCard>() }
    val isEmpty = memories.isEmpty()

    Column(
        modifier = modifier
            .fillMaxSize()
            .background(PensieveColors.background)
    ) {
        // Header
        Text("Your Vault", fontSize = 28.sp, fontWeight = FontWeight.Bold,
            color = PensieveColors.textPrimary,
            modifier = Modifier.padding(start = 16.dp, top = 16.dp))
        Text("Private memories, stored on this device.", fontSize = 14.sp,
            color = PensieveColors.textSecondary,
            modifier = Modifier.padding(start = 16.dp, top = 4.dp))

        if (isEmpty) {
            VaultEmptyState()
        } else {
            Spacer(Modifier.height(16.dp))
            // Filter chips
            LazyRow(
                contentPadding = PaddingValues(horizontal = 16.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                items(VaultFilter.entries) { filter ->
                    FilterChipItem(
                        label = filter.label,
                        isSelected = activeFilter == filter,
                        onClick = { activeFilter = filter }
                    )
                }
            }

            Spacer(Modifier.height(8.dp))
            Text("${memories.size} memories", fontSize = 12.sp,
                color = PensieveColors.textMuted,
                modifier = Modifier.padding(horizontal = 16.dp))

            // Memory card list
            LazyColumn(
                contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                items(memories) { card ->
                    MemoryCardItem(card) { selectedMemory = card }
                }
            }
        }
    }

    // Memory detail bottom sheet
    selectedMemory?.let { memory ->
        ModalBottomSheet(
            onDismissRequest = { selectedMemory = null },
            containerColor = PensieveColors.background
        ) {
            MemoryDetailContent(memory, onDelete = {
                memories.remove(memory)
                selectedMemory = null
            })
        }
    }
}

@Composable
private fun VaultEmptyState() {
    Column(
        modifier = Modifier.fillMaxSize(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Box(
            Modifier.size(100.dp).clip(CircleShape).background(
                Brush.radialGradient(listOf(
                    PensieveColors.accentViolet.copy(0.5f),
                    PensieveColors.accentLavender.copy(0.2f),
                    PensieveColors.background
                ))
            )
        )
        Spacer(Modifier.height(24.dp))
        Text("Your vault is empty", fontSize = 22.sp, fontWeight = FontWeight.SemiBold,
            color = PensieveColors.textPrimary)
        Spacer(Modifier.height(8.dp))
        Text("Start talking and your memories\nwill be saved here.",
            fontSize = 16.sp, color = PensieveColors.textSecondary, textAlign = TextAlign.Center)
        Spacer(Modifier.height(24.dp))
        Button(
            onClick = { /* Navigate to Talk tab */ },
            shape = RoundedCornerShape(50),
            colors = ButtonDefaults.buttonColors(
                containerColor = PensieveColors.accentLavender, contentColor = PensieveColors.background
            )
        ) {
            Text("Start Talking →", fontWeight = FontWeight.SemiBold,
                modifier = Modifier.padding(horizontal = 16.dp, vertical = 4.dp))
        }
    }
}

@Composable
private fun FilterChipItem(label: String, isSelected: Boolean, onClick: () -> Unit) {
    Text(label, fontSize = 13.sp,
        fontWeight = if (isSelected) FontWeight.SemiBold else FontWeight.Normal,
        color = if (isSelected) PensieveColors.background else PensieveColors.textSecondary,
        modifier = Modifier
            .background(
                if (isSelected) PensieveColors.accentLavender else PensieveColors.surfaceSecondary,
                RoundedCornerShape(20.dp)
            )
            .clickable(onClick = onClick)
            .padding(horizontal = 14.dp, vertical = 8.dp))
}

@Composable
private fun MemoryCardItem(card: MemoryCard, onClick: () -> Unit) {
    val dateStr = remember(card.createdAt) {
        card.createdAt.atZone(ZoneId.systemDefault())
            .format(DateTimeFormatter.ofPattern("MMM d, yyyy"))
    }
    val allTags = card.emotionTags + card.topicTags + card.peopleTags + card.goalTags

    Card(
        modifier = Modifier.fillMaxWidth().clickable(onClick = onClick),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = PensieveColors.surfaceSecondary)
    ) {
        Column(Modifier.padding(14.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(card.title, fontSize = 14.sp, fontWeight = FontWeight.Medium,
                    color = PensieveColors.textPrimary, maxLines = 1,
                    overflow = TextOverflow.Ellipsis, modifier = Modifier.weight(1f))
                if (card.isFavorite) {
                    Icon(Icons.Default.Favorite, null, Modifier.size(14.dp),
                        tint = PensieveColors.accentRed)
                }
            }
            Spacer(Modifier.height(6.dp))
            Text(card.summary, fontSize = 12.sp, color = PensieveColors.textSecondary,
                maxLines = 2, overflow = TextOverflow.Ellipsis)
            Spacer(Modifier.height(8.dp))
            Row(verticalAlignment = Alignment.CenterVertically) {
                allTags.take(3).forEach { tag ->
                    Text(tag, fontSize = 10.sp, color = PensieveColors.accentLavender,
                        modifier = Modifier
                            .padding(end = 4.dp)
                            .background(PensieveColors.accentLavender.copy(0.15f), RoundedCornerShape(10.dp))
                            .padding(horizontal = 6.dp, vertical = 2.dp))
                }
                Spacer(Modifier.weight(1f))
                Text(dateStr, fontSize = 10.sp, color = PensieveColors.textMuted)
            }
        }
    }
}

@Composable
private fun MemoryDetailContent(card: MemoryCard, onDelete: () -> Unit) {
    var showConfirm by remember { mutableStateOf(false) }

    Column(Modifier.padding(24.dp)) {
        Text(card.title, fontSize = 20.sp, fontWeight = FontWeight.SemiBold,
            color = PensieveColors.textPrimary)
        Spacer(Modifier.height(16.dp))

        // AI Insight
        Card(shape = RoundedCornerShape(12.dp),
            colors = CardDefaults.cardColors(containerColor = PensieveColors.surfaceElevated)) {
            Column(Modifier.padding(16.dp)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Default.AutoAwesome, null, Modifier.size(14.dp),
                        tint = PensieveColors.accentLavender)
                    Spacer(Modifier.width(6.dp))
                    Text("AI Insight Summary", fontSize = 12.sp, fontWeight = FontWeight.SemiBold,
                        color = PensieveColors.accentLavender)
                }
                Spacer(Modifier.height(8.dp))
                Text(card.summary, fontSize = 14.sp, color = PensieveColors.textPrimary)
            }
        }

        Spacer(Modifier.height(16.dp))

        // Scores
        Row(horizontalArrangement = Arrangement.spacedBy(24.dp)) {
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text("${card.importanceScore}/10", fontSize = 18.sp, fontWeight = FontWeight.SemiBold,
                    color = if (card.importanceScore >= 7) PensieveColors.accentAmber else PensieveColors.textMuted)
                Text("Importance", fontSize = 11.sp, color = PensieveColors.textMuted)
            }
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text("${(card.confidenceScore * 100).toInt()}%", fontSize = 18.sp,
                    fontWeight = FontWeight.SemiBold, color = PensieveColors.accentTeal)
                Text("Confidence", fontSize = 11.sp, color = PensieveColors.textMuted)
            }
        }

        Spacer(Modifier.height(24.dp))

        // Delete
        OutlinedButton(
            onClick = { showConfirm = true },
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(12.dp),
            colors = ButtonDefaults.outlinedButtonColors(contentColor = PensieveColors.accentRed)
        ) {
            Icon(Icons.Default.Delete, null, Modifier.size(16.dp))
            Spacer(Modifier.width(8.dp))
            Text("Delete Memory")
        }

        Spacer(Modifier.height(32.dp))
    }

    if (showConfirm) {
        AlertDialog(
            onDismissRequest = { showConfirm = false },
            title = { Text("Delete Memory?") },
            text = { Text("This memory will be permanently removed from your vault.") },
            confirmButton = {
                TextButton(onClick = { showConfirm = false; onDelete() }) {
                    Text("Delete", color = PensieveColors.accentRed)
                }
            },
            dismissButton = {
                TextButton(onClick = { showConfirm = false }) { Text("Cancel") }
            }
        )
    }
}
