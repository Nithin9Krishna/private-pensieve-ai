// RecallScreen.swift
// Private Pensieve AI — iOS
// Memory recall: ask anything + evidence-bound answers (Stitch screens 06, 14)

import SwiftUI

struct RecallScreen: View {
    @StateObject private var viewModel = RecallViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.pensieveBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Ask Anything")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.pensieveTextPrimary)

                            Text("I'll search only what you saved.")
                                .font(.body)
                                .foregroundColor(.pensieveTextSecondary)
                        }
                        .padding(.top, 24)

                        // Search input
                        HStack {
                            TextField("What would you like to remember?", text: $viewModel.questionText)
                                .foregroundColor(.pensieveTextPrimary)
                                .padding(16)
                                .onSubmit { viewModel.askQuestion() }

                            Button(action: { viewModel.askQuestion() }) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.pensieveAccentLavender)
                                    .frame(width: 44, height: 44)
                            }
                            .padding(.trailing, 8)
                        }
                        .background(Color.pensieveSurfaceElevated)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal, 16)

                        // Content
                        switch viewModel.state {
                        case .idle:
                            suggestedQuestionsView
                        case .searching:
                            searchingView
                        case .answered(let result):
                            RecallAnswerView(result: result, onNewQuestion: { viewModel.reset() })
                        case .error(let message):
                            errorView(message)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Suggested Questions

    private var suggestedQuestionsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Suggested")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.pensieveTextMuted)
                .padding(.horizontal, 16)

            ForEach(viewModel.suggestedQuestions, id: \.self) { question in
                Button(action: { viewModel.askSuggested(question) }) {
                    HStack {
                        Image(systemName: "sparkle")
                            .font(.caption)
                            .foregroundColor(.pensieveAccentLavender)
                        Text(question)
                            .font(.subheadline)
                            .foregroundColor(.pensieveTextPrimary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundColor(.pensieveTextMuted)
                    }
                    .padding(14)
                    .background(Color.pensieveSurfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private var searchingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.pensieveAccentLavender)
                .scaleEffect(1.2)
            Text("Searching your memories…")
                .font(.body)
                .foregroundColor(.pensieveTextSecondary)
        }
        .padding(.top, 48)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title)
                .foregroundColor(.pensieveAccentAmber)
            Text(message)
                .font(.callout)
                .foregroundColor(.pensieveTextSecondary)
                .multilineTextAlignment(.center)
            Button("Try Again") { viewModel.reset() }
                .foregroundColor(.pensieveAccentLavender)
        }
        .padding(.top, 48)
    }
}

// MARK: - Recall Answer View

struct RecallAnswerView: View {
    let result: RecallResult
    let onNewQuestion: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // AI Answer card
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundColor(.pensieveAccentLavender)
                    Text("Pensieve's Answer")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.pensieveAccentLavender)
                }

                Text(result.answer)
                    .font(.body)
                    .foregroundColor(.pensieveTextPrimary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.pensieveSurfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: 14))

            // Source evidence
            if !result.evidence.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Source Evidence")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.pensieveTextMuted)

                    ForEach(result.evidence) { card in
                        HStack(alignment: .top, spacing: 10) {
                            Circle()
                                .fill(Color.pensieveAccentTeal)
                                .frame(width: 6, height: 6)
                                .padding(.top, 6)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(card.title)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.pensieveTextPrimary)
                                Text(card.createdAt, style: .date)
                                    .font(.system(size: 10))
                                    .foregroundColor(.pensieveTextMuted)
                            }
                        }
                        .padding(10)
                        .background(Color.pensieveSurfaceSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }

            // Ask another question
            Button(action: onNewQuestion) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Ask another question")
                }
                .font(.subheadline)
                .foregroundColor(.pensieveAccentLavender)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.pensieveAccentLavender.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    RecallScreen()
        .preferredColorScheme(.dark)
}
