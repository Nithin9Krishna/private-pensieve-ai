package com.privatepensieve.app.navigation

import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Mic
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Shield
import androidx.compose.material.icons.filled.VisibilityOff
import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import com.privatepensieve.app.screens.PrivacyScreen
import com.privatepensieve.app.screens.RecallScreen
import com.privatepensieve.app.screens.TalkScreen
import com.privatepensieve.app.screens.VaultScreen
import com.privatepensieve.app.ui.theme.PensieveColors

/**
 * Four tabs only: Talk, Vault, Recall, Privacy.
 * Do not add more bottom tabs.
 */
enum class PensieveTab(
    val title: String,
    val icon: ImageVector
) {
    Talk("Talk", Icons.Filled.Mic),
    Vault("Vault", Icons.Filled.Shield),
    Recall("Recall", Icons.Filled.Search),
    Privacy("Privacy", Icons.Filled.VisibilityOff)
}

@Composable
fun PensieveApp() {
    var selectedTab by remember { mutableStateOf(PensieveTab.Talk) }

    Scaffold(
        containerColor = PensieveColors.background,
        bottomBar = {
            NavigationBar(
                containerColor = PensieveColors.surfacePrimary,
                contentColor = PensieveColors.textPrimary
            ) {
                PensieveTab.entries.forEach { tab ->
                    NavigationBarItem(
                        selected = selectedTab == tab,
                        onClick = { selectedTab = tab },
                        icon = { Icon(tab.icon, contentDescription = tab.title) },
                        label = { Text(tab.title) }
                    )
                }
            }
        }
    ) { innerPadding ->
        when (selectedTab) {
            PensieveTab.Talk -> TalkScreen(modifier = Modifier.padding(innerPadding))
            PensieveTab.Vault -> VaultScreen(modifier = Modifier.padding(innerPadding))
            PensieveTab.Recall -> RecallScreen(modifier = Modifier.padding(innerPadding))
            PensieveTab.Privacy -> PrivacyScreen(modifier = Modifier.padding(innerPadding))
        }
    }
}
