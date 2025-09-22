import Foundation
import UserNotifications
import UIKit

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        checkAuthorizationStatus()
    }
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            
            DispatchQueue.main.async {
                self.isAuthorized = granted
            }
            
            return granted
        } catch {
            print("Error requesting notification authorization: \(error)")
            return false
        }
    }
    
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func scheduleFollowUpReminder(for contact: Contact, at date: Date) {
        guard isAuthorized else {
            print("Notifications not authorized")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Follow-Up Reminder"
        content.body = "Time to follow up with \(contact.firstName ?? "") \(contact.lastName ?? "")"
        content.sound = .default
        content.badge = 1
        
        // Add custom data
        content.userInfo = [
            "contactId": contact.id?.uuidString ?? "",
            "contactName": "\(contact.firstName ?? "") \(contact.lastName ?? "")",
            "type": "followup"
        ]
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let identifier = "followup-\(contact.id?.uuidString ?? UUID().uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Follow-up reminder scheduled for \(date)")
            }
        }
    }
    
    func cancelFollowUpReminder(for contact: Contact) {
        let identifier = "followup-\(contact.id?.uuidString ?? UUID().uuidString)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("Cancelled follow-up reminder for \(contact.firstName ?? "") \(contact.lastName ?? "")")
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    func getPendingNotificationCount() async -> Int {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        return requests.count
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    // Called when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is active
        completionHandler([.alert, .sound, .badge])
    }
    
    // Called when user taps notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        // Handle different notification types
        if let type = userInfo["type"] as? String, type == "followup" {
            handleFollowUpNotificationTap(userInfo: userInfo)
        }
        
        completionHandler()
    }
    
    private func handleFollowUpNotificationTap(userInfo: [AnyHashable: Any]) {
        guard let contactId = userInfo["contactId"] as? String,
              let contactUUID = UUID(uuidString: contactId) else {
            return
        }
        
        // Post notification to open specific contact
        NotificationCenter.default.post(
            name: NSNotification.Name("OpenContact"),
            object: nil,
            userInfo: ["contactId": contactUUID]
        )
    }
}

// MARK: - Notification Names
extension NSNotification.Name {
    static let openContact = NSNotification.Name("OpenContact")
}