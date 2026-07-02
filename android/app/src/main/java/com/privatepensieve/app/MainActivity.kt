package com.privatepensieve.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import com.privatepensieve.app.navigation.PensieveApp
import com.privatepensieve.app.onboarding.OnboardingFlow
import com.privatepensieve.app.onboarding.isOnboardingComplete
import com.privatepensieve.app.ui.theme.PrivatePensieveTheme
import androidx.compose.runtime.*

/**
 * Main entry point — Private Pensieve AI
 * No login. No cloud. No tracking. Memories stay on device.
 */
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            PrivatePensieveTheme {
                var onboardingDone by remember {
                    mutableStateOf(isOnboardingComplete(this@MainActivity))
                }

                if (onboardingDone) {
                    PensieveApp()
                } else {
                    OnboardingFlow(onComplete = { onboardingDone = true })
                }
            }
        }
    }
}
