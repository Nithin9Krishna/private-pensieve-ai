// PrivacyScreen.swift
// Private Pensieve AI — iOS
// Privacy dashboard: product differentiator

import SwiftUI

struct PrivacyScreen: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.pensieveBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Privacy, by design")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.pensieveTextPrimary)

                            Text("Your memories do not leave this device.")
                                .font(.body)
                                .foregroundColor(.pensieveTextSecondary)
                        }
                        .padding(.top, 24)

                        // Status list
                        VStack(spacing: 0) {
                            PrivacyStatusRow(label: "Account", value: "Not required", icon: "person.slash")
                            Divider().background(Color.pensieveBorder)
                            PrivacyStatusRow(label: "Server", value: "Not used", icon: "server.rack")
                            Divider().background(Color.pensieveBorder)
                            PrivacyStatusRow(label: "Cloud", value: "Not used", icon: "icloud.slash")
                            Divider().background(Color.pensieveBorder)
                            PrivacyStatusRow(label: "Internet", value: "Not required", icon: "wifi.slash")
                            Divider().background(Color.pensieveBorder)
                            PrivacyStatusRow(label: "AI", value: "On-device", icon: "brain")
                            Divider().background(Color.pensieveBorder)
                            PrivacyStatusRow(label: "Memories", value: "Encrypted locally", icon: "lock.fill")
                            Divider().background(Color.pensieveBorder)
                            PrivacyStatusRow(label: "Backup", value: "Manual encrypted export only", icon: "square.and.arrow.up")
                            Divider().background(Color.pensieveBorder)
                            PrivacyStatusRow(label: "Tracking", value: "None", icon: "hand.raised.slash")
                        }
                        .background(Color.pensieveSurfacePrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal, 16)

                        // Actions
                        VStack(spacing: 12) {
                            PrivacyActionButton(title: "Export encrypted backup", icon: "square.and.arrow.up") {
                                // TODO: BACKUP-001
                            }
                            PrivacyActionButton(title: "Import backup", icon: "square.and.arrow.down") {
                                // TODO: BACKUP-001
                            }
                            PrivacyActionButton(title: "Manage offline brain pack", icon: "brain") {
                                // TODO: Brain pack manager
                            }
                            PrivacyActionButton(title: "Delete audio recordings", icon: "waveform", isDestructive: true) {
                                // TODO: PRIV-001
                            }
                            PrivacyActionButton(title: "Delete all memories", icon: "trash", isDestructive: true) {
                                // TODO: PRIV-001
                            }
                            PrivacyActionButton(title: "View privacy promise", icon: "doc.text") {
                                // TODO: Show privacy promise
                            }
                            PrivacyActionButton(title: "View open-source code", icon: "chevron.left.forwardslash.chevron.right") {
                                // TODO: Open repository URL
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 32)
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct PrivacyStatusRow: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.pensieveAccentTeal)
                .frame(width: 28)

            Text(label)
                .font(.body)
                .foregroundColor(.pensieveTextPrimary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .foregroundColor(.pensieveTextSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

struct PrivacyActionButton: View {
    let title: String
    let icon: String
    var isDestructive: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(isDestructive ? .pensieveAccentRed : .pensieveAccentLavender)
                    .frame(width: 28)

                Text(title)
                    .font(.body)
                    .foregroundColor(isDestructive ? .pensieveAccentRed : .pensieveTextPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.pensieveTextMuted)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.pensieveSurfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .accessibilityLabel(title)
    }
}

#Preview {
    PrivacyScreen()
        .preferredColorScheme(.dark)
}
