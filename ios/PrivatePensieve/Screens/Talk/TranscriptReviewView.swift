// TranscriptReviewView.swift
// Private Pensieve AI — iOS
// Post-recording transcript editor with AI insight and Save/Discard (Stitch screen 12)

import SwiftUI

struct TranscriptReviewView: View {
    let transcript: String
    let aiReply: String?
    let onSave: (String) -> Void
    let onDiscard: () -> Void

    @State private var editedTranscript: String = ""
    @State private var isEditing = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("Review Transcript")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.pensieveTextPrimary)
                    Spacer()
                    Button(action: { isEditing.toggle() }) {
                        Image(systemName: isEditing ? "checkmark" : "pencil")
                            .foregroundColor(.pensieveAccentLavender)
                    }
                }

                // AI Insight card
                if let reply = aiReply {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.caption)
                                .foregroundColor(.pensieveAccentLavender)
                            Text("AI Insight")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.pensieveAccentLavender)
                        }
                        Text(reply)
                            .font(.subheadline)
                            .foregroundColor(.pensieveTextPrimary)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.pensieveSurfaceElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Transcript content
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your words")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.pensieveTextMuted)

                    if isEditing {
                        TextEditor(text: $editedTranscript)
                            .font(.body)
                            .foregroundColor(.pensieveTextPrimary)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 120)
                            .padding(12)
                            .background(Color.pensieveSurfaceSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        Text(editedTranscript)
                            .font(.body)
                            .foregroundColor(.pensieveTextPrimary)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.pensieveSurfaceSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }

                // Action buttons
                VStack(spacing: 12) {
                    Button(action: { onSave(editedTranscript) }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("Save to Vault")
                        }
                        .font(.headline)
                        .foregroundColor(.pensieveBackground)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.pensieveAccentLavender)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    Button(action: onDiscard) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Discard")
                        }
                        .font(.subheadline)
                        .foregroundColor(.pensieveAccentRed)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.pensieveAccentRed.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
        }
        .onAppear { editedTranscript = transcript }
    }
}

#Preview {
    ZStack {
        Color.pensieveBackground.ignoresSafeArea()
        TranscriptReviewView(
            transcript: "I had coffee with Maya today. We talked about whether I should take that new job. I'm feeling more confident after our conversation.",
            aiReply: "That sounds important. What part of it stayed with you most?",
            onSave: { _ in },
            onDiscard: {}
        )
    }
    .preferredColorScheme(.dark)
}
