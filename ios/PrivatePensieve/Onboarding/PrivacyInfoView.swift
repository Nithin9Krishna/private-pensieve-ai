// PrivacyInfoView.swift
// Private Pensieve AI — iOS
// Onboarding Step 2: Privacy mechanics explanation (Stitch screen 08)

import SwiftUI

struct PrivacyInfoView: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 60)

            // Shield icon
            Image(systemName: "shield.checkered")
                .font(.system(size: 48))
                .foregroundColor(.pensieveAccentTeal)

            Spacer().frame(height: 24)

            Text("Your privacy,\nby design.")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.pensieveTextPrimary)
                .multilineTextAlignment(.center)

            Spacer().frame(height: 32)

            // Privacy feature list
            VStack(spacing: 20) {
                PrivacyFeatureRow(
                    icon: "iphone",
                    title: "On-device only",
                    description: "Your memories never leave this phone. No servers. No cloud sync."
                )
                PrivacyFeatureRow(
                    icon: "lock.fill",
                    title: "Encrypted vault",
                    description: "All data is encrypted with a key only your device holds."
                )
                PrivacyFeatureRow(
                    icon: "brain.head.profile",
                    title: "Local AI",
                    description: "Speech recognition and AI run entirely on your device."
                )
                PrivacyFeatureRow(
                    icon: "trash.fill",
                    title: "You own deletion",
                    description: "Delete any memory instantly. No backups retained without your consent."
                )
            }
            .padding(.horizontal, 8)

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

            Spacer().frame(height: 32)
        }
        .padding(.horizontal, 24)
    }
}

struct PrivacyFeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.pensieveAccentLavender)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.pensieveTextPrimary)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.pensieveTextSecondary)
            }
        }
    }
}

#Preview {
    PrivacyInfoView(onContinue: {})
        .preferredColorScheme(.dark)
        .background(Color.pensieveBackground)
}
