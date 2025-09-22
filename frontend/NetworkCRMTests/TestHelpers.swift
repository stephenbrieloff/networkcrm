import Foundation
import CoreData
import UserNotifications
@testable import NetworkCRM

// MARK: - Test Data Factory

class TestDataFactory {
    
    static func createTestContact(
        in context: NSManagedObjectContext,
        firstName: String = "Test",
        lastName: String = "Contact",
        company: String? = "TestCorp",
        email: String? = "test@example.com",
        phone: String? = "(555) 123-4567",
        metAt: String? = "Test Event",
        notes: String? = "Test notes"
    ) -> Contact {
        let contact = Contact(context: context)
        contact.id = UUID()
        contact.firstName = firstName
        contact.lastName = lastName
        contact.company = company
        contact.email = email
        contact.phone = phone
        contact.metAt = metAt
        contact.notes = notes
        contact.dateAdded = Date()
        contact.interactionCount = 0
        contact.quickTags = []
        contact.conversationTopics = []
        
        return contact
    }
    
    static func createContactWithFollowUp(
        in context: NSManagedObjectContext,
        firstName: String = "FollowUp",
        lastName: String = "Contact",
        followUpDate: Date
    ) -> Contact {
        let contact = createTestContact(in: context, firstName: firstName, lastName: lastName)
        contact.nextFollowUp = followUpDate
        return contact
    }
    
    static func createBulkContacts(
        in context: NSManagedObjectContext,
        count: Int,
        namePrefix: String = "Bulk"
    ) -> [Contact] {
        var contacts: [Contact] = []
        
        for i in 0..<count {
            let contact = createTestContact(
                in: context,
                firstName: "\\(namePrefix)\\(i)",
                lastName: "Contact",
                company: i % 3 == 0 ? "TechCorp" : (i % 3 == 1 ? "StartupCo" : "BigCorp"),
                email: "\\(namePrefix.lowercased())\\(i)@example.com"
            )
            contacts.append(contact)
        }
        
        return contacts
    }
    
    static func createContactsWithVariousDates(
        in context: NSManagedObjectContext,
        count: Int
    ) -> [Contact] {
        var contacts: [Contact] = []
        let calendar = Calendar.current
        let today = Date()
        
        for i in 0..<count {
            let contact = createTestContact(
                in: context,
                firstName: "DateTest\\(i)",
                lastName: "Contact"
            )
            
            // Distribute dates over the past 30 days
            let daysAgo = i % 30
            contact.dateAdded = calendar.date(byAdding: .day, value: -daysAgo, to: today) ?? today
            
            contacts.append(contact)
        }
        
        return contacts
    }
    
    static func saveTestContacts(_ contacts: [Contact], in context: NSManagedObjectContext) throws {
        try context.save()
    }
}

// MARK: - Mock NotificationManager

class MockNotificationManager: NotificationManager {
    
    var isScheduleFollowUpReminderCalled = false
    var isCancelFollowUpReminderCalled = false
    var isCancelAllNotificationsCalled = false
    var isRequestAuthorizationCalled = false
    
    var scheduledReminders: [(Contact, Date)] = []
    var cancelledReminderContacts: [Contact] = []
    var mockPendingNotificationCount = 0
    var mockIsAuthorized = true
    
    override init() {
        super.init()
        self.isAuthorized = mockIsAuthorized
    }
    
    override func scheduleFollowUpReminder(for contact: Contact, at date: Date) {
        isScheduleFollowUpReminderCalled = true
        scheduledReminders.append((contact, date))
    }
    
    override func cancelFollowUpReminder(for contact: Contact) {
        isCancelFollowUpReminderCalled = true
        cancelledReminderContacts.append(contact)
    }
    
    override func cancelAllNotifications() {
        isCancelAllNotificationsCalled = true
        scheduledReminders.removeAll()
    }
    
    override func requestAuthorization() async -> Bool {
        isRequestAuthorizationCalled = true
        return mockIsAuthorized
    }
    
    override func getPendingNotificationCount() async -> Int {
        return mockPendingNotificationCount
    }
    
    // Helper methods for testing
    func reset() {
        isScheduleFollowUpReminderCalled = false
        isCancelFollowUpReminderCalled = false
        isCancelAllNotificationsCalled = false
        isRequestAuthorizationCalled = false
        scheduledReminders.removeAll()
        cancelledReminderContacts.removeAll()
    }
    
    func setMockAuthorization(_ authorized: Bool) {
        mockIsAuthorized = authorized
        self.isAuthorized = authorized
    }
}

// MARK: - Test Persistence Controller

class TestPersistenceController {
    static func createInMemoryController() -> PersistenceController {
        return PersistenceController(inMemory: true)
    }
    
