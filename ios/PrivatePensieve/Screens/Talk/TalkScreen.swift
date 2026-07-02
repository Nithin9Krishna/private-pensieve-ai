// TalkScreen.swift
// Private Pensieve AI — iOS
// Main screen: voice-first interaction with animated orb

import SwiftUI

struct TalkScreen: View {
    var body: some View {
        ZStack {
            Color.pensieveBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top status pills
                HStack {
                    PrivacyStatusPill(text: "Local-only", style: .privacy)
                    Spacer()
                    PrivacyStatusPill(text: "Offline ready", style: .offline)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer()

                // Center orb area
                VStack(spacing: 16) {
                    // Placeholder for PensieveOrb
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.pensieveAccentViolet, .pensieveAccentLavender.opacity(0.3), .clear],
                                center: .center,
                                startRadius: 20,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .accessibilityLabel("Pensieve orb — idle")

                    Text("I'm here.")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.pensieveTextPrimary)

                    Text("Talk freely. I'll remember what matters.")
                        .font(.callout)
                        .foregroundColor(.pensieveTextSecondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // Microphone button
                Button(action: {
                    // TODO: Voice recording integration (VOICE-001)
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.pensieveBackground)
                            .frame(width: 72, height: 72)
                            .background(Color.pensieveAccentLavender)
                            .clipShape(Circle())
                            .accessibilityLabel("Hold to speak")

                        Text("Hold to Speak")
                            .font(.footnote)
                            .foregroundColor(.pensieveTextMuted)
                    }
                }
                .padding(.bottom, 24)

                // Privacy footer
                Text("Your memories stay on this device.")
                    .font(.caption)
                    .foregroundColor(.pensieveTextMuted)
                    .padding(.bottom, 8)
            }
        }
    }
}

#Preview {
    TalkScreen()
        .preferredColorScheme(.dark)
}
