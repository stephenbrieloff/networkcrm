import XCTest
import CoreData
import UserNotifications
@testable import NetworkCRM

class ServicesTests: XCTestCase {
    
    // MARK: - PersistenceController Tests
    
    func testPersistenceControllerSharedInstance() {
        // Given/When
        let instance1 = PersistenceController.shared
        let instance2 = PersistenceController.shared
        
        // Then
        XCTAssertTrue(instance1 === instance2, "Shared instance should be a singleton")
    }
    
    func testPersistenceControllerInMemory() {
        // Given/When
        let inMemoryController = PersistenceController(inMemory: true)
        let context = inMemoryController.container.viewContext
        
        // Then
        XCTAssertNotNil(inMemoryController.container)
        XCTAssertNotNil(context)
        XCTAssertTrue(context.automaticallyMergesChangesFromParent)
    }
    
    func testPersistenceControllerPreview() {
        // Given/When
        let previewController = PersistenceController.preview
        let context = previewController.container.viewContext
        
        // Then
        XCTAssertNotNil(previewController)
        XCTAssertNotNil(context)
        
        // Verify that preview data exists
        let fetchRequest: NSFetchRequest<Contact> = Contact.fetchRequest()
        do {
            let contacts = try context.fetch(fetchRequest)
            XCTAssertGreaterThan(contacts.count, 0, "Preview should contain sample data")
            
            // Verify the sample contact data
            if let sampleContact = contacts.first {
                XCTAssertEqual(sampleContact.firstName, "John")
                XCTAssertEqual(sampleContact.lastName, "Doe")
                XCTAssertEqual(sampleContact.company, "TechCorp")
                XCTAssertEqual(sampleContact.email, "john.doe@techcorp.com")
                XCTAssertEqual(sampleContact.phone, "(555) 123-4567")
                XCTAssertEqual(sampleContact.metAt, "Tech Conference 2024")
                XCTAssertNotNil(sampleContact.dateAdded)
            }
        } catch {
            XCTFail("Failed to fetch preview data: \\(error)")
        }
    }
    
    func testPersistenceControllerSaveFunction() {
        // Given
        let testController = PersistenceController(inMemory: true)
        let context = testController.container.viewContext
        
        let contact = Contact(context: context)
        contact.id = UUID()
        contact.firstName = "Test"
        contact.lastName = "Save"
        contact.dateAdded = Date()
        
        // When
        XCTAssertNoThrow(testController.save())
        
        // Then
        let fetchRequest: NSFetchRequest<Contact> = Contact.fetchRequest()
        do {
            let savedContacts = try context.fetch(fetchRequest)
            XCTAssertEqual(savedContacts.count, 1)
            XCTAssertEqual(savedContacts.first?.firstName, "Test")
        } catch {
            XCTFail("Failed to fetch saved contact: \\(error)")
        }
    }
    
    func testPersistenceControllerSaveWithNoChanges() {
        // Given
        let testController = PersistenceController(inMemory: true)
        let context = testController.container.viewContext
        
        // When - calling save with no changes
        XCTAssertNoThrow(testController.save())
        
        // Then - should not crash or throw
        XCTAssertFalse(context.hasChanges)
    }
}

// MARK: - NotificationManager Tests
class NotificationManagerTests: XCTestCase {
    var notificationManager: NotificationManager!
    var mockContact: Contact!
    var testPersistenceController: PersistenceController!
    
    override func setUpWithError() throws {
        notificationManager = NotificationManager()
        
        // Create mock contact for testing
        testPersistenceController = PersistenceController(inMemory: true)
        let context = testPersistenceController.container.viewContext
        
        mockContact = Contact(context: context)
        mockContact.id = UUID()
        mockContact.firstName = "Test"
        mockContact.lastName = "Contact"
        mockContact.dateAdded = Date()
        
        try context.save()
    }
    
    override func tearDownWithError() throws {
        notificationManager = nil
        mockContact = nil
        testPersistenceController = nil
    }
    
    func testNotificationManagerSingleton() {
        // Given/When
        let instance1 = NotificationManager.shared
        let instance2 = NotificationManager.shared
        
        // Then
        XCTAssertTrue(instance1 === instance2, "NotificationManager should be a singleton")
    }
    
    func testNotificationManagerInitialization() {
        // Given/When
        let manager = NotificationManager()
        
        // Then
        XCTAssertNotNil(manager)
        XCTAssertFalse(manager.isAuthorized) // Initially false until authorized
    }
    
    func testScheduleFollowUpReminderContent() {
        // Given
        let futureDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        
        // When
        notificationManager.scheduleFollowUpReminder(for: mockContact, at: futureDate)
        
        // Then - We can't easily test the actual scheduling without mocking UNUserNotificationCenter
        // But we can verify the method doesn't crash
        XCTAssertNotNil(mockContact.firstName)
        XCTAssertNotNil(mockContact.lastName)
        XCTAssertNotNil(mockContact.id)
    }
    
    func testCancelFollowUpReminder() {
        // Given
        let futureDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        notificationManager.scheduleFollowUpReminder(for: mockContact, at: futureDate)
        
        // When
        XCTAssertNoThrow(notificationManager.cancelFollowUpReminder(for: mockContact))
        
        // Then - Method should not crash
        XCTAssertNotNil(mockContact.id)
    }
    
