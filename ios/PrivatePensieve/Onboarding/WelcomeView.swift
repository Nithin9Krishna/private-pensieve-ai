// WelcomeView.swift
// Private Pensieve AI — iOS
// Onboarding Step 1: Welcome screen matching Stitch design 05_onboarding_welcome

import SwiftUI

struct WelcomeView: View {
    let onContinue: () -> Void

    @State private var orbScale: CGFloat = 0.8
    @State private var orbOpacity: Double = 0.0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Pensieve orb — animated entrance
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.pensieveAccentViolet, .pensieveAccentLavender.opacity(0.4), .clear],
                        center: .center,
                        startRadius: 10,
                        endRadius: 70
                    )
                )
                .frame(width: 140, height: 140)
                .scaleEffect(orbScale)
                .opacity(orbOpacity)
                .onAppear {
                    withAnimation(.easeOut(duration: 1.0)) {
                        orbScale = 1.0
                        orbOpacity = 1.0
                    }
                }

            Spacer().frame(height: 32)

            // Title
            Text("Your thoughts,\nkept for you.")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.pensieveTextPrimary)
                .multilineTextAlignment(.center)

            Spacer().frame(height: 12)

            // Subtitle
            Text("An offline, private memory companion\nthat stays entirely on your device.")
                .font(.callout)
                .foregroundColor(.pensieveTextSecondary)
                .multilineTextAlignment(.center)

            Spacer().frame(height: 24)

            // Privacy badges
            HStack(spacing: 12) {
                PrivacyBadge(icon: "lock.shield", text: "LOCAL-ONLY")
                PrivacyBadge(icon: "wifi.slash", text: "OFFLINE")
            }

            Spacer()

            // Continue button
            Button(action: onContinue) {
                Text("Continue →")
                    .font(.headline)
                    .foregroundColor(.pensieveBackground)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.pensieveAccentLavender)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 24)

            Spacer().frame(height: 16)

            // Privacy note
            Text("By continuing, you acknowledge that your data never\nleaves this device.")
                .font(.caption2)
                .foregroundColor(.pensieveTextMuted)
                .multilineTextAlignment(.center)

            Spacer().frame(height: 32)
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Privacy Badge

struct PrivacyBadge: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(.pensieveAccentTeal)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.pensieveSurfaceSecondary)
        .clipShape(Capsule())
    }
}

#Preview {
    WelcomeView(onContinue: {})
        .preferredColorScheme(.dark)
        .background(Color.pensieveBackground)
}