    static func createControllerWithSampleData() -> PersistenceController {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        
        // Create sample contacts
        let sampleContacts = [
            ("John", "Doe", "TechCorp", "john@techcorp.com"),
            ("Jane", "Smith", "StartupCo", "jane@startup.com"),
            ("Bob", "Johnson", "BigCorp", "bob@bigcorp.com"),
            ("Alice", "Williams", "InnovateLtd", "alice@innovate.com"),
            ("Charlie", "Brown", "DesignStudio", "charlie@design.com")
        ]
        
        for (firstName, lastName, company, email) in sampleContacts {
            let contact = TestDataFactory.createTestContact(
                in: context,
                firstName: firstName,
                lastName: lastName,
                company: company,
                email: email
            )
            
            // Add some with follow-ups
            if firstName == "John" || firstName == "Alice" {
                let followUpDate = Calendar.current.date(byAdding: .day, value: Int.random(in: 1...7), to: Date())
                contact.nextFollowUp = followUpDate
            }
        }
        
        try? context.save()
        return controller
    }
}

// MARK: - Test Assertions Helper

class TestAssertions {
    
    static func assertContactEquals(
        _ contact: Contact,
        firstName: String,
        lastName: String,
        company: String? = nil,
        email: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(contact.firstName, firstName, file: file, line: line)
        XCTAssertEqual(contact.lastName, lastName, file: file, line: line)
        
        if let expectedCompany = company {
            XCTAssertEqual(contact.company, expectedCompany, file: file, line: line)
        }
        
        if let expectedEmail = email {
            XCTAssertEqual(contact.email, expectedEmail, file: file, line: line)
        }
        
        XCTAssertNotNil(contact.id, "Contact should have an ID", file: file, line: line)
        XCTAssertNotNil(contact.dateAdded, "Contact should have a dateAdded", file: file, line: line)
    }
    
    static func assertPerformanceTime(
        _ actualTime: TimeInterval,
        isLessThan expectedTime: TimeInterval,
        operation: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertLessThan(
            actualTime,
            expectedTime,
            "\\(operation) should complete in under \\(expectedTime) seconds. Actual: \\(actualTime) seconds",
            file: file,
            line: line
        )
    }
    
    static func assertFiveSecondRule(
        _ actualTime: TimeInterval,
        operation: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        assertPerformanceTime(actualTime, isLessThan: 5.0, operation: operation, file: file, line: line)
    }
}

// MARK: - Test Extensions

extension ContactViewModel {
    
    /// Helper method to create a test contact with minimal data
    func createTestContact(firstName: String = "Test", lastName: String = "User") -> Contact {
        return createContact(firstName: firstName, lastName: lastName)
    }
    
    /// Helper method to populate with bulk test data
    func populateWithTestData(count: Int = 10) {
        for i in 0..<count {
            let contact = createContact(
                firstName: "TestUser\\(i)",
                lastName: "LastName",
                company: i % 2 == 0 ? "TechCorp" : "StartupCo",
                email: "testuser\\(i)@example.com"
            )
            
            // Add some variation
            if i % 3 == 0 {
                let followUpDate = Calendar.current.date(byAdding: .day, value: i % 7 + 1, to: Date())
                contact.nextFollowUp = followUpDate
            }
        }
        
        saveContext()
    }
    
    /// Helper to clear all test data
    func clearAllTestData() {
        for contact in contacts {
            deleteContact(contact)
        }
    }
}

// MARK: - Test Configuration

struct TestConfiguration {
    
    // Performance thresholds
    static let contactCreationThreshold: TimeInterval = 1.0
    static let searchThreshold: TimeInterval = 0.1
    static let fetchThreshold: TimeInterval = 0.5
    static let saveThreshold: TimeInterval = 0.5
    static let fiveSecondRuleThreshold: TimeInterval = 5.0
    static let appLaunchThreshold: TimeInterval = 3.0
    
    // Test data sizes
    static let smallDataSet = 10
    static let mediumDataSet = 50
    static let largeDataSet = 200
    static let stressTestDataSet = 500
    
    // Common test data
    static let sampleFirstNames = ["John", "Jane", "Bob", "Alice", "Charlie", "Diana", "Eve", "Frank"]
    static let sampleLastNames = ["Smith", "Doe", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller"]
    static let sampleCompanies = ["TechCorp", "StartupCo", "BigCorp", "InnovateLtd", "DesignStudio", "DataSystems"]
    static let sampleEmails = ["user@example.com", "contact@test.com", "hello@company.co"]
    
    static func randomSampleData() -> (firstName: String, lastName: String, company: String) {
        return (
            firstName: sampleFirstNames.randomElement() ?? "Test",
            lastName: sampleLastNames.randomElement() ?? "User", 
            company: sampleCompanies.randomElement() ?? "TestCorp"
        )
    }
}

// MARK: - Test Wait Helpers

class TestWaitHelper {
    
    static func waitForCondition(
        timeout: TimeInterval = 2.0,
        condition: () -> Bool,
        description: String = "Condition"
    ) -> Bool {
        let startTime = Date()
        
        while Date().timeIntervalSince(startTime) < timeout {
            if condition() {
                return true
            }
            
            RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.01))
        }
        
        return false
    }
    
    static func waitForViewModelUpdate(
        _ viewModel: ContactViewModel,
        timeout: TimeInterval = 1.0,
        expectedContactCount: Int? = nil
    ) -> Bool {
        return waitForCondition(timeout: timeout) {
            if let expectedCount = expectedContactCount {
                return viewModel.contacts.count == expectedCount
            } else {
                return !viewModel.isLoading
            }
        }
    }
}