import SwiftUI
import UserNotifications
import CoreData

struct FollowUpReminderView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var notificationManager: NotificationManager
    @ObservedObject var contact: Contact
    
    @State private var selectedDate = Date()
    @State private var reminderTime = Date()
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    // Quick preset options
    private let presetOptions = [
        ("Tomorrow", Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()),
        ("In 3 days", Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()),
        ("Next week", Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date()) ?? Date()),
        ("In 2 weeks", Calendar.current.date(byAdding: .weekOfYear, value: 2, to: Date()) ?? Date()),
        ("Next month", Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date())
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                headerSection
                
                // Quick preset buttons
                quickPresetSection
                
                // Custom date and time picker
                customDateSection
                
                Spacer()
                
                // Save button
                saveButton
            }
            .padding()
            .navigationTitle("Set Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") {
                    if alertTitle == "Reminder Set!" {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                requestNotificationPermission()
                // Set default reminder time to 9 AM
                let calendar = Calendar.current
                reminderTime = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            // Contact info
            HStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(initials)
                            .font(.headline)
                            .foregroundColor(.accentColor)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(contact.firstName ?? "") \(contact.lastName ?? "")")
                        .font(.headline)
                    if let company = contact.company, !company.isEmpty {
                        Text(company)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            Text("When would you like to be reminded to follow up?")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var quickPresetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Options")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(presetOptions, id: \.0) { option in
                    Button(action: {
                        selectedDate = option.1
                        reminderTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: option.1) ?? option.1
                    }) {
                        VStack(spacing: 8) {
                            Text(option.0)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(formatPresetDate(option.1))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            Calendar.current.isDate(selectedDate, inSameDayAs: option.1) ?
                            Color.accentColor.opacity(0.2) : Color(.systemGray6)
                        )
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    Calendar.current.isDate(selectedDate, inSameDayAs: option.1) ?
                                    Color.accentColor : Color.clear,
                                    lineWidth: 2
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var customDateSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Custom Date & Time")
                .font(.headline)
            
            VStack(spacing: 12) {
                DatePicker(
                    "Reminder Date",
                    selection: $selectedDate,
                    in: Date()...,
                    displayedComponents: .date
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                
                DatePicker(
                    "Reminder Time",
                    selection: $reminderTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(WheelDatePickerStyle())
                .frame(height: 120)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private var saveButton: some View {
        Button(action: saveReminder) {
            HStack {
                Image(systemName: "bell.fill")
                Text("Set Reminder")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var initials: String {
        let first = contact.firstName?.first?.uppercased() ?? ""
        let last = contact.lastName?.first?.uppercased() ?? ""
        return "\(first)\(last)"
    }
    
    private func formatPresetDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func requestNotificationPermission() {
        Task {
            let granted = await notificationManager.requestAuthorization()
            if !granted {
                DispatchQueue.main.async {
                    alertTitle = "Permission Required"
                    alertMessage = "Please enable notifications in Settings to receive follow-up reminders."
                    showingAlert = true
                }
            }
        }
    }
    
    private func saveReminder() {
        // Combine selected date with reminder time
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: reminderTime)
        
        var finalComponents = dateComponents
        finalComponents.hour = timeComponents.hour
        finalComponents.minute = timeComponents.minute
        
        guard let finalDate = calendar.date(from: finalComponents) else { return }
        
        // Check if the date is in the past
        if finalDate <= Date() {
            alertTitle = "Invalid Date"
            alertMessage = "Please select a future date and time for your reminder."
            showingAlert = true
            return
        }
        
        // Save to Core Data
        contact.nextFollowUp = finalDate
        contact.lastContact = Date() // Update last contact to now
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
            return
        }
        
        // Schedule local notification using NotificationManager
        notificationManager.scheduleFollowUpReminder(for: contact, at: finalDate)
        
        alertTitle = "Reminder Set!"
        alertMessage = "You'll be reminded to follow up with \(contact.firstName ?? "") on \(formatReminderDate(finalDate))"
        showingAlert = true
    }
    
    private func formatReminderDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct FollowUpReminderView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let contact = Contact(context: context)
        contact.firstName = "John"
        contact.lastName = "Doe"
        contact.company = "TechCorp"
        
        return FollowUpReminderView(contact: contact)
            .environment(\.managedObjectContext, context)
    }
}