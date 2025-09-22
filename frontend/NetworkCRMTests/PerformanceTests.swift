import XCTest
import CoreData
@testable import NetworkCRM

class PerformanceTests: XCTestCase {
    var viewModel: ContactViewModel!
    var testPersistenceController: PersistenceController!
    var testContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        testPersistenceController = PersistenceController(inMemory: true)
        testContext = testPersistenceController.container.viewContext
        viewModel = ContactViewModel(viewContext: testContext)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        testContext = nil
        testPersistenceController = nil
    }

    // MARK: - 5-Second Rule Tests
    
    func testContactCreationPerformance() throws {
        // Given - Measure the time to create a contact
        let expectation = XCTestExpectation(description: "Contact creation should complete quickly")
        
        // When - Measure contact creation time
        let startTime = Date()
        
        let newContact = viewModel.createContact(
            firstName: "Performance",
            lastName: "Test",
            company: "TestCorp",
            email: "test@testcorp.com",
            phone: "(555) 123-4567",
            metAt: "Performance Testing",
            notes: "Testing contact creation speed"
        )
        
        // Save the contact
        viewModel.saveContext()
        
        let endTime = Date()
        let creationTime = endTime.timeIntervalSince(startTime)
        
        // Then - Should complete in well under 5 seconds (aiming for under 1 second)
        XCTAssertLessThan(creationTime, 1.0, "Contact creation should complete in under 1 second. Actual: \\(creationTime) seconds")
        XCTAssertNotNil(newContact.id)
        XCTAssertEqual(newContact.firstName, "Performance")
        
        expectation.fulfill()
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testBulkContactCreationPerformance() throws {
        // Given - Test performance with multiple contacts
        let contactCount = 10
        let startTime = Date()
        
        // When - Create multiple contacts
        for i in 0..<contactCount {
            let contact = viewModel.createContact(
                firstName: "Bulk\\(i)",
                lastName: "Contact",
                company: "Company\\(i)",
                email: "bulk\\(i)@test.com"
            )
            XCTAssertNotNil(contact.id)
        }
        
        viewModel.saveContext()
        
        let endTime = Date()
        let totalTime = endTime.timeIntervalSince(startTime)
        let averageTime = totalTime / Double(contactCount)
        
        // Then - Each contact should still be created quickly
        XCTAssertLessThan(totalTime, 5.0, "Bulk contact creation should complete in under 5 seconds")
        XCTAssertLessThan(averageTime, 0.5, "Average contact creation should be under 0.5 seconds")
        XCTAssertEqual(viewModel.contacts.count, contactCount)
    }
    
    func testSearchPerformance() throws {
        // Given - Create test data
        createBulkTestContacts(count: 100)
        viewModel.fetchContacts()
        
        // When - Measure search performance
        let startTime = Date()
        
        viewModel.searchText = "test"
        let filteredContacts = viewModel.filteredContacts
        
        let endTime = Date()
        let searchTime = endTime.timeIntervalSince(startTime)
        
        // Then - Search should be instant
        XCTAssertLessThan(searchTime, 0.1, "Search should complete in under 0.1 seconds. Actual: \\(searchTime) seconds")
        XCTAssertGreaterThan(filteredContacts.count, 0, "Should find matching contacts")
    }
    
    func testFollowUpCalculationPerformance() throws {
        // Given - Create contacts with various follow-up dates
        let contactCount = 50
        createContactsWithFollowUps(count: contactCount)
        viewModel.fetchContacts()
        
        // When - Measure follow-up calculations
        let startTime = Date()
        
        let upcomingFollowUps = viewModel.upcomingFollowUps
        let pendingFollowUps = viewModel.pendingFollowUps
        
        let endTime = Date()
        let calculationTime = endTime.timeIntervalSince(startTime)
        
        // Then - Calculations should be fast
        XCTAssertLessThan(calculationTime, 0.5, "Follow-up calculations should complete in under 0.5 seconds")
        XCTAssertGreaterThanOrEqual(upcomingFollowUps.count, 0)
        XCTAssertGreaterThanOrEqual(pendingFollowUps, 0)
    }
    
    // MARK: - Core Data Performance Tests
    
    func testCoreDataFetchPerformance() throws {
        // Given - Create a substantial amount of test data
        createBulkTestContacts(count: 200)
        
        // When - Measure fetch performance
        measure {
            viewModel.fetchContacts()
        }
        
        // Then - Should complete quickly (measured by XCTest measure)
        XCTAssertEqual(viewModel.contacts.count, 200)
    }
    
    func testCoreDataSavePerformance() throws {
        // Given - Create contacts in memory
        for i in 0..<50 {
            let contact = Contact(context: testContext)
            contact.id = UUID()
            contact.firstName = "Save\\(i)"
            contact.lastName = "Test"
            contact.dateAdded = Date()
        }
        
        // When - Measure save performance
        measure {
            viewModel.saveContext()
        }
        
        // Then - Save should complete quickly
        let fetchRequest: NSFetchRequest<Contact> = Contact.fetchRequest()
        let savedContacts = try testContext.fetch(fetchRequest)
        XCTAssertEqual(savedContacts.count, 50)
    }
    
    func testCoreDataDeletePerformance() throws {
        // Given - Create and save test contacts
        createBulkTestContacts(count: 30)
        viewModel.fetchContacts()
        let initialCount = viewModel.contacts.count
        
        // When - Measure delete performance
        let startTime = Date()
        
        for contact in viewModel.contacts.prefix(10) {
            viewModel.deleteContact(contact)
        }
        
        let endTime = Date()
        let deleteTime = endTime.timeIntervalSince(startTime)
        
        // Then - Deletion should be fast
        XCTAssertLessThan(deleteTime, 1.0, "Deleting 10 contacts should complete in under 1 second")
        XCTAssertEqual(viewModel.contacts.count, initialCount - 10)
    }
    
    // MARK: - Memory Performance Tests
    
    func testMemoryUsageDuringBulkOperations() throws {
        // Given - Start with clean slate
        let initialContactCount = viewModel.contacts.count
        
        // When - Perform bulk operations
        let iterations = 5
        for iteration in 0..<iterations {
            // Create contacts
            for i in 0..<20 {
                let contact = viewModel.createContact(
                    firstName: "Memory\\(iteration)\\(i)",
                    lastName: "Test"
                )
                XCTAssertNotNil(contact)
            }
            
            // Save and fetch
            viewModel.saveContext()
            viewModel.fetchContacts()
            
            // Perform search (exercises filtered contacts)
            viewModel.searchText = "Memory\\(iteration)"
            _ = viewModel.filteredContacts
            viewModel.searchText = ""
            
            // Clean up some contacts to simulate real usage
            if iteration > 0 {
                let contactsToDelete = Array(viewModel.contacts.prefix(5))
                for contact in contactsToDelete {
                    viewModel.deleteContact(contact)
                }
            }
        }
        
        // Then - Memory should be managed efficiently (no specific assertion, just shouldn't crash)
        XCTAssertGreaterThan(viewModel.contacts.count, initialContactCount)
    }
    
    // MARK: - Notification Performance Tests
    
    func testNotificationSchedulingPerformance() throws {
        // Given - Create a contact and notification manager
        let contact = viewModel.createContact(firstName: "Notification", lastName: "Test")
        let notificationManager = NotificationManager()
        let futureDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        
        // When - Measure notification scheduling
        let startTime = Date()
        
        notificationManager.scheduleFollowUpReminder(for: contact, at: futureDate)
        
        let endTime = Date()
        let schedulingTime = endTime.timeIntervalSince(startTime)
        
        // Then - Should be nearly instant
        XCTAssertLessThan(schedulingTime, 0.1, "Notification scheduling should complete in under 0.1 seconds")
        
        // Clean up
        notificationManager.cancelFollowUpReminder(for: contact)
    }
    
    // MARK: - Analytics Performance Tests
    
    func testAnalyticsCalculationPerformance() throws {
        // Given - Create test data with various dates
        createContactsWithVariousDates(count: 100)
        viewModel.fetchContacts()
        
        // When - Measure analytics calculations
        let startTime = Date()
        
        let totalContacts = viewModel.totalContacts
        let recentContacts = viewModel.contactsAddedThisWeek
        let pendingFollowUps = viewModel.pendingFollowUps
        
        let endTime = Date()
        let analyticsTime = endTime.timeIntervalSince(startTime)
        
        // Then - Analytics should be calculated quickly
        XCTAssertLessThan(analyticsTime, 0.2, "Analytics calculations should complete in under 0.2 seconds")
        XCTAssertEqual(totalContacts, 100)
        XCTAssertGreaterThanOrEqual(recentContacts, 0)
        XCTAssertGreaterThanOrEqual(pendingFollowUps, 0)
    }
    
    // MARK: - Stress Tests
    
    func testAppStressWithManyContacts() throws {
        // Given - Create a large number of contacts
        let largeContactCount = 500
        let batchSize = 50
        
        for batch in 0..<(largeContactCount / batchSize) {
            for i in 0..<batchSize {
                let contact = viewModel.createContact(
                    firstName: "Stress\\(batch)",
                    lastName: "Contact\\(i)",
                    company: "StressCorp\\(batch % 10)"
                )
                XCTAssertNotNil(contact)
            }
            
            // Save periodically to avoid memory buildup
            if batch % 5 == 0 {
                viewModel.saveContext()
            }
        }
        
        viewModel.saveContext()
        
        // When - Test various operations under stress
        let startTime = Date()
        
        viewModel.fetchContacts()
        let fetchTime = Date().timeIntervalSince(startTime)
        
        viewModel.searchText = "Stress0"
        let searchResults = viewModel.filteredContacts
        let searchTime = Date().timeIntervalSince(startTime) - fetchTime
        
        let analytics = (viewModel.totalContacts, viewModel.contactsAddedThisWeek)
        let analyticsTime = Date().timeIntervalSince(startTime) - fetchTime - searchTime
        
        // Then - App should handle large datasets reasonably well
        XCTAssertLessThan(fetchTime, 2.0, "Fetching \\(largeContactCount) contacts should complete in under 2 seconds")
        XCTAssertLessThan(searchTime, 0.5, "Searching through \\(largeContactCount) contacts should complete in under 0.5 seconds")
        XCTAssertLessThan(analyticsTime, 0.5, "Analytics on \\(largeContactCount) contacts should complete in under 0.5 seconds")
        
        XCTAssertEqual(viewModel.contacts.count, largeContactCount)
        XCTAssertGreaterThan(searchResults.count, 0)
        XCTAssertEqual(analytics.0, largeContactCount)
    }
    
    // MARK: - Helper Methods
    
    private func createBulkTestContacts(count: Int) {
        for i in 0..<count {
            let contact = Contact(context: testContext)
            contact.id = UUID()
            contact.firstName = "Test\\(i)"
            contact.lastName = "Contact"
            contact.company = i % 2 == 0 ? "TestCorp" : "BulkCorp"
            contact.email = "test\\(i)@example.com"
            contact.dateAdded = Date()
        }
        
        try? testContext.save()
    }
    
    private func createContactsWithFollowUps(count: Int) {
        let today = Date()
        let calendar = Calendar.current
        
        for i in 0..<count {
            let contact = Contact(context: testContext)
            contact.id = UUID()
            contact.firstName = "FollowUp\\(i)"
            contact.lastName = "Contact"
            contact.dateAdded = today
            
            // Distribute follow-ups across different time periods
            let daysToAdd = (i % 14) - 7 // Range from -7 to +6 days
            contact.nextFollowUp = calendar.date(byAdding: .day, value: daysToAdd, to: today)
        }
        
        try? testContext.save()
    }
    
    private func createContactsWithVariousDates(count: Int) {
        let today = Date()
        let calendar = Calendar.current
        
        for i in 0..<count {
            let contact = Contact(context: testContext)
            contact.id = UUID()
            contact.firstName = "Analytics\\(i)"
            contact.lastName = "Contact"
            
            // Distribute creation dates over the past month
            let daysAgo = i % 30
            contact.dateAdded = calendar.date(byAdding: .day, value: -daysAgo, to: today) ?? today
            
            // Add some follow-ups
            if i % 3 == 0 {
                let followUpDays = (i % 14) - 7
                contact.nextFollowUp = calendar.date(byAdding: .day, value: followUpDays, to: today)
            }
        }
        
        try? testContext.save()
    }
}