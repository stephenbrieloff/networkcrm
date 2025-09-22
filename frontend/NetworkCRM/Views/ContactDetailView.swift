import SwiftUI
import CoreData

struct ContactDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var contact: Contact
    
    @State private var isEditing = false
    @State private var editedFirstName = ""
    @State private var editedLastName = ""
    @State private var editedCompany = ""
    @State private var editedEmail = ""
    @State private var editedPhone = ""
    @State private var editedJobTitle = ""
    @State private var editedMetAt = ""
    @State private var editedNotes = ""
    
    @State private var showingFollowUpSheet = false
    @State private var showingCallAlert = false
    @State private var showingMessageAlert = false
    @State private var showingVoiceNotes = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Section
                headerSection
                
                // Quick Actions
                quickActionButtons
                
                // Contact Information
                contactInformationSection
                
                // Follow-up Section
                followUpSection
                
                // Notes Section
                notesSection
                
                // Meeting Context
                if let metAt = contact.metAt, !metAt.isEmpty {
                    meetingContextSection
                }
                
                Spacer(minLength: 20)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Done" : "Edit") {
                    if isEditing {
                        saveChanges()
                    } else {
                        startEditing()
                    }
                    isEditing.toggle()
                }
            }
        }
        .sheet(isPresented: $showingFollowUpSheet) {
            FollowUpReminderView(contact: contact)
        }
        .sheet(isPresented: $showingVoiceNotes) {
            VoiceNotesView(contact: contact)
        }
        .alert("Call \(contact.firstName ?? "")?", isPresented: $showingCallAlert) {
            Button("Cancel", role: .cancel) { }
            if let phone = contact.phone {
                Button("Call") {
                    if let url = URL(string: "tel:\(phone)") {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
        .alert("Message \(contact.firstName ?? "")?", isPresented: $showingMessageAlert) {
            Button("Cancel", role: .cancel) { }
            if let phone = contact.phone {
                Button("Message") {
                    if let url = URL(string: "sms:\(phone)") {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Profile Circle
                Circle()
                    .fill(Color.accentColor.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text(initials)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.accentColor)
                    )
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Added \(formatDate(contact.dateAdded))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let lastContact = contact.lastContact {
                        Text("Last contact: \(formatDate(lastContact))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let nextFollowUp = contact.nextFollowUp {
                        HStack {
                            Image(systemName: "bell.fill")
                            Text("Reminder: \(formatDate(nextFollowUp))")
                        }
                        .font(.caption)
                        .foregroundColor(.orange)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if isEditing {
                    HStack {
                        TextField("First Name", text: $editedFirstName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Last Name", text: $editedLastName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                } else {
                    Text("\(contact.firstName ?? "") \(contact.lastName ?? "")")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                if isEditing {
                    HStack {
                        TextField("Company", text: $editedCompany)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Job Title", text: $editedJobTitle)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                } else {
                    if let company = contact.company, !company.isEmpty {
                        Text(company)
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    
                    if let jobTitle = contact.jobTitle, !jobTitle.isEmpty {
                        Text(jobTitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var quickActionButtons: some View {
        HStack(spacing: 16) {
            if let phone = contact.phone, !phone.isEmpty {
                QuickActionButton(
                    icon: "phone.fill",
                    title: "Call",
                    color: .green
                ) {
                    showingCallAlert = true
                }
                
                QuickActionButton(
                    icon: "message.fill",
                    title: "Message",
                    color: .blue
                ) {
                    showingMessageAlert = true
                }
            }
            
            if let email = contact.email, !email.isEmpty {
                QuickActionButton(
                    icon: "envelope.fill",
                    title: "Email",
                    color: .orange
                ) {
                    if let url = URL(string: "mailto:\(email)") {
                        UIApplication.shared.open(url)
                    }
                }
            }
            
            QuickActionButton(
                icon: "bell.fill",
                title: "Remind",
                color: .purple
            ) {
                showingFollowUpSheet = true
            }
            
            QuickActionButton(
                icon: "mic.fill",
                title: "Voice Note",
                color: .indigo
            ) {
                showingVoiceNotes = true
            }
        }
    }
    
    private var contactInformationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Contact Information")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                if isEditing {
                    ContactEditRow(label: "Email", text: $editedEmail, keyboardType: .emailAddress)
                    ContactEditRow(label: "Phone", text: $editedPhone, keyboardType: .phonePad)
                } else {
                    if let email = contact.email, !email.isEmpty {
                        ContactInfoRow(icon: "envelope", label: "Email", value: email)
                    }
                    
                    if let phone = contact.phone, !phone.isEmpty {
                        ContactInfoRow(icon: "phone", label: "Phone", value: phone)
                    }
                    
                    if (contact.email?.isEmpty ?? true) && (contact.phone?.isEmpty ?? true) {
                        Text("No contact information")
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var followUpSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Follow-Up")
                    .font(.headline)
                Spacer()
                Button("Set Reminder") {
                    showingFollowUpSheet = true
                }
                .font(.caption)
                .foregroundColor(.accentColor)
            }
            
            if let nextFollowUp = contact.nextFollowUp {
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.orange)
                    Text("Reminder set for \(formatDate(nextFollowUp))")
                        .font(.body)
                }
            } else {
                Text("No reminders set")
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes")
                .font(.headline)
            
            if isEditing {
                TextEditor(text: $editedNotes)
                    .frame(minHeight: 100)
                    .padding(4)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            } else {
                if let notes = contact.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.body)
                } else {
                    Text("No notes yet")
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var meetingContextSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Meeting Context")
                .font(.headline)
            
            if isEditing {
                TextField("Where did you meet?", text: $editedMetAt)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            } else {
                if let metAt = contact.metAt, !metAt.isEmpty {
                    HStack {
                        Image(systemName: "location")
                            .foregroundColor(.blue)
                        Text(metAt)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var initials: String {
        let first = contact.firstName?.first?.uppercased() ?? ""
        let last = contact.lastName?.first?.uppercased() ?? ""
        return "\(first)\(last)"
    }
    
    private func startEditing() {
        editedFirstName = contact.firstName ?? ""
        editedLastName = contact.lastName ?? ""
        editedCompany = contact.company ?? ""
        editedEmail = contact.email ?? ""
        editedPhone = contact.phone ?? ""
        editedJobTitle = contact.jobTitle ?? ""
        editedMetAt = contact.metAt ?? ""
        editedNotes = contact.notes ?? ""
    }
    
    private func saveChanges() {
        contact.firstName = editedFirstName
        contact.lastName = editedLastName
        contact.company = editedCompany.isEmpty ? nil : editedCompany
        contact.email = editedEmail.isEmpty ? nil : editedEmail
        contact.phone = editedPhone.isEmpty ? nil : editedPhone
        contact.jobTitle = editedJobTitle.isEmpty ? nil : editedJobTitle
        contact.metAt = editedMetAt.isEmpty ? nil : editedMetAt
        contact.notes = editedNotes.isEmpty ? nil : editedNotes
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ContactInfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 20)
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

struct ContactEditRow: View {
    let label: String
    @Binding var text: String
    let keyboardType: UIKeyboardType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            TextField(label, text: $text)
                .keyboardType(keyboardType)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct ContactDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let contact = Contact(context: context)
        contact.firstName = "John"
        contact.lastName = "Doe"
        contact.company = "TechCorp"
        contact.email = "john@techcorp.com"
        contact.phone = "(555) 123-4567"
        contact.dateAdded = Date()
        
        return NavigationView {
            ContactDetailView(contact: contact)
        }
        .environment(\.managedObjectContext, context)
    }
}