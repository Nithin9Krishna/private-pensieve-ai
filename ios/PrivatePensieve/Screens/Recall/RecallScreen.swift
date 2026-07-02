// RecallScreen.swift
// Private Pensieve AI — iOS
// Memory recall: ask your past self

import SwiftUI

struct RecallScreen: View {
    @State private var queryText = ""
    @State private var recallState: RecallState = .idle

    private let suggestedQuestions = [
        "What did I say about my goals?",
        "When was I feeling stressed?",
        "What made me happy recently?",
        "What did I promise myself?",
        "What has been on my mind lately?"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.pensieveBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Ask your past self")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.pensieveTextPrimary)

                            Text("I'll search only what you saved.")
                                .font(.body)
                                .foregroundColor(.pensieveTextSecondary)
                        }
                        .padding(.top, 24)

                        // Input
                        HStack {
                            TextField("What would you like to remember?", text: $queryText)
                                .foregroundColor(.pensieveTextPrimary)
                                .padding(16)

                            Button(action: {
                                // TODO: Voice input for recall (VOICE-001)
                            }) {
                                Image(systemName: "mic.fill")
                                    .foregroundColor(.pensieveAccentLavender)
                                    .frame(width: 44, height: 44)
                                    .accessibilityLabel("Ask with voice")
                            }
                            .padding(.trailing, 8)
                        }
                        .background(Color.pensieveSurfaceElevated)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal, 16)

                        // Content based on state
                        switch recallState {
                        case .idle:
                            suggestedQuestionsView
                        case .searching:
                            searchingView
                        case .results(let results):
                            resultsView(results)
                        case .noResults:
                            noResultsView
                        case .empty:
                            emptyView
                        }
                    }
                }
            }
        }
    }

    private var suggestedQuestionsView: some View {
        VStack(spacing: 12) {
            ForEach(suggestedQuestions, id: \.self) { question in
                RecallQuestionCard(question: question) {
                    queryText = question
                    // TODO: Execute recall query (RECALL-001)
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private var searchingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.pensieveAccentLavender)
            Text("Searching your memories…")
                .font(.body)
                .foregroundColor(.pensieveTextSecondary)
        }
        .padding(.top, 48)
    }

    private func resultsView(_ results: [RecallResult]) -> some View {
        VStack(spacing: 16) {
            Text("I found \(results.count) memories related to this.")
                .font(.body)
                .foregroundColor(.pensieveTextSecondary)
                .padding(.horizontal, 16)

            // Evidence cards would go here
            // TODO: Populate from RecallEngine (RECALL-001)
        }
    }

    private var noResultsView: some View {
        VStack(spacing: 16) {
            Text("I don't remember you telling me that yet.")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.pensieveTextPrimary)
                .multilineTextAlignment(.center)

            Text("Would you like to talk about it now?")
                .font(.body)
                .foregroundColor(.pensieveTextSecondary)

            Button(action: {
                // TODO: Navigate to Talk tab
            }) {
                Text("Talk about it")
                    .font(.headline)
                    .foregroundColor(.pensieveBackground)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(Color.pensieveAccentLavender)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 32)
        .padding(.top, 48)
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Text("No memories yet.")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.pensieveTextPrimary)

            Text("Start a conversation and save some memories first.")
                .font(.body)
                .foregroundColor(.pensieveTextSecondary)
                .multilineTextAlignment(.center)

            Button(action: {
                // TODO: Navigate to Talk tab
            }) {
                Text("Talk to me")
                    .font(.headline)
                    .foregroundColor(.pensieveBackground)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(Color.pensieveAccentLavender)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 32)
        .padding(.top, 48)
    }
}

// MARK: - Recall State

enum RecallState {
    case idle
    case searching
    case results([RecallResult])
    case noResults
    case empty
}

struct RecallResult: Identifiable {
    let id: String
    let date: String
    let summary: String
}

#Preview {
    RecallScreen()
        .preferredColorScheme(.dark)
}
