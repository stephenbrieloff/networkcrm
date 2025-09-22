import XCTest
import CoreData
import Combine
@testable import NetworkCRM

class ContactViewModelTests: XCTestCase {
    var viewModel: ContactViewModel!
    var testPersistenceController: PersistenceController!
    var testContext: NSManagedObjectContext!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        testPersistenceController = PersistenceController(inMemory: true)
        testContext = testPersistenceController.container.viewContext
        viewModel = ContactViewModel(viewContext: testContext)
        cancellables = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        cancellables?.forEach { $0.cancel() }
        cancellables = nil
        viewModel = nil
        testContext = nil
        testPersistenceController = nil
    }

    // MARK: - Contact Creation Tests
    
    func testCreateContact() throws {
        // Given
        let initialCount = viewModel.contacts.count
        
        // When
        let newContact = viewModel.createContact(
            firstName: "John",
            lastName: "Doe",
            company: "TechCorp",
            email: "john@techcorp.com",
            phone: "(555) 123-4567",
            metAt: "Tech Conference",
            notes: "Great conversation about AI"
        )
        
        // Then
        XCTAssertEqual(newContact.firstName, "John")
        XCTAssertEqual(newContact.lastName, "Doe")
        XCTAssertEqual(newContact.company, "TechCorp")
        XCTAssertEqual(newContact.email, "john@techcorp.com")
        XCTAssertEqual(newContact.phone, "(555) 123-4567")
        XCTAssertEqual(newContact.metAt, "Tech Conference")
        XCTAssertEqual(newContact.notes, "Great conversation about AI")
        XCTAssertNotNil(newContact.id)
        XCTAssertNotNil(newContact.dateAdded)
        XCTAssertEqual(newContact.interactionCount, 0)
        XCTAssertNotNil(newContact.quickTags)
        XCTAssertNotNil(newContact.conversationTopics)
    }

    func testCreateContactTrimsWhitespace() throws {
        // Given
        let spaceString = "  John  "
        let emptyString = "   "
        
        // When
        let newContact = viewModel.createContact(
            firstName: spaceString,
            lastName: "Doe",
            company: emptyString,
            email: emptyString,
            phone: nil
        )
        
        // Then
        XCTAssertEqual(newContact.firstName, "John")
        XCTAssertNil(newContact.company) // Should be nil because empty after trimming
        XCTAssertNil(newContact.email) // Should be nil because empty after trimming
        XCTAssertNil(newContact.phone)
    }

    // MARK: - Contact Fetching Tests
    
    func testFetchContactsInitiallyEmpty() {
        // Given/When - ViewModel initialized in setUp
        
        // Then
        XCTAssertEqual(viewModel.contacts.count, 0)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testFetchContactsWithData() throws {
        // Given
        let contact1 = Contact(context: testContext)
        contact1.id = UUID()
        contact1.firstName = "John"
        contact1.lastName = "Doe"
        contact1.dateAdded = Date()
        
        let contact2 = Contact(context: testContext)
        contact2.id = UUID()
        contact2.firstName = "Jane"
        contact2.lastName = "Smith"
        contact2.dateAdded = Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date()
        
        try testContext.save()
        
        // When
        viewModel.fetchContacts()
        
        // Then
        XCTAssertEqual(viewModel.contacts.count, 2)
        // Should be sorted by dateAdded descending (newest first)
        XCTAssertEqual(viewModel.contacts.first?.firstName, "John")
        XCTAssertEqual(viewModel.contacts.last?.firstName, "Jane")
    }

    // MARK: - Search Functionality Tests
    
    func testFilteredContactsWithEmptySearch() throws {
        // Given
        createTestContacts()
        viewModel.fetchContacts()
        
        // When
        viewModel.searchText = ""
        
        // Then
        XCTAssertEqual(viewModel.filteredContacts.count, viewModel.contacts.count)
    }

    func testFilteredContactsByFirstName() throws {
        // Given
        createTestContacts()
        viewModel.fetchContacts()
        
        // When
        viewModel.searchText = "john"
        
        // Then
        XCTAssertEqual(viewModel.filteredContacts.count, 1)
        XCTAssertEqual(viewModel.filteredContacts.first?.firstName, "John")
    }

    func testFilteredContactsByLastName() throws {
        // Given
        createTestContacts()
        viewModel.fetchContacts()
        
        // When
        viewModel.searchText = "smith"
        
        // Then
        XCTAssertEqual(viewModel.filteredContacts.count, 1)
        XCTAssertEqual(viewModel.filteredContacts.first?.lastName, "Smith")
    }

    func testFilteredContactsByCompany() throws {
        // Given
        createTestContacts()
        viewModel.fetchContacts()
        
        // When
        viewModel.searchText = "techcorp"
        
        // Then
        XCTAssertEqual(viewModel.filteredContacts.count, 1)
        XCTAssertEqual(viewModel.filteredContacts.first?.company, "TechCorp")
    }

    func testFilteredContactsByEmail() throws {
        // Given
        createTestContacts()
        viewModel.fetchContacts()
        
        // When
        viewModel.searchText = "jane@startup"
        
        // Then
        XCTAssertEqual(viewModel.filteredContacts.count, 1)
        XCTAssertEqual(viewModel.filteredContacts.first?.email, "jane@startup.com")
    }

    func testFilteredContactsCaseInsensitive() throws {
        // Given
        createTestContacts()
        viewModel.fetchContacts()
        
        // When
        viewModel.searchText = "JOHN"
        
        // Then
        XCTAssertEqual(viewModel.filteredContacts.count, 1)
        XCTAssertEqual(viewModel.filteredContacts.first?.firstName, "John")
    }

    func testFilteredContactsNoMatches() throws {
        // Given
        createTestContacts()
        viewModel.fetchContacts()
        
        // When
        viewModel.searchText = "nonexistent"
        
        // Then
        XCTAssertEqual(viewModel.filteredContacts.count, 0)
    }

    // MARK: - Follow-up Tests
    
    func testUpcomingFollowUps() throws {
        // Given
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: today)!
        let farFuture = Calendar.current.date(byAdding: .day, value: 30, to: today)!
        
        let contact1 = Contact(context: testContext)
        contact1.id = UUID()
        contact1.firstName = "Tomorrow"
        contact1.lastName = "Contact"
        contact1.dateAdded = today
        contact1.nextFollowUp = tomorrow
        
        let contact2 = Contact(context: testContext)
        contact2.id = UUID()
        contact2.firstName = "NextWeek"
        contact2.lastName = "Contact"
        contact2.dateAdded = today
        contact2.nextFollowUp = nextWeek
        
        let contact3 = Contact(context: testContext)
        contact3.id = UUID()
        contact3.firstName = "FarFuture"
        contact3.lastName = "Contact"
        contact3.dateAdded = today
        contact3.nextFollowUp = farFuture
        
        try testContext.save()
        viewModel.fetchContacts()
        
        // When
        let upcomingFollowUps = viewModel.upcomingFollowUps
        
        // Then
        XCTAssertEqual(upcomingFollowUps.count, 2) // Should not include far future
        XCTAssertTrue(upcomingFollowUps.contains { $0.firstName == "Tomorrow" })
        XCTAssertTrue(upcomingFollowUps.contains { $0.firstName == "NextWeek" })
        XCTAssertFalse(upcomingFollowUps.contains { $0.firstName == "FarFuture" })
    }

    // MARK: - Contact Deletion Tests
    
    func testDeleteContact() throws {
        // Given
        let contact = Contact(context: testContext)
        contact.id = UUID()
        contact.firstName = "Delete"
        contact.lastName = "Me"
        contact.dateAdded = Date()
        try testContext.save()
        
        viewModel.fetchContacts()
        let initialCount = viewModel.contacts.count
        XCTAssertEqual(initialCount, 1)
        
        // When
        viewModel.deleteContact(contact)
        
        // Then
        XCTAssertEqual(viewModel.contacts.count, 0)
    }

    // MARK: - Analytics Tests
    
    func testTotalContacts() throws {
        // Given
        createTestContacts()
        viewModel.fetchContacts()
        
        // When
        let totalContacts = viewModel.totalContacts
        
        // Then
        XCTAssertEqual(totalContacts, 2)
    }

    func testContactsAddedThisWeek() throws {
        // Given
        let today = Date()
        let lastWeek = Calendar.current.date(byAdding: .day, value: -8, to: today)!
        let thisWeek = Calendar.current.date(byAdding: .day, value: -3, to: today)!
        
        let contact1 = Contact(context: testContext)
        contact1.id = UUID()
        contact1.firstName = "Old"
        contact1.lastName = "Contact"
        contact1.dateAdded = lastWeek
        
        let contact2 = Contact(context: testContext)
        contact2.id = UUID()
        contact2.firstName = "New"
        contact2.lastName = "Contact"
        contact2.dateAdded = thisWeek
        
        try testContext.save()
        viewModel.fetchContacts()
        
        // When
        let recentContacts = viewModel.contactsAddedThisWeek
        
        // Then
        XCTAssertEqual(recentContacts, 1)
    }

    func testPendingFollowUps() throws {
        // Given
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let future = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        let contact1 = Contact(context: testContext)
        contact1.id = UUID()
        contact1.firstName = "Overdue"
        contact1.lastName = "Contact"
        contact1.dateAdded = today
        contact1.nextFollowUp = yesterday
        
        let contact2 = Contact(context: testContext)
        contact2.id = UUID()
        contact2.firstName = "Future"
        contact2.lastName = "Contact"
        contact2.dateAdded = today
        contact2.nextFollowUp = future
        
        try testContext.save()
        viewModel.fetchContacts()
        
        // When
        let pendingCount = viewModel.pendingFollowUps
        
        // Then
        XCTAssertEqual(pendingCount, 1) // Only the overdue one
    }

    // MARK: - Context Saving Tests
    
    func testSaveContext() throws {
        // Given
        let contact = Contact(context: testContext)
        contact.id = UUID()
        contact.firstName = "Save"
        contact.lastName = "Test"
        contact.dateAdded = Date()
        
        let initialCount = viewModel.contacts.count
        
        // When
        viewModel.saveContext()
        
        // Then
        XCTAssertEqual(viewModel.contacts.count, initialCount + 1)
        
        // Verify it's actually saved by fetching from a new context
        let fetchRequest: NSFetchRequest<Contact> = Contact.fetchRequest()
        let savedContacts = try testContext.fetch(fetchRequest)
        XCTAssertEqual(savedContacts.count, initialCount + 1)
    }

    // MARK: - Debounced Search Tests
    
    func testSearchTextDebouncing() {
        // Given
        let expectation = XCTestExpectation(description: "Search should be debounced")
        createTestContacts()
        viewModel.fetchContacts()
        
        var searchUpdateCount = 0
        
        // Monitor changes to filteredContacts
        viewModel.$searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { _ in
                searchUpdateCount += 1
                if searchUpdateCount == 1 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When - rapidly change search text
        viewModel.searchText = "j"
        viewModel.searchText = "jo"
        viewModel.searchText = "joh"
        viewModel.searchText = "john"
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(searchUpdateCount, 1, "Search should be debounced to prevent excessive updates")
    }

    // MARK: - Helper Methods
    
    private func createTestContacts() {
        let contact1 = Contact(context: testContext)
        contact1.id = UUID()
        contact1.firstName = "John"
        contact1.lastName = "Doe"
        contact1.company = "TechCorp"
        contact1.email = "john@techcorp.com"
        contact1.dateAdded = Date()
        
        let contact2 = Contact(context: testContext)
        contact2.id = UUID()
        contact2.firstName = "Jane"
        contact2.lastName = "Smith"
        contact2.company = "StartupCo"
        contact2.email = "jane@startup.com"
        contact2.dateAdded = Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date()
        
        try? testContext.save()
    }
}