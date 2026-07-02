// TalkViewModel.swift
// Private Pensieve AI — iOS
// State machine for voice flow: idle → recording → transcribing → preview → saved

import SwiftUI
import Combine

/// Talk screen state machine.
/// Controls the full voice flow: idle → listening → transcribing → preview → saved.
@MainActor
final class TalkViewModel: ObservableObject {

    // MARK: - State

    enum TalkState: Equatable {
        case idle
        case recording(duration: TimeInterval)
        case transcribing
        case preview(transcript: String, aiReply: String?)
        case saving
        case saved
        case error(String)
    }

    @Published var state: TalkState = .idle
    @Published var liveTranscript: String = ""
    @Published var recordingDuration: TimeInterval = 0

    // MARK: - Dependencies

    private let aiBrain: AIBrainProvider
    private let stt: SpeechToTextProvider
    private let tts: TTSProvider
    private let memoryCardDAO: MemoryCardDAO
    private let conversationDAO: ConversationDAO

    private var recordingTimer: Timer?

    // MARK: - Init

    init(
        aiBrain: AIBrainProvider = FakeAIBrain(),
        stt: SpeechToTextProvider = FakeSpeechToText(),
        tts: TTSProvider = FakeTTS(),
        memoryCardDAO: MemoryCardDAO = MemoryCardDAO(),
        conversationDAO: ConversationDAO = ConversationDAO()
    ) {
        self.aiBrain = aiBrain
        self.stt = stt
        self.tts = tts
        self.memoryCardDAO = memoryCardDAO
        self.conversationDAO = conversationDAO
    }

    // MARK: - Actions

    /// Start recording voice input.
    func startRecording() {
        guard case .idle = state else { return }
        state = .recording(duration: 0)
        recordingDuration = 0
        liveTranscript = ""

        // Start duration timer
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                self.recordingDuration += 0.1
                self.state = .recording(duration: self.recordingDuration)
            }
        }
    }

    /// Stop recording and begin transcription.
    func stopRecording() {
        recordingTimer?.invalidate()
        recordingTimer = nil

        state = .transcribing

        Task {
            do {
                // Simulate transcription (V1: FakeSpeechToText)
                let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("recording.m4a")
                let result = try await stt.transcribe(audioFileURL: tempURL)
                liveTranscript = result.text

                // Generate AI reply
                let reply = try await aiBrain.generateFriendReply(transcript: result.text, recentMemories: [])
                state = .preview(transcript: result.text, aiReply: reply)
            } catch {
                state = .error("Transcription failed: \(error.localizedDescription)")
            }
        }
    }

    /// Save the transcript as a conversation and extract memory cards.
    func saveTranscript(_ editedTranscript: String) {
        state = .saving

        Task {
            do {
                // 1. Save conversation
                let conversationId = UUID().uuidString
                let conversation = Conversation(
                    id: conversationId,
                    createdAt: Date(),
                    sourceType: .voice,
                    userTranscript: editedTranscript,
                    aiReply: nil,
                    audioRetained: false,
                    audioFilePath: nil,
                    isArchived: false,
                    isDeleted: false
                )
                try conversationDAO.insert(conversation)

                // 2. Extract memory cards
                let cards = try await aiBrain.extractMemory(transcript: editedTranscript)
                for card in cards {
                    try memoryCardDAO.insert(card)
                }

                // 3. Generate friend reply
                let reply = try await aiBrain.generateFriendReply(transcript: editedTranscript, recentMemories: cards)

                // 4. Speak the reply
                try await tts.speak(text: reply)

                state = .saved

                // Return to idle after brief delay
                try await Task.sleep(nanoseconds: 2_000_000_000)
                state = .idle
                liveTranscript = ""
            } catch {
                state = .error("Save failed: \(error.localizedDescription)")
            }
        }
    }

    /// Discard the current transcript and return to idle.
    func discard() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        state = .idle
        liveTranscript = ""
        recordingDuration = 0
    }

    /// Format recording duration as MM:SS.
    var formattedDuration: String {
        let minutes = Int(recordingDuration) / 60
        let seconds = Int(recordingDuration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
