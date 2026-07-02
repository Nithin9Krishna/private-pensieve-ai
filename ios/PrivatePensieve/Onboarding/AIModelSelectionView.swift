// AIModelSelectionView.swift
// Private Pensieve AI — iOS
// Onboarding Step 4: AI model selection (Stitch screen 11)

import SwiftUI

struct AIModelSelectionView: View {
    let onContinue: () -> Void

    @State private var selectedModel: AIModel = .fakeDefault

    enum AIModel: String, CaseIterable, Identifiable {
        case fakeDefault = "default"
        case appleFoundation = "apple_foundation"

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .fakeDefault: return "Pensieve Default"
            case .appleFoundation: return "Apple Intelligence"
            }
        }

        var description: String {
            switch self {
            case .fakeDefault: return "Works on all devices. Deterministic responses. Great for getting started."
            case .appleFoundation: return "Advanced on-device AI. Requires iOS 26+ and compatible hardware."
            }
        }

        var icon: String {
            switch self {
            case .fakeDefault: return "brain"
            case .appleFoundation: return "apple.logo"
            }
        }

        var isAvailable: Bool {
            switch self {
            case .fakeDefault: return true
            case .appleFoundation:
                if #available(iOS 26, *) { return true }
                return false
            }
        }

        var badge: String? {
            switch self {
            case .fakeDefault: return "ALWAYS AVAILABLE"
            case .appleFoundation:
                return isAvailable ? "ON-DEVICE" : "NOT AVAILABLE"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 60)

            Image(systemName: "cpu")
                .font(.system(size: 48))
                .foregroundColor(.pensieveAccentLavender)

            Spacer().frame(height: 24)

            Text("Choose your\nAI companion.")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.pensieveTextPrimary)
                .multilineTextAlignment(.center)

            Spacer().frame(height: 12)

            Text("All AI runs locally on your device.\nYou can change this later in settings.")
                .font(.callout)
                .foregroundColor(.pensieveTextSecondary)
                .multilineTextAlignment(.center)

            Spacer().frame(height: 32)

            // Model options
            VStack(spacing: 12) {
                ForEach(AIModel.allCases) { model in
                    ModelOptionCard(
                        model: model,
                        isSelected: selectedModel == model,
                        onSelect: { selectedModel = model }
                    )
                }
            }
            .padding(.horizontal, 8)

            Spacer()

            // Begin button
            Button(action: {
                UserDefaults.standard.set(selectedModel.rawValue, forKey: "com.privatepensieve.ai.model")
                onContinue()
            }) {
                Text("Begin →")
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

// MARK: - Model Option Card

struct ModelOptionCard: View {
    let model: AIModelSelectionView.AIModel
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {
                Image(systemName: model.icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .pensieveAccentLavender : .pensieveTextMuted)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(model.displayName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.pensieveTextPrimary)

                        if let badge = model.badge {
                            Text(badge)
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundColor(model.isAvailable ? .pensieveAccentTeal : .pensieveTextMuted)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    (model.isAvailable ? Color.pensieveAccentTeal : Color.pensieveTextMuted)
                                        .opacity(0.15)
                                )
                                .clipShape(Capsule())
                        }
                    }

                    Text(model.description)
                        .font(.caption)
                        .foregroundColor(.pensieveTextSecondary)
                }

                Spacer()

                // Radio button
                Circle()
                    .strokeBorder(isSelected ? Color.pensieveAccentLavender : Color.pensieveBorder, lineWidth: 2)
                    .background(
                        Circle().fill(isSelected ? Color.pensieveAccentLavender : Color.clear)
                            .padding(4)
                    )
                    .frame(width: 22, height: 22)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.pensieveSurfaceSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                isSelected ? Color.pensieveAccentLavender.opacity(0.5) : Color.clear,
                                lineWidth: 1
                            )
                    )
            )
        }
        .disabled(!model.isAvailable)
        .opacity(model.isAvailable ? 1.0 : 0.5)
    }
}

#Preview {
    AIModelSelectionView(onContinue: {})
        .preferredColorScheme(.dark)
        .background(Color.pensieveBackground)
}
