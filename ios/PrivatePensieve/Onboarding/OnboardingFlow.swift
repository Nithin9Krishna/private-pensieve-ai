// OnboardingFlow.swift
// Private Pensieve AI — iOS
// Manages the 4-step onboarding flow: Welcome → Privacy → Security → AI Model

import SwiftUI

/// Controls the onboarding state and persists completion.
final class OnboardingState: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var isComplete: Bool

    enum OnboardingStep: Int, CaseIterable {
        case welcome = 0
        case privacy = 1
        case security = 2
        case aiModel = 3
    }

    private let completedKey = "com.privatepensieve.onboarding.completed"

    init() {
        self.isComplete = UserDefaults.standard.bool(forKey: completedKey)
    }

    func advance() {
        let allSteps = OnboardingStep.allCases
        if let currentIndex = allSteps.firstIndex(of: currentStep),
           currentIndex + 1 < allSteps.count {
            currentStep = allSteps[currentIndex + 1]
        } else {
            complete()
        }
    }

    func complete() {
        isComplete = true
        UserDefaults.standard.set(true, forKey: completedKey)
    }

    /// For testing / reset
    func reset() {
        isComplete = false
        currentStep = .welcome
        UserDefaults.standard.set(false, forKey: completedKey)
    }
}

/// The onboarding container view that switches between steps.
struct OnboardingFlow: View {
    @StateObject private var state = OnboardingState()

    var body: some View {
        ZStack {
            Color.pensieveBackground.ignoresSafeArea()

            Group {
                switch state.currentStep {
                case .welcome:
                    WelcomeView(onContinue: state.advance)
                case .privacy:
                    PrivacyInfoView(onContinue: state.advance)
                case .security:
                    SecuritySetupView(onContinue: state.advance, onSkip: state.advance)
                case .aiModel:
                    AIModelSelectionView(onContinue: state.complete)
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            .animation(.easeInOut(duration: 0.3), value: state.currentStep)
        }
    }
}

#Preview {
    OnboardingFlow()
        .preferredColorScheme(.dark)
}
