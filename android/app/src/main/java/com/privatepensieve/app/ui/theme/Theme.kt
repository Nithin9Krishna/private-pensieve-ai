package com.privatepensieve.app.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

/**
 * Pensieve color tokens — source of truth: docs/DESIGN_SYSTEM.md
 */
object PensieveColors {
    // Base dark surfaces
    val background = Color(0xFF0B0F14)
    val surfacePrimary = Color(0xFF121923)
    val surfaceSecondary = Color(0xFF182230)
    val surfaceElevated = Color(0xFF1E2A38)
    val textPrimary = Color(0xFFF6F7FB)
    val textSecondary = Color(0xFFAAB5C4)
    val textMuted = Color(0xFF7B8797)
    val border = Color(0xFF2B3A4A)

    // Accents
    val accentLavender = Color(0xFFA78BFA)
    val accentViolet = Color(0xFF7C5CFC)
    val accentBlue = Color(0xFF63B3ED)
    val accentTeal = Color(0xFF5ED6C9)
    val accentAmber = Color(0xFFF6C667)
    val accentRed = Color(0xFFF87171)
}

private val PensieveDarkColorScheme = darkColorScheme(
    primary = PensieveColors.accentLavender,
    onPrimary = PensieveColors.background,
    secondary = PensieveColors.accentViolet,
    background = PensieveColors.background,
    surface = PensieveColors.surfacePrimary,
    surfaceVariant = PensieveColors.surfaceSecondary,
    onBackground = PensieveColors.textPrimary,
    onSurface = PensieveColors.textPrimary,
    onSurfaceVariant = PensieveColors.textSecondary,
    outline = PensieveColors.border,
    error = PensieveColors.accentRed,
)

@Composable
fun PrivatePensieveTheme(
    content: @Composable () -> Unit
) {
    MaterialTheme(
        colorScheme = PensieveDarkColorScheme,
        content = content
    )
}
