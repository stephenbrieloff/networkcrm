import SwiftUI
import AVFoundation

struct VoiceNotesView: View {
    @ObservedObject var contact: Contact
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var voiceService = VoiceNotesService()
    
    @State private var voiceNotes: [VoiceNotesService.VoiceNote] = []
    @State private var currentRecordingURL: URL?
    @State private var showingPermissionAlert = false
    @State private var isTranscribing = false
    @State private var showingDeleteConfirmation = false
    @State private var noteToDelete: VoiceNotesService.VoiceNote?
    
    var body: some View {
        NavigationView {
            VStack {
                if !voiceService.recordingPermissionGranted {
                    permissionRequiredView
                } else {
                    voiceNotesContent
                }
            }
            .navigationTitle("Voice Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                if voiceService.recordingPermissionGranted {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        recordButton
                    }
                }
            }
            .alert("Permissions Required", isPresented: $showingPermissionAlert) {
                Button("Settings") {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Voice notes require microphone and speech recognition permissions. Please enable them in Settings.")
            }
            .alert("Delete Voice Note", isPresented: $showingDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    if let note = noteToDelete {
                        deleteVoiceNote(note)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This action cannot be undone.")
            }
            .onAppear {
                loadVoiceNotes()
                checkPermissions()
            }
        }
    }
    
    private var permissionRequiredView: some View {
        VStack(spacing: 20) {
            Image(systemName: "mic.slash.circle")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("Microphone Access Required")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Voice notes need microphone access to record audio. Speech recognition permission is also recommended for transcriptions.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button("Grant Permissions") {
                requestPermissions()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private var voiceNotesContent: some View {
        VStack {
            // Current recording indicator
            if voiceService.isRecording {
                currentRecordingIndicator
                    .padding(.bottom)
            }
            
            // Voice notes list
            if voiceNotes.isEmpty {
                emptyStateView
            } else {
                voiceNotesList
            }
        }
    }
    
    private var currentRecordingIndicator: some View {
        VStack(spacing: 16) {
            HStack {
                Circle()
                    .fill(Color.red)
                    .frame(width: 12, height: 12)
                    .scaleEffect(voiceService.isRecording ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 1).repeatForever(), value: voiceService.isRecording)
                
                Text("Recording...")
                    .font(.headline)
                    .foregroundColor(.red)
            }
            
            Text(voiceService.formatDuration(voiceService.currentRecordingTime))
                .font(.system(size: 32, weight: .light, design: .monospaced))
                .foregroundColor(.primary)
            
            Button("Stop Recording") {
                stopRecording()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "mic.badge.plus")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No Voice Notes Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Tap the microphone button to record your first voice note for \(contact.firstName ?? "this contact").")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var voiceNotesList: some View {
        List {
            ForEach(voiceNotes) { note in
                VoiceNoteRow(
                    note: note,
                    isPlaying: voiceService.isPlaying,
                    onPlay: { playVoiceNote(note) },
                    onDelete: { confirmDeleteVoiceNote(note) }
                )
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private var recordButton: some View {
        Button(action: {
            if voiceService.isRecording {
                stopRecording()
            } else {
                startRecording()
            }
        }) {
            Image(systemName: voiceService.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                .font(.title2)
                .foregroundColor(voiceService.isRecording ? .red : .accentColor)
        }
        .disabled(!voiceService.recordingPermissionGranted)
    }
    
    // MARK: - Voice Note Actions
    
    private func startRecording() {
        guard !voiceService.isRecording else { return }
        currentRecordingURL = voiceService.startRecording()
    }
    
    private func stopRecording() {
        guard voiceService.isRecording, let recordingURL = currentRecordingURL else { return }
        
        voiceService.stopRecording()
        
        // Create voice note from recording
        Task {
            await createVoiceNote(from: recordingURL)
        }
    }
    
    private func createVoiceNote(from url: URL) async {
        let duration = await getAudioDuration(url: url)
        var transcription: String? = nil
        
        // Attempt transcription
        if voiceService.speechRecognitionPermissionGranted {
            DispatchQueue.main.async {
                self.isTranscribing = true
            }
            transcription = await voiceService.transcribeAudio(from: url)
            DispatchQueue.main.async {
                self.isTranscribing = false
            }
        }
        
        let voiceNote = VoiceNotesService.VoiceNote(
            fileURL: url,
            duration: duration,
            transcription: transcription,
            dateCreated: Date(),
            title: nil
        )
        
        DispatchQueue.main.async {
            self.voiceNotes.append(voiceNote)
            self.saveVoiceNotes()
            self.currentRecordingURL = nil
        }
    }
    
    private func playVoiceNote(_ note: VoiceNotesService.VoiceNote) {
        if voiceService.isPlaying {
            voiceService.stopPlayback()
        } else {
            voiceService.playAudio(from: note.fileURL)
        }
    }
    
    private func confirmDeleteVoiceNote(_ note: VoiceNotesService.VoiceNote) {
        noteToDelete = note
        showingDeleteConfirmation = true
    }
    
    private func deleteVoiceNote(_ note: VoiceNotesService.VoiceNote) {
        voiceService.deleteAudioFile(at: note.fileURL)
        voiceNotes.removeAll { $0.id == note.id }
        saveVoiceNotes()
    }
    
    // MARK: - Data Management
    
    private func loadVoiceNotes() {
        // For now, we'll store voice notes as a transformable array
        // In a real implementation, you might want to use a separate Core Data entity
        if let data = contact.voiceNotes as? Data,
           let notes = try? JSONDecoder().decode([VoiceNotesService.VoiceNote].self, from: data) {
            voiceNotes = notes
        }
    }
    
    private func saveVoiceNotes() {
        if let data = try? JSONEncoder().encode(voiceNotes) {
            contact.voiceNotes = data as NSObject
            
            do {
                try viewContext.save()
            } catch {
                print("Failed to save voice notes: \(error)")
            }
        }
    }
    
    private func checkPermissions() {
        if !voiceService.recordingPermissionGranted || !voiceService.speechRecognitionPermissionGranted {
            showingPermissionAlert = true
        }
    }
    
    private func requestPermissions() {
        Task {
            _ = await voiceService.requestRecordingPermission()
            _ = await voiceService.requestSpeechRecognitionPermission()
        }
    }
    
    private func getAudioDuration(url: URL) async -> TimeInterval {
        do {
            let audioFile = try AVAudioFile(forReading: url)
            let sampleRate = audioFile.processingFormat.sampleRate
            let frameCount = audioFile.length
            return Double(frameCount) / sampleRate
        } catch {
            return 0
        }
    }
}

struct VoiceNoteRow: View {
    let note: VoiceNotesService.VoiceNote
    let isPlaying: Bool
    let onPlay: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button(action: onPlay) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.title2)
                        .foregroundColor(.accentColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(note.formattedDuration)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(note.formattedDate)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let transcription = note.transcription, !transcription.isEmpty {
                        Text(transcription)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                    } else {
                        Text("No transcription available")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.body)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct VoiceNotesView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let contact = Contact(context: context)
        contact.firstName = "John"
        contact.lastName = "Doe"
        contact.company = "TechCorp"
        
        return VoiceNotesView(contact: contact)
            .environment(\.managedObjectContext, context)
    }
}
