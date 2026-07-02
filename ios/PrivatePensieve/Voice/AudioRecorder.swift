// AudioRecorder.swift
// Private Pensieve AI — iOS
// Real on-device audio recording using AVAudioEngine.
// Records to M4A (AAC) format. No network. No cloud upload.

import AVFoundation
import Foundation

/// On-device audio recorder using AVAudioEngine.
/// Records voice input and saves to a local M4A file.
final class AudioRecorder: ObservableObject {

    @Published var isRecording = false
    @Published var recordingURL: URL?

    private var audioEngine: AVAudioEngine?
    private var audioFile: AVAudioFile?

    /// Start recording voice input to a local file.
    func startRecording() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .spokenAudio, options: [.duckOthers])
        try session.setActive(true, options: .notifyOthersOnDeactivation)

        let engine = AVAudioEngine()
        let inputNode = engine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        // Create temp file
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("pensieve_recording_\(UUID().uuidString).m4a")

        // AAC settings for compact on-device storage
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: recordingFormat.sampleRate,
            AVNumberOfChannelsKey: recordingFormat.channelCount,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            AVEncoderBitRateKey: 128000
        ]

        let file = try AVAudioFile(forWriting: fileURL, settings: settings)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            do {
                try file.write(from: buffer)
            } catch {
                // Silently handle write errors during recording
            }
        }

        try engine.start()

        self.audioEngine = engine
        self.audioFile = file
        self.recordingURL = fileURL
        self.isRecording = true
    }

    /// Stop recording and return the file URL.
    func stopRecording() -> URL? {
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil
        audioFile = nil
        isRecording = false

        try? AVAudioSession.sharedInstance().setActive(false)
        return recordingURL
    }

    /// Delete the recording file from disk.
    func deleteRecording() {
        guard let url = recordingURL else { return }
        try? FileManager.default.removeItem(at: url)
        recordingURL = nil
    }

    /// Request microphone permission.
    static func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
}
