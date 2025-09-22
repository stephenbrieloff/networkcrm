import Foundation
import SwiftUI

class MessageTemplateService: ObservableObject {
    @Published var templates: [MessageTemplate] = []
    
    init() {
        loadDefaultTemplates()
    }
    
    struct MessageTemplate: Identifiable, Codable {
        let id = UUID()
        let title: String
        let category: TemplateCategory
        let template: String
        let variables: [String] // Variables that can be replaced like [firstName], [company]
        let isDefault: Bool
        let dateCreated: Date
        
        var formattedTemplate: String {
            // Show variables in a readable format
            return template
                .replacingOccurrences(of: "[firstName]", with: "{{First Name}}")
                .replacingOccurrences(of: "[lastName]", with: "{{Last Name}}")
                .replacingOccurrences(of: "[company]", with: "{{Company}}")
                .replacingOccurrences(of: "[metAt]", with: "{{Where Met}}")
                .replacingOccurrences(of: "[eventDate]", with: "{{Event Date}}")
        }
    }
    
    enum TemplateCategory: String, CaseIterable, Codable {
        case postMeeting = "Post-Meeting"
        case checkIn = "Check-In"
        case introduction = "Introduction"
        case thankYou = "Thank You"
        case followUp = "Follow-Up"
        case reconnection = "Reconnection"
        
        var icon: String {
            switch self {
            case .postMeeting: return "person.2.badge.gearshape"
            case .checkIn: return "checkmark.bubble"
            case .introduction: return "hand.wave"
            case .thankYou: return "heart.text.square"
            case .followUp: return "arrow.right.circle"
            case .reconnection: return "arrow.counterclockwise.circle"
            }
        }
        
        var color: Color {
            switch self {
            case .postMeeting: return .blue
            case .checkIn: return .green
            case .introduction: return .purple
            case .thankYou: return .pink
            case .followUp: return .orange
            case .reconnection: return .indigo
            }
        }
    }
    
    // MARK: - Template Management
    
    func addCustomTemplate(_ template: MessageTemplate) {
        templates.append(template)
        saveTemplates()
    }
    
    func removeTemplate(_ template: MessageTemplate) {
        templates.removeAll { $0.id == template.id }
        saveTemplates()
    }
    
    func updateTemplate(_ template: MessageTemplate) {
        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            templates[index] = template
            saveTemplates()
        }
    }
    
    // MARK: - Message Generation
    
    func generateMessage(from template: MessageTemplate, for contact: Contact, customVariables: [String: String] = [:]) -> String {
        var message = template.template
        
        // Replace contact variables
        if let firstName = contact.firstName {
            message = message.replacingOccurrences(of: "[firstName]", with: firstName)
        }
        
        if let lastName = contact.lastName {
            message = message.replacingOccurrences(of: "[lastName]", with: lastName)
        }
        
        if let company = contact.company {
            message = message.replacingOccurrences(of: "[company]", with: company)
        }
        
        if let metAt = contact.metAt {
            message = message.replacingOccurrences(of: "[metAt]", with: metAt)
        }
        
        // Replace custom variables
        for (key, value) in customVariables {
            message = message.replacingOccurrences(of: "[\(key)]", with: value)
        }
        
        // Replace date variables
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let today = formatter.string(from: Date())
        message = message.replacingOccurrences(of: "[today]", with: today)
        
        return message
    }
    
    func getTemplatesForCategory(_ category: TemplateCategory) -> [MessageTemplate] {
        return templates.filter { $0.category == category }
    }
    
    func getRecentlyUsedTemplates(limit: Int = 5) -> [MessageTemplate] {
        // In a real implementation, you'd track usage
        // For now, return the first few templates
        return Array(templates.prefix(limit))
    }
    
    // MARK: - Data Persistence
    
    private func saveTemplates() {
        if let data = try? JSONEncoder().encode(templates) {
            UserDefaults.standard.set(data, forKey: "MessageTemplates")
        }
    }
    
    private func loadTemplates() {
        if let data = UserDefaults.standard.data(forKey: "MessageTemplates"),
           let savedTemplates = try? JSONDecoder().decode([MessageTemplate].self, from: data) {
            templates = savedTemplates
        }
    }
    
    private func loadDefaultTemplates() {
        // Load saved templates first
        loadTemplates()
        
        // Add default templates if none exist
        if templates.isEmpty {
            templates = createDefaultTemplates()
            saveTemplates()
        }
    }
    
    private func createDefaultTemplates() -> [MessageTemplate] {
        return [
            // Post-Meeting Templates
            MessageTemplate(
                title: "Professional Follow-Up",
                category: .postMeeting,
                template: "Hi [firstName],\n\nIt was great meeting you at [metAt]. I really enjoyed our conversation about [topic]. \n\nAs discussed, I'd love to continue our conversation. Would you be available for a quick call next week?\n\nBest regards,\n[senderName]",
                variables: ["firstName", "metAt", "topic", "senderName"],
                isDefault: true,
                dateCreated: Date()
            ),
            
            MessageTemplate(
                title: "Casual Follow-Up",
                category: .postMeeting,
                template: "Hey [firstName]!\n\nGreat meeting you at [metAt] today. Hope you enjoyed the [event] as much as I did!\n\nWould love to grab coffee sometime and chat more about [topic].\n\nCheers,\n[senderName]",
                variables: ["firstName", "metAt", "event", "topic", "senderName"],
                isDefault: true,
                dateCreated: Date()
            ),
            
            // Check-In Templates
            MessageTemplate(
                title: "Quarterly Check-In",
                category: .checkIn,
                template: "Hi [firstName],\n\nHope you're doing well! I was thinking about our conversation at [metAt] and wanted to check in.\n\nHow are things going with [project] at [company]? I'd love to hear about any updates.\n\nBest,\n[senderName]",
                variables: ["firstName", "metAt", "project", "company", "senderName"],
                isDefault: true,
                dateCreated: Date()
            ),
            
            MessageTemplate(
                title: "Holiday Check-In",
                category: .checkIn,
                template: "Hi [firstName],\n\nHappy [holiday]! Hope you're having a wonderful time with family and friends.\n\nI was just thinking about our chat at [metAt] and wanted to reach out. Hope 2024 is treating you well at [company]!\n\nWarm regards,\n[senderName]",
                variables: ["firstName", "holiday", "metAt", "company", "senderName"],
                isDefault: true,
                dateCreated: Date()
            ),
            
            // Introduction Templates
            MessageTemplate(
                title: "Mutual Connection Introduction",
                category: .introduction,
                template: "Hi [firstName],\n\n[mutualConnection] suggested I reach out to you. I'm [senderTitle] at [senderCompany] and [mutualConnection] thought we should connect given our mutual interest in [topic].\n\nWould you be open to a brief call to chat?\n\nBest,\n[senderName]",
                variables: ["firstName", "mutualConnection", "senderTitle", "senderCompany", "topic", "senderName"],
                isDefault: true,
                dateCreated: Date()
            ),
            
            // Thank You Templates
            MessageTemplate(
                title: "Professional Thank You",
                category: .thankYou,
                template: "Dear [firstName],\n\nThank you so much for taking the time to [action] today. Your insights on [topic] were incredibly valuable.\n\nI really appreciate your [helpType] and look forward to staying in touch.\n\nSincerely,\n[senderName]",
                variables: ["firstName", "action", "topic", "helpType", "senderName"],
                isDefault: true,
                dateCreated: Date()
            ),
            
            // Follow-Up Templates
            MessageTemplate(
                title: "Resource Sharing",
                category: .followUp,
                template: "Hi [firstName],\n\nFollowing up on our conversation at [metAt], I wanted to share [resource] that I mentioned.\n\n[resourceLink]\n\nI think you'll find it useful for [application]. Let me know what you think!\n\nBest,\n[senderName]",
                variables: ["firstName", "metAt", "resource", "resourceLink", "application", "senderName"],
                isDefault: true,
                dateCreated: Date()
            ),
            
            // Reconnection Templates
            MessageTemplate(
                title: "Long-Time Reconnection",
                category: .reconnection,
                template: "Hi [firstName],\n\nIt's been a while since we connected at [metAt]! I hope you're doing well and that things are going great at [company].\n\nI'd love to catch up and hear what you've been working on. Are you free for a quick coffee chat in the next couple of weeks?\n\nLooking forward to reconnecting,\n[senderName]",
                variables: ["firstName", "metAt", "company", "senderName"],
                isDefault: true,
                dateCreated: Date()
            )
        ]
    }
}

// MARK: - Template Suggestions
extension MessageTemplateService {
    func suggestTemplate(for contact: Contact, context: MessageContext) -> MessageTemplate? {
        let daysSinceAdded = Calendar.current.dateComponents([.day], from: contact.dateAdded ?? Date(), to: Date()).day ?? 0
        let daysSinceLastContact = contact.lastContact != nil ? 
            Calendar.current.dateComponents([.day], from: contact.lastContact!, to: Date()).day ?? 0 : daysSinceAdded
        
        // Suggest based on time since last contact
        if daysSinceAdded <= 3 {
            // Recently met - suggest post-meeting
            return getTemplatesForCategory(.postMeeting).first
        } else if daysSinceLastContact > 90 {
            // Long time no contact - suggest reconnection
            return getTemplatesForCategory(.reconnection).first
        } else if daysSinceLastContact > 30 {
            // Monthly check-in
            return getTemplatesForCategory(.checkIn).first
        } else {
            // General follow-up
            return getTemplatesForCategory(.followUp).first
        }
    }
    
    enum MessageContext {
        case postMeeting
        case regularCheckIn
        case longTimeNoContact
        case thankYou
        case introduction
        case resourceShare
    }
}
