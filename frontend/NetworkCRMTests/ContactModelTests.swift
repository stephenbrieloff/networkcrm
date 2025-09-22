import XCTest
import CoreData
@testable import NetworkCRM

class ContactModelTests: XCTestCase {
    var testPersistenceController: PersistenceController!
    var testContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        // Create in-memory persistence controller for testing
        testPersistenceController = PersistenceController(inMemory: true)
        testContext = testPersistenceController.container.viewContext
    }

    override func tearDownWithError() throws {
        testPersistenceController = nil
        testContext = nil
    }

    // MARK: - Contact Creation Tests
    
    func testContactCreation() throws {
        // Given
        let contact = Contact(context: testContext)
        let testId = UUID()
        let testDate = Date()
        
        // When
        contact.id = testId
        contact.firstName = "John"
        contact.lastName = "Doe"
        contact.company = "TechCorp"
        contact.email = "john@techcorp.com"
        contact.phone = "(555) 123-4567"
        contact.dateAdded = testDate
        contact.metAt = "Tech Conference"
        contact.interactionCount = 0
        
        // Then
        XCTAssertEqual(contact.id, testId)
        XCTAssertEqual(contact.firstName, "John")
        XCTAssertEqual(contact.lastName, "Doe")
        XCTAssertEqual(contact.company, "TechCorp")
        XCTAssertEqual(contact.email, "john@techcorp.com")
        XCTAssertEqual(contact.phone, "(555) 123-4567")
        XCTAssertEqual(contact.dateAdded, testDate)
        XCTAssertEqual(contact.metAt, "Tech Conference")
        XCTAssertEqual(contact.interactionCount, 0)
    }

    func testContactPersistence() throws {
        // Given
        let contact = Contact(context: testContext)
        contact.id = UUID()
        contact.firstName = "Jane"
        contact.lastName = "Smith"
        contact.company = "StartupCo"
        contact.dateAdded = Date()
        
        // When
        try testContext.save()
        
        // Fetch the saved contact
        let request: NSFetchRequest<Contact> = Contact.fetchRequest()
        request.predicate = NSPredicate(format: "firstName == %@", "Jane")
        let savedContacts = try testContext.fetch(request)
        
        // Then
        XCTAssertEqual(savedContacts.count, 1)
        let savedContact = savedContacts.first!
        XCTAssertEqual(savedContact.firstName, "Jane")
        XCTAssertEqual(savedContact.lastName, "Smith")
        XCTAssertEqual(savedContact.company, "StartupCo")
    }

    func testContactDeletion() throws {
        // Given
        let contact = Contact(context: testContext)
        contact.id = UUID()
        contact.firstName = "Test"
        contact.lastName = "Delete"
        contact.dateAdded = Date()
        
        try testContext.save()
        
        // Verify contact exists
        let fetchRequest: NSFetchRequest<Contact> = Contact.fetchRequest()
        var contacts = try testContext.fetch(fetchRequest)
        XCTAssertEqual(contacts.count, 1)
        
        // When
        testContext.delete(contact)
        try testContext.save()
        
        // Then
        contacts = try testContext.fetch(fetchRequest)
        XCTAssertEqual(contacts.count, 0)
    }

    // MARK: - Contact Validation Tests
    
    func testRequiredFields() throws {
        // Given
        let contact = Contact(context: testContext)
        
        // When setting minimal required fields
        contact.id = UUID()
        contact.firstName = "John"
        contact.lastName = "Doe"
        contact.dateAdded = Date()
        
        // Then
        XCTAssertNoThrow(try testContext.save())
    }

    func testOptionalFields() throws {
        // Given
        let contact = Contact(context: testContext)
        contact.id = UUID()
        contact.firstName = "John"
        contact.lastName = "Doe"
        contact.dateAdded = Date()
        
        // When
        contact.company = nil
        contact.email = nil
        contact.phone = nil
        contact.metAt = nil
        contact.notes = nil
        
        // Then
        XCTAssertNoThrow(try testContext.save())
        XCTAssertNil(contact.company)
        XCTAssertNil(contact.email)
        XCTAssertNil(contact.phone)
        XCTAssertNil(contact.metAt)
        XCTAssertNil(contact.notes)
    }

    // MARK: - Contact Array Fields Tests
    
    func testQuickTagsArray() throws {
        // Given
        let contact = Contact(context: testContext)
        contact.id = UUID()
        contact.firstName = "John"
        contact.lastName = "Doe"
        contact.dateAdded = Date()
        
        // When
        contact.quickTags = ["networking", "tech", "startup"]
        
        try testContext.save()
        
        // Refetch the contact
        let request: NSFetchRequest<Contact> = Contact.fetchRequest()
        request.predicate = NSPredicate(format: "firstName == %@", "John")
        let savedContacts = try testContext.fetch(request)
        
        // Then
        XCTAssertEqual(savedContacts.count, 1)
        let savedContact = savedContacts.first!
        XCTAssertEqual(savedContact.quickTags, ["networking", "tech", "startup"])
    }

    func testConversationTopicsArray() throws {
        // Given
        let contact = Contact(context: testContext)
        contact.id = UUID()
        contact.firstName = "Jane"
        contact.lastName = "Smith"
        contact.dateAdded = Date()
        
        // When
        contact.conversationTopics = ["AI/ML", "Mobile Development", "Venture Capital"]
        
        try testContext.save()
        
        // Refetch the contact
        let request: NSFetchRequest<Contact> = Contact.fetchRequest()
        request.predicate = NSPredicate(format: "firstName == %@", "Jane")
        let savedContacts = try testContext.fetch(request)
        
        // Then
        XCTAssertEqual(savedContacts.count, 1)
        let savedContact = savedContacts.first!
        XCTAssertEqual(savedContact.conversationTopics, ["AI/ML", "Mobile Development", "Venture Capital"])
    }

    // MARK: - Follow-up Tests
    
    func testFollowUpDateHandling() throws {
        // Given
        let contact = Contact(context: testContext)
        contact.id = UUID()
        contact.firstName = "Follow"
        contact.lastName = "Up"
        contact.dateAdded = Date()
        
        let futureDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        
        // When
        contact.nextFollowUp = futureDate
        
        try testContext.save()
        
        // Refetch the contact
        let request: NSFetchRequest<Contact> = Contact.fetchRequest()
        request.predicate = NSPredicate(format: "firstName == %@", "Follow")
        let savedContacts = try testContext.fetch(request)
        
        // Then
        XCTAssertEqual(savedContacts.count, 1)
        let savedContact = savedContacts.first!
        XCTAssertNotNil(savedContact.nextFollowUp)
        
        // Compare dates with some tolerance for milliseconds
        let timeInterval = abs(savedContact.nextFollowUp!.timeIntervalSince(futureDate))
        XCTAssertLessThan(timeInterval, 1.0, "Dates should be within 1 second")
    }
}