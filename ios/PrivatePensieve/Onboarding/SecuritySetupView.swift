// SecuritySetupView.swift
// Private Pensieve AI — iOS
// Onboarding Step 3: Biometric/passcode setup (Stitch screen 09)

import SwiftUI
import LocalAuthentication

struct SecuritySetupView: View {
    let onContinue: () -> Void
    let onSkip: () -> Void

    @State private var biometricEnabled = false
    @State private var biometricType: LABiometryType = .none

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 60)

            Image(systemName: biometricIcon)
                .font(.system(size: 48))
                .foregroundColor(.pensieveAccentLavender)

            Spacer().frame(height: 24)

            Text("Protect your\nmemories.")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.pensieveTextPrimary)
                .multilineTextAlignment(.center)

            Spacer().frame(height: 12)

            Text("Add biometric lock so only you can access your vault.")
                .font(.callout)
                .foregroundColor(.pensieveTextSecondary)
                .multilineTextAlignment(.center)

            Spacer().frame(height: 40)

            // Biometric toggle card
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: biometricIcon)
                        .font(.title3)
                        .foregroundColor(.pensieveAccentLavender)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(biometricName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.pensieveTextPrimary)
                        Text("Require \(biometricName.lowercased()) to open Pensieve")
                            .font(.caption)
                            .foregroundColor(.pensieveTextSecondary)
                    }

                    Spacer()

                    Toggle("", isOn: $biometricEnabled)
                        .labelsHidden()
                        .tint(.pensieveAccentLavender)
                }
                .padding(16)
                .background(Color.pensieveSurfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Passcode fallback note
                HStack(spacing: 8) {
                    Image(systemName: "key.fill")
                        .font(.caption)
                        .foregroundColor(.pensieveTextMuted)
                    Text("Device passcode is used as fallback.")
                        .font(.caption)
                        .foregroundColor(.pensieveTextMuted)
                }
            }
            .padding(.horizontal, 8)

            Spacer()

            // Enable button
            Button(action: {
                if biometricEnabled {
                    // Save preference
                    UserDefaults.standard.set(true, forKey: "com.privatepensieve.biometric.enabled")
                }
                onContinue()
            }) {
                Text(biometricEnabled ? "Enable \(biometricName) →" : "Continue without lock →")
                    .font(.headline)
                    .foregroundColor(.pensieveBackground)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.pensieveAccentLavender)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            Spacer().frame(height: 12)

            // Skip
            Button("Skip for now", action: onSkip)
                .font(.subheadline)
                .foregroundColor(.pensieveTextMuted)

            Spacer().frame(height: 32)
        }
        .padding(.horizontal, 24)
        .onAppear { checkBiometricType() }
    }

    // MARK: - Biometric Helpers

    private var biometricIcon: String {
        switch biometricType {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        default: return "lock.fill"
        }
    }

    private var biometricName: String {
        switch biometricType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        default: return "Passcode"
        }
    }

    private func checkBiometricType() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            biometricType = context.biometryType
        }
    }
}

#Preview {
    SecuritySetupView(onContinue: {}, onSkip: {})
        .preferredColorScheme(.dark)
        .background(Color.pensieveBackground)
}
