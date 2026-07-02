// PrivatePensieveApp.swift
// Private Pensieve AI — iOS
// No login. No cloud. No tracking. Memories stay on device.

import SwiftUI

@main
struct PrivatePensieveApp: App {
    @StateObject private var onboardingState = OnboardingState()

    var body: some Scene {
        WindowGroup {
            Group {
                if onboardingState.isComplete {
                    MainTabView()
                } else {
                    OnboardingFlow()
                        .environmentObject(onboardingState)
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}
