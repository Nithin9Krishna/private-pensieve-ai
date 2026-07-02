// RecallViewModel.swift
// Private Pensieve AI — iOS
// Manages recall flow: question → engine → answer with evidence.

import SwiftUI

@MainActor
final class RecallViewModel: ObservableObject {

    enum RecallState {
        case idle
        case searching
        case answered(RecallResult)
        case error(String)
    }

    @Published var state: RecallState = .idle
    @Published var questionText: String = ""

    let suggestedQuestions = [
        "What did I say about my goals?",
        "How was I feeling last week?",
        "Did I mention any career plans?",
        "What people did I talk about?",
        "What patterns do I notice?"
    ]

    private let engine: RecallEngine

    init(engine: RecallEngine = RecallEngine()) {
        self.engine = engine
    }

    func askQuestion() {
        guard !questionText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        state = .searching

        Task {
            do {
                let result = try await engine.recall(question: questionText)
                state = .answered(result)
            } catch {
                state = .error("Recall failed: \(error.localizedDescription)")
            }
        }
    }

    func askSuggested(_ question: String) {
        questionText = question
        askQuestion()
    }

    func reset() {
        state = .idle
        questionText = ""
    }
}
