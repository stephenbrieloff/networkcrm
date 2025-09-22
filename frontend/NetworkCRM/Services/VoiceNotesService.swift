import Foundation
import AVFoundation
import Speech
import SwiftUI

class VoiceNotesService: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var currentRecordingTime: TimeInterval = 0
    @Published var recordingPermissionGranted = false
    @Published var speechRecognitionPermissionGranted = false
    @Published var errorMessage: String?
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingTimer: Timer?
    private var speechRecognizer = SFSpeechRecognizer()
    private var audioEngine = AVAudioEngine()
    
    override init() {
        super.init()
        setupAudioSession()
        checkPermissions()
    }
    
    // MARK: - Permissions
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
            errorMessage = "Failed to set up audio session"
        }
    }
    
    func requestRecordingPermission() async -> Bool {
        await AVAudioSession.sharedInstance().requestRecordPermission()
    }
    
    func requestSpeechRecognitionPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
    
    private func checkPermissions() {
        Task {
            let recordingGranted = await requestRecordingPermission()
            let speechGranted = await requestSpeechRecognitionPermission()
            
            DispatchQueue.main.async {
                self.recordingPermissionGranted = recordingGranted
                self.speechRecognitionPermissionGranted = speechGranted
            }
        }
    }
    
    // MARK: - Recording
    
    func startRecording() -> URL? {
        guard recordingPermissionGranted else {
            errorMessage = "Recording permission not granted"
            return nil
        }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("voice_note_\(UUID().uuidString).m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            isRecording = true
            currentRecordingTime = 0
            
            // Start timer to update recording time
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                DispatchQueue.main.async {
                    self.currentRecordingTime = self.audioRecorder?.currentTime ?? 0
                }
            }
            
            return audioFilename
        } catch {
            print("Failed to start recording: \(error)")
            errorMessage = "Failed to start recording: \(error.localizedDescription)"
            return nil
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        recordingTimer?.invalidate()
        recordingTimer = nil
        isRecording = false
    }
    
    // MARK: - Playback
    
    func playAudio(from url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Failed to play audio: \(error)")
            errorMessage = "Failed to play audio: \(error.localizedDescription)"
        }
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        isPlaying = false
    }
    
    func pausePlayback() {
        audioPlayer?.pause()
        isPlaying = false
    }
    
    // MARK: - Speech-to-Text
    
    func transcribeAudio(from url: URL) async -> String? {
        guard speechRecognitionPermissionGranted else {
            DispatchQueue.main.async {
                self.errorMessage = "Speech recognition permission not granted"
            }
            return nil
        }
        
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            DispatchQueue.main.async {
                self.errorMessage = "Speech recognition not available"
            }
            return nil
        }
        
        let request = SFSpeechURLRecognitionRequest(url: url)
        request.shouldReportPartialResults = false
        
        return await withCheckedContinuation { continuation in
            recognizer.recognitionTask(with: request) { result, error in
                if let error = error {
                    print("Speech recognition error: \(error)")
                    continuation.resume(returning: nil)
                    return
                }
                
                if let result = result, result.isFinal {
                    continuation.resume(returning: result.bestTranscription.formattedString)
                } else if result == nil {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    // MARK: - File Management
    
    func deleteAudioFile(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Failed to delete audio file: \(error)")
            errorMessage = "Failed to delete audio file"
        }
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - AVAudioRecorderDelegate
extension VoiceNotesService: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        if !flag {
            errorMessage = "Recording failed"
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("Audio recorder encode error: \(error)")
            errorMessage = "Recording error: \(error.localizedDescription)"
        }
        isRecording = false
    }
}

// MARK: - AVAudioPlayerDelegate
extension VoiceNotesService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Audio player decode error: \(error)")
            errorMessage = "Playback error: \(error.localizedDescription)"
        }
        isPlaying = false
    }
}

// MARK: - Core Data Integration
extension VoiceNotesService {
    struct VoiceNote: Codable, Identifiable {
        let id = UUID()
        let fileURL: URL
        let duration: TimeInterval
        let transcription: String?
        let dateCreated: Date
        let title: String?
        
        var formattedDuration: String {
            let minutes = Int(duration) / 60
            let seconds = Int(duration) % 60
            return String(format: "%d:%02d", minutes, seconds)
        }
        
        var formattedDate: String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: dateCreated)
        }
    }
}