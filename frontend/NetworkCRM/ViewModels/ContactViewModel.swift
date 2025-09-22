import SwiftUI
import CoreData
import Combine

class ContactViewModel: ObservableObject {
    @Published var contacts: [Contact] = []
    @Published var searchText = ""
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        setupSearchTextBinding()
        fetchContacts()
    }
    
    var filteredContacts: [Contact] {
        if searchText.isEmpty {
            return contacts
        } else {
            return contacts.filter { contact in
                contact.firstName?.localizedCaseInsensitiveContains(searchText) == true ||
                contact.lastName?.localizedCaseInsensitiveContains(searchText) == true ||
                contact.company?.localizedCaseInsensitiveContains(searchText) == true ||
                contact.email?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
    }
    
    var upcomingFollowUps: [Contact] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: today) ?? Date()
        
        return contacts.filter { contact in
            guard let followUpDate = contact.nextFollowUp else { return false }
            return followUpDate >= today && followUpDate <= nextWeek
        }.sorted { $0.nextFollowUp ?? Date() < $1.nextFollowUp ?? Date() }
    }
    
    private func setupSearchTextBinding() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { _ in
                // Search text changed, UI will automatically update through filteredContacts
            }
            .store(in: &cancellables)
    }
    
    func fetchContacts() {
        isLoading = true
        
        let request: NSFetchRequest<Contact> = Contact.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        
        do {
            contacts = try viewContext.fetch(request)
        } catch {
            print("Error fetching contacts: \(error)")
            contacts = []
        }
        
        isLoading = false
    }
    
    func deleteContact(_ contact: Contact) {
        viewContext.delete(contact)
        
        do {
            try viewContext.save()
            fetchContacts() // Refresh the list
        } catch {
            print("Error deleting contact: \(error)")
        }
    }
    
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                fetchContacts() // Refresh after save
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    // Analytics helpers
    var totalContacts: Int {
        contacts.count
    }
    
    var contactsAddedThisWeek: Int {
        let calendar = Calendar.current
        let oneWeekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
        
        return contacts.filter { contact in
            guard let dateAdded = contact.dateAdded else { return false }
            return dateAdded >= oneWeekAgo
        }.count
    }
    
    var pendingFollowUps: Int {
        let today = Date()
        return contacts.filter { contact in
            guard let followUpDate = contact.nextFollowUp else { return false }
            return followUpDate <= today
        }.count
    }
}

// MARK: - Contact Creation Helper
extension ContactViewModel {
    func createContact(
        firstName: String,
        lastName: String,
        company: String? = nil,
        email: String? = nil,
        phone: String? = nil,
        metAt: String? = nil,
        notes: String? = nil
    ) -> Contact {
        let newContact = Contact(context: viewContext)
        newContact.id = UUID()
        newContact.firstName = firstName.trimmingCharacters(in: .whitespaces)
        newContact.lastName = lastName.trimmingCharacters(in: .whitespaces)
        newContact.company = company?.trimmingCharacters(in: .whitespaces).isEmpty == false ? company?.trimmingCharacters(in: .whitespaces) : nil
        newContact.email = email?.trimmingCharacters(in: .whitespaces).isEmpty == false ? email?.trimmingCharacters(in: .whitespaces) : nil
        newContact.phone = phone?.trimmingCharacters(in: .whitespaces).isEmpty == false ? phone?.trimmingCharacters(in: .whitespaces) : nil
        newContact.metAt = metAt?.trimmingCharacters(in: .whitespaces).isEmpty == false ? metAt?.trimmingCharacters(in: .whitespaces) : nil
        newContact.notes = notes?.trimmingCharacters(in: .whitespaces).isEmpty == false ? notes?.trimmingCharacters(in: .whitespaces) : nil
        newContact.dateAdded = Date()
        newContact.interactionCount = 0
        newContact.quickTags = []
        newContact.conversationTopics = []
        
        return newContact
    }
}