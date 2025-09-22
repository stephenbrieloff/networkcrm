import SwiftUI
import CoreData

struct ContactListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var searchText = ""
    @State private var showingAddContact = false
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Contact.dateAdded, ascending: false)],
        animation: .default)
    private var contacts: FetchedResults<Contact>
    
    var filteredContacts: [Contact] {
        if searchText.isEmpty {
            return Array(contacts)
        } else {
            return contacts.filter { contact in
                contact.firstName?.localizedCaseInsensitiveContains(searchText) == true ||
                contact.lastName?.localizedCaseInsensitiveContains(searchText) == true ||
                contact.company?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if filteredContacts.isEmpty {
                    EmptyStateView(showingAddContact: $showingAddContact)
                } else {
                    List {
                        ForEach(filteredContacts, id: \.id) { contact in
                            NavigationLink(destination: ContactDetailView(contact: contact)) {
                                ContactRowView(contact: contact)
                            }
                        }
                        .onDelete(perform: deleteContacts)
                    }
                    .searchable(text: $searchText, prompt: "Search contacts...")
                }
            }
            .navigationTitle("Contacts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddContact = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
                
                if !contacts.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }
                }
            }
            .sheet(isPresented: $showingAddContact) {
                AddContactView()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func deleteContacts(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredContacts[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                // Handle the error appropriately
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ContactRowView: View {
    let contact: Contact
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("\(contact.firstName ?? "") \(contact.lastName ?? "")")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if let nextFollowUp = contact.nextFollowUp {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                }
            }
            
            if let company = contact.company, !company.isEmpty {
                Text(company)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text(formatDate(contact.dateAdded))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let metAt = contact.metAt, !metAt.isEmpty {
                    Text("• \(metAt)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isToday(date) {
            return "Today"
        } else if calendar.isYesterday(date) {
            return "Yesterday"
        } else if calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) {
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        } else {
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
    }
}

struct EmptyStateView: View {
    @Binding var showingAddContact: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2.circle")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No Contacts Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Add your first networking contact in just 5 seconds")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button(action: {
                showingAddContact = true
            }) {
                Text("Add First Contact")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}

struct ContactListView_Previews: PreviewProvider {
    static var previews: some View {
        ContactListView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}