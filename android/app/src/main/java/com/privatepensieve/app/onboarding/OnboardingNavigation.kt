package com.privatepensieve.app.onboarding

import android.content.Context
import androidx.compose.animation.*
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import com.privatepensieve.app.ui.theme.PensieveColors

/**
 * Onboarding flow — 4 steps: Welcome → Privacy → Security → AI Model.
 * Completion state persisted in SharedPreferences.
 */
enum class OnboardingStep { WELCOME, PRIVACY, SECURITY, AI_MODEL }

@Composable
fun OnboardingFlow(onComplete: () -> Unit) {
    var currentStep by remember { mutableStateOf(OnboardingStep.WELCOME) }
    val context = LocalContext.current

    fun advance() {
        currentStep = when (currentStep) {
            OnboardingStep.WELCOME -> OnboardingStep.PRIVACY
            OnboardingStep.PRIVACY -> OnboardingStep.SECURITY
            OnboardingStep.SECURITY -> OnboardingStep.AI_MODEL
            OnboardingStep.AI_MODEL -> {
                markOnboardingComplete(context)
                onComplete()
                return
            }
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(PensieveColors.background)
    ) {
        AnimatedContent(
            targetState = currentStep,
            transitionSpec = {
                slideInHorizontally { it } + fadeIn() togetherWith
                    slideOutHorizontally { -it } + fadeOut()
            },
            label = "onboarding"
        ) { step ->
            when (step) {
                OnboardingStep.WELCOME -> WelcomeScreen(onContinue = { advance() })
                OnboardingStep.PRIVACY -> PrivacyInfoScreen(onContinue = { advance() })
                OnboardingStep.SECURITY -> SecuritySetupScreen(
                    onContinue = { advance() },
                    onSkip = { advance() }
                )
                OnboardingStep.AI_MODEL -> AIModelScreen(onContinue = {
                    markOnboardingComplete(context)
                    onComplete()
                })
            }
        }
    }
}

private const val PREFS_NAME = "pensieve_onboarding"
private const val KEY_COMPLETED = "completed"

fun isOnboardingComplete(context: Context): Boolean {
    return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        .getBoolean(KEY_COMPLETED, false)
}

fun markOnboardingComplete(context: Context) {
    context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        .edit().putBoolean(KEY_COMPLETED, true).apply()
}
