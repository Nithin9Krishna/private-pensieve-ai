// TalkScreen.swift
// Private Pensieve AI — iOS
// Main screen: voice-first interaction with animated orb
// States: Idle → Recording/Listening → Transcribing → Preview → Saved

import SwiftUI

struct TalkScreen: View {
    @StateObject private var viewModel = TalkViewModel()
    @State private var orbPulse = false

    var body: some View {
        ZStack {
            Color.pensieveBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top status pills
                HStack {
                    PrivacyStatusPill(text: "Local-only", style: .privacy)
                    Spacer()
                    if case .recording = viewModel.state {
                        PrivacyStatusPill(text: "RECORDING", style: .recording)
                    } else {
                        PrivacyStatusPill(text: "Offline ready", style: .offline)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer()

                // Center content — changes based on state
                centerContent

                Spacer()

                // Bottom action area
                bottomAction

                // Privacy footer
                Text("Your memories stay on this device.")
                    .font(.caption)
                    .foregroundColor(.pensieveTextMuted)
                    .padding(.bottom, 8)
            }
        }
    }

    // MARK: - Center Content (State-dependent)

    @ViewBuilder
    private var centerContent: some View {
        switch viewModel.state {
        case .idle:
            idleView
        case .recording:
            recordingView
        case .transcribing:
            transcribingView
        case .preview(let transcript, let aiReply):
            TranscriptReviewView(
                transcript: transcript,
                aiReply: aiReply,
                onSave: { viewModel.saveTranscript($0) },
                onDiscard: { viewModel.discard() }
            )
        case .saving:
            savingView
        case .saved:
            savedView
        case .error(let message):
            errorView(message)
        }
    }

    // MARK: - Idle State

    private var idleView: some View {
        VStack(spacing: 16) {
            // Breathing orb
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
                .scaleEffect(orbPulse ? 1.05 : 0.95)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: orbPulse)
                .onAppear { orbPulse = true }
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
    }

    // MARK: - Recording State

    private var recordingView: some View {
        VStack(spacing: 16) {
            // Pulsing orb — larger and more vibrant during recording
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.pensieveAccentViolet, .pensieveAccentLavender.opacity(0.5), .clear],
                        center: .center,
                        startRadius: 30,
                        endRadius: 100
                    )
                )
                .frame(width: 180, height: 180)
                .scaleEffect(orbPulse ? 1.15 : 0.90)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: orbPulse)
                .accessibilityLabel("Pensieve orb — listening")

            // Timer
            Text(viewModel.formattedDuration)
                .font(.system(size: 24, weight: .medium, design: .monospaced))
                .foregroundColor(.pensieveAccentLavender)

            Text("Listening...")
                .font(.callout)
                .foregroundColor(.pensieveTextSecondary)

            // Live transcript preview
            if !viewModel.liveTranscript.isEmpty {
                Text(viewModel.liveTranscript)
                    .font(.body)
                    .foregroundColor(.pensieveTextPrimary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.pensieveSurfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 24)
            }

            // LOCAL-ONLY ENCRYPTION badge
            HStack(spacing: 4) {
                Image(systemName: "lock.fill")
                    .font(.caption2)
                Text("LOCAL-ONLY ENCRYPTION")
                    .font(.caption2)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.pensieveAccentTeal)
        }
    }

    // MARK: - Transcribing State

    private var transcribingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.pensieveAccentLavender)
                .scaleEffect(1.5)

            Text("Transcribing...")
                .font(.callout)
                .foregroundColor(.pensieveTextSecondary)
        }
    }

    // MARK: - Saving State

    private var savingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.pensieveAccentLavender)

            Text("Saving to your vault...")
                .font(.callout)
                .foregroundColor(.pensieveTextSecondary)
        }
    }

    // MARK: - Saved State

    private var savedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.pensieveAccentTeal)

            Text("Memory saved")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.pensieveTextPrimary)

            Text("Stored safely in your vault.")
                .font(.callout)
                .foregroundColor(.pensieveTextSecondary)
        }
    }

    // MARK: - Error State

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 36))
                .foregroundColor(.pensieveAccentAmber)

            Text(message)
                .font(.callout)
                .foregroundColor(.pensieveTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Button("Try Again") { viewModel.discard() }
                .font(.subheadline)
                .foregroundColor(.pensieveAccentLavender)
        }
    }

    // MARK: - Bottom Action Button

    @ViewBuilder
    private var bottomAction: some View {
        switch viewModel.state {
        case .idle:
            // Hold to speak button
            VStack(spacing: 8) {
                Button(action: {}) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.pensieveBackground)
                        .frame(width: 72, height: 72)
                        .background(Color.pensieveAccentLavender)
                        .clipShape(Circle())
                }
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.1)
                        .onEnded { _ in viewModel.startRecording() }
                )
                .accessibilityLabel("Hold to speak")

                Text("Hold to Speak")
                    .font(.footnote)
                    .foregroundColor(.pensieveTextMuted)
            }
            .padding(.bottom, 24)

        case .recording:
            // Stop button
            VStack(spacing: 8) {
                Button(action: { viewModel.stopRecording() }) {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.pensieveBackground)
                        .frame(width: 72, height: 72)
                        .background(Color.pensieveAccentRed)
                        .clipShape(Circle())
                }
                .accessibilityLabel("Stop recording")

                Text("Tap to Stop")
                    .font(.footnote)
                    .foregroundColor(.pensieveTextMuted)
            }
            .padding(.bottom, 24)

        case .preview, .transcribing, .saving, .saved, .error:
            EmptyView()
                .padding(.bottom, 24)
        }
    }
}

#Preview {
    TalkScreen()
        .preferredColorScheme(.dark)
}