    func testCancelAllNotifications() {
        // Given/When
        XCTAssertNoThrow(notificationManager.cancelAllNotifications())
        
        // Then - Method should not crash
        // This calls UNUserNotificationCenter methods which we can't easily verify in unit tests
    }
    
    func testGetPendingNotificationCount() async {
        // Given/When
        let count = await notificationManager.getPendingNotificationCount()
        
        // Then
        XCTAssertGreaterThanOrEqual(count, 0, "Pending notification count should be non-negative")
    }
    
    func testHandleFollowUpNotificationTapWithValidData() {
        // Given
        let expectation = XCTestExpectation(description: "Notification should be posted")
        let testContactId = UUID()
        let userInfo: [AnyHashable: Any] = [
            "contactId": testContactId.uuidString,
            "type": "followup"
        ]
        
        // Set up observer for the notification
        let observer = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("OpenContact"),
            object: nil,
            queue: .main
        ) { notification in
            if let contactId = notification.userInfo?["contactId"] as? UUID {
                XCTAssertEqual(contactId, testContactId)
                expectation.fulfill()
            }
        }
        
        // When - Simulate notification tap
        let content = UNMutableNotificationContent()
        content.userInfo = userInfo
        let request = UNNotificationRequest(identifier: "test", content: content, trigger: nil)
        let notification = UNNotification(request: request, date: Date())
        let response = UNNotificationResponse(
            notification: notification,
            actionIdentifier: UNNotificationDefaultActionIdentifier
        )
        
        notificationManager.userNotificationCenter(
            UNUserNotificationCenter.current(),
            didReceive: response
        ) { }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        NotificationCenter.default.removeObserver(observer)
    }
    
    func testHandleFollowUpNotificationTapWithInvalidData() {
        // Given
        let userInfo: [AnyHashable: Any] = [
            "contactId": "invalid-uuid",
            "type": "followup"
        ]
        
        // When - This should not crash
        let content = UNMutableNotificationContent()
        content.userInfo = userInfo
        let request = UNNotificationRequest(identifier: "test", content: content, trigger: nil)
        let notification = UNNotification(request: request, date: Date())
        let response = UNNotificationResponse(
            notification: notification,
            actionIdentifier: UNNotificationDefaultActionIdentifier
        )
        
        XCTAssertNoThrow(
            notificationManager.userNotificationCenter(
                UNUserNotificationCenter.current(),
                didReceive: response
            ) { }
        )
        
        // Then - Should handle gracefully without crashing
    }
    
    func testWillPresentNotificationInForeground() {
        // Given
        let content = UNMutableNotificationContent()
        content.title = "Test"
        content.body = "Test notification"
        
        let request = UNNotificationRequest(identifier: "test", content: content, trigger: nil)
        let notification = UNNotification(request: request, date: Date())
        
        let expectation = XCTestExpectation(description: "Completion handler should be called")
        
        // When
        notificationManager.userNotificationCenter(
            UNUserNotificationCenter.current(),
            willPresent: notification
        ) { options in
            // Then
            XCTAssertTrue(options.contains(.alert))
            XCTAssertTrue(options.contains(.sound))
            XCTAssertTrue(options.contains(.badge))
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testNotificationExtensionName() {
        // Given/When
        let notificationName = NSNotification.Name.openContact
        
        // Then
        XCTAssertEqual(notificationName.rawValue, "OpenContact")
    }
}

// MARK: - Integration Tests
class ServicesIntegrationTests: XCTestCase {
    var persistenceController: PersistenceController!
    var notificationManager: NotificationManager!
    var testContact: Contact!
    
    override func setUpWithError() throws {
        persistenceController = PersistenceController(inMemory: true)
        notificationManager = NotificationManager()
        
        let context = persistenceController.container.viewContext
        testContact = Contact(context: context)
        testContact.id = UUID()
        testContact.firstName = "Integration"
        testContact.lastName = "Test"
        testContact.dateAdded = Date()
        
        try context.save()
    }
    
    override func tearDownWithError() throws {
        persistenceController = nil
        notificationManager = nil
        testContact = nil
    }
    
    func testContactPersistenceWithNotificationScheduling() {
        // Given
        let followUpDate = Calendar.current.date(byAdding: .hour, value: 24, to: Date())!
        testContact.nextFollowUp = followUpDate
        
        // When - Save contact and schedule notification
        persistenceController.save()
        notificationManager.scheduleFollowUpReminder(for: testContact, at: followUpDate)
        
        // Then - Contact should be saved with follow-up date
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<Contact> = Contact.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "firstName == %@", "Integration")
        
        do {
            let savedContacts = try context.fetch(fetchRequest)
            XCTAssertEqual(savedContacts.count, 1)
            
            let savedContact = savedContacts.first!
            XCTAssertNotNil(savedContact.nextFollowUp)
            XCTAssertEqual(savedContact.firstName, "Integration")
            XCTAssertEqual(savedContact.lastName, "Test")
            
            // Test that notification can be cancelled
            XCTAssertNoThrow(notificationManager.cancelFollowUpReminder(for: savedContact))
            
        } catch {
            XCTFail("Failed to fetch saved contact: \\(error)")
        }
    }
}