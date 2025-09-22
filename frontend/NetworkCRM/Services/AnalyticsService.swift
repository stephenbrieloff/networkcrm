import Foundation
import CoreData
import Combine

class AnalyticsService: ObservableObject {
    private let viewContext: NSManagedObjectContext
    
    @Published var networkingStats = NetworkingStats()
    @Published var relationshipHealth = RelationshipHealthData()
    @Published var followUpMetrics = FollowUpMetrics()
    @Published var isLoading = false
    
    struct NetworkingStats {
        var totalContacts: Int = 0
        var contactsAddedThisWeek: Int = 0
        var contactsAddedThisMonth: Int = 0
        var averageContactsPerWeek: Double = 0
        var mostActiveCompanies: [(String, Int)] = []
        var contactsWithEmail: Int = 0
        var contactsWithPhone: Int = 0
        var contactsWithBothEmailAndPhone: Int = 0
    }
    
    struct RelationshipHealthData {
        var strongRelationships: Int = 0      // Contacted within 30 days
        var moderateRelationships: Int = 0    // Contacted 30-90 days ago
        var weakRelationships: Int = 0        // Contacted 90+ days ago or never
        var dormantRelationships: Int = 0     // No contact in 6+ months
        var averageDaysSinceLastContact: Double = 0
        var relationshipStrengthDistribution: [RelationshipStrength: Int] = [:]
    }
    
    struct FollowUpMetrics {
        var totalRemindersSet: Int = 0
        var overdueFollowUps: Int = 0
        var upcomingFollowUps: Int = 0        // Next 7 days
        var completedFollowUps: Int = 0       // Based on lastContact updates
        var averageFollowUpTime: Double = 0   // Days between adding contact and setting reminder
        var followUpCompletionRate: Double = 0
        var followUpsByWeek: [(String, Int)] = []
    }
    
    enum RelationshipStrength {
        case strong, moderate, weak, dormant
        
        var description: String {
            switch self {
            case .strong: return "Strong"
            case .moderate: return "Moderate"
            case .weak: return "Weak"
            case .dormant: return "Dormant"
            }
        }
        
        var color: String {
            switch self {
            case .strong: return "green"
            case .moderate: return "blue"
            case .weak: return "orange"
            case .dormant: return "red"
            }
        }
    }
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        refreshAnalytics()
    }
    
    func refreshAnalytics() {
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let stats = self.calculateNetworkingStats()
            let health = self.calculateRelationshipHealth()
            let followUp = self.calculateFollowUpMetrics()
            
            DispatchQueue.main.async {
                self.networkingStats = stats
                self.relationshipHealth = health
                self.followUpMetrics = followUp
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Networking Stats Calculation
    
    private func calculateNetworkingStats() -> NetworkingStats {
        let request: NSFetchRequest<Contact> = Contact.fetchRequest()
        
        guard let contacts = try? viewContext.fetch(request) else {
            return NetworkingStats()
        }
        
        var stats = NetworkingStats()
        stats.totalContacts = contacts.count
        
        let calendar = Calendar.current
        let now = Date()
        
        // Calculate date ranges
        let oneWeekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
        let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: now) ?? now
        
        // Calculate contact metrics
        stats.contactsAddedThisWeek = contacts.filter { contact in
            guard let dateAdded = contact.dateAdded else { return false }
            return dateAdded >= oneWeekAgo
        }.count
        
        stats.contactsAddedThisMonth = contacts.filter { contact in
            guard let dateAdded = contact.dateAdded else { return false }
            return dateAdded >= oneMonthAgo
        }.count
        
        // Calculate average contacts per week over the last 3 months
        let contactsLast3Months = contacts.filter { contact in
            guard let dateAdded = contact.dateAdded else { return false }
            return dateAdded >= threeMonthsAgo
        }.count
        stats.averageContactsPerWeek = Double(contactsLast3Months) / 12.0 // ~12 weeks in 3 months
        
        // Contact information completeness
        stats.contactsWithEmail = contacts.filter { !($0.email?.isEmpty ?? true) }.count
        stats.contactsWithPhone = contacts.filter { !($0.phone?.isEmpty ?? true) }.count
        stats.contactsWithBothEmailAndPhone = contacts.filter { 
            !($0.email?.isEmpty ?? true) && !($0.phone?.isEmpty ?? true) 
        }.count
        
        // Most active companies
        var companyCount: [String: Int] = [:]
        contacts.forEach { contact in
            if let company = contact.company, !company.isEmpty {
                companyCount[company, default: 0] += 1
            }
        }
        
        stats.mostActiveCompanies = companyCount
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map { ($0.key, $0.value) }
        
        return stats
    }
    
    // MARK: - Relationship Health Calculation
    
    private func calculateRelationshipHealth() -> RelationshipHealthData {
        let request: NSFetchRequest<Contact> = Contact.fetchRequest()
        
        guard let contacts = try? viewContext.fetch(request) else {
            return RelationshipHealthData()
        }
        
        var health = RelationshipHealthData()
        let calendar = Calendar.current
        let now = Date()
        
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        let ninetyDaysAgo = calendar.date(byAdding: .day, value: -90, to: now) ?? now
        let sixMonthsAgo = calendar.date(byAdding: .month, value: -6, to: now) ?? now
        
        var totalDaysSinceLastContact = 0
        var contactsWithLastContact = 0
        var strengthDistribution: [RelationshipStrength: Int] = [:]
        
        for contact in contacts {
            let strength = calculateRelationshipStrength(for: contact, 
                                                       thirtyDaysAgo: thirtyDaysAgo,
                                                       ninetyDaysAgo: ninetyDaysAgo,
                                                       sixMonthsAgo: sixMonthsAgo)
            
            strengthDistribution[strength, default: 0] += 1
            
            switch strength {
            case .strong:
                health.strongRelationships += 1
            case .moderate:
                health.moderateRelationships += 1
            case .weak:
                health.weakRelationships += 1
            case .dormant:
                health.dormantRelationships += 1
            }
            
            // Calculate average days since last contact
            if let lastContact = contact.lastContact {
                let daysSince = calendar.dateComponents([.day], from: lastContact, to: now).day ?? 0
                totalDaysSinceLastContact += daysSince
                contactsWithLastContact += 1
            }
        }
        
        health.relationshipStrengthDistribution = strengthDistribution
        
        if contactsWithLastContact > 0 {
            health.averageDaysSinceLastContact = Double(totalDaysSinceLastContact) / Double(contactsWithLastContact)
        }
        
        return health
    }
    
    private func calculateRelationshipStrength(for contact: Contact, 
                                             thirtyDaysAgo: Date,
                                             ninetyDaysAgo: Date,
                                             sixMonthsAgo: Date) -> RelationshipStrength {
        guard let lastContact = contact.lastContact else {
            // No contact recorded - check how long since added
            if let dateAdded = contact.dateAdded {
                return dateAdded < sixMonthsAgo ? .dormant : .weak
            }
            return .weak
        }
        
        if lastContact >= thirtyDaysAgo {
            return .strong
        } else if lastContact >= ninetyDaysAgo {
            return .moderate
        } else if lastContact >= sixMonthsAgo {
            return .weak
        } else {
            return .dormant
        }
    }
    
    // MARK: - Follow-Up Metrics Calculation
    
    private func calculateFollowUpMetrics() -> FollowUpMetrics {
        let request: NSFetchRequest<Contact> = Contact.fetchRequest()
        
        guard let contacts = try? viewContext.fetch(request) else {
            return FollowUpMetrics()
        }
        
        var metrics = FollowUpMetrics()
        let calendar = Calendar.current
        let now = Date()
        let sevenDaysFromNow = calendar.date(byAdding: .day, value: 7, to: now) ?? now
        
        var totalFollowUpDays = 0
        var followUpCount = 0
        
        for contact in contacts {
            // Count total reminders set
            if contact.nextFollowUp != nil {
                metrics.totalRemindersSet += 1
                
                // Calculate follow-up timing
                if let dateAdded = contact.dateAdded, let nextFollowUp = contact.nextFollowUp {
                    let daysBetween = calendar.dateComponents([.day], from: dateAdded, to: nextFollowUp).day ?? 0
                    totalFollowUpDays += daysBetween
                    followUpCount += 1
                }
                
                // Check if overdue or upcoming
                if let nextFollowUp = contact.nextFollowUp {
                    if nextFollowUp < now {
                        metrics.overdueFollowUps += 1
                    } else if nextFollowUp <= sevenDaysFromNow {
                        metrics.upcomingFollowUps += 1
                    }
                }
            }
            
            // Estimate completed follow-ups (contacts with both reminder set and recent lastContact)
            if let nextFollowUp = contact.nextFollowUp, 
               let lastContact = contact.lastContact,
               lastContact > nextFollowUp {
                metrics.completedFollowUps += 1
            }
        }
        
        // Calculate averages
        if followUpCount > 0 {
            metrics.averageFollowUpTime = Double(totalFollowUpDays) / Double(followUpCount)
        }
        
        if metrics.totalRemindersSet > 0 {
            metrics.followUpCompletionRate = Double(metrics.completedFollowUps) / Double(metrics.totalRemindersSet)
        }
        
        // Calculate follow-ups by week (last 8 weeks)
        metrics.followUpsByWeek = calculateFollowUpsByWeek(contacts: contacts)
        
        return metrics
    }
    
    private func calculateFollowUpsByWeek(contacts: [Contact]) -> [(String, Int)] {
        let calendar = Calendar.current
        let now = Date()
        var weeklyData: [(String, Int)] = []
        
        // Get last 8 weeks
        for weekOffset in (0..<8).reversed() {
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: now),
                  let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) else {
                continue
            }
            
            let followUpsThisWeek = contacts.filter { contact in
                guard let nextFollowUp = contact.nextFollowUp else { return false }
                return nextFollowUp >= weekStart && nextFollowUp < weekEnd
            }.count
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            let weekLabel = formatter.string(from: weekStart)
            
            weeklyData.append((weekLabel, followUpsThisWeek))
        }
        
        return weeklyData
    }
}

// MARK: - Analytics Helpers
extension AnalyticsService {
    func getNetworkingScore() -> Int {
        let stats = networkingStats
        let health = relationshipHealth
        let followUp = followUpMetrics
        
        var score = 0
        
        // Contact quantity score (0-25 points)
        if stats.totalContacts >= 50 {
            score += 25
        } else {
            score += (stats.totalContacts * 25) / 50
        }
        
        // Contact activity score (0-25 points)
        if stats.contactsAddedThisWeek >= 3 {
            score += 25
        } else {
            score += (stats.contactsAddedThisWeek * 25) / 3
        }
        
        // Relationship health score (0-25 points)
        let totalContacts = stats.totalContacts
        if totalContacts > 0 {
            let healthyRatio = Double(health.strongRelationships + health.moderateRelationships) / Double(totalContacts)
            score += Int(healthyRatio * 25)
        }
        
        // Follow-up consistency score (0-25 points)
        if followUp.followUpCompletionRate >= 0.8 {
            score += 25
        } else {
            score += Int(followUp.followUpCompletionRate * 25)
        }
        
        return min(score, 100) // Cap at 100
    }
    
    func getNetworkingGrade() -> String {
        let score = getNetworkingScore()
        
        switch score {
        case 90...100: return "A+"
        case 80...89: return "A"
        case 70...79: return "B+"
        case 60...69: return "B"
        case 50...59: return "C+"
        case 40...49: return "C"
        case 30...39: return "D+"
        case 20...29: return "D"
        default: return "F"
        }
    }
    
    func getInsights() -> [String] {
        var insights: [String] = []
        
        let stats = networkingStats
        let health = relationshipHealth
        let followUp = followUpMetrics
        
        // Contact insights
        if stats.contactsAddedThisWeek == 0 {
            insights.append("You haven't added any contacts this week. Try to meet one new person!")
        } else if stats.contactsAddedThisWeek >= 5 {
            insights.append("Great networking week! You added \(stats.contactsAddedThisWeek) contacts.")
        }
        
        // Relationship health insights
        let totalContacts = stats.totalContacts
        if totalContacts > 0 {
            let dormantRatio = Double(health.dormantRelationships) / Double(totalContacts)
            if dormantRatio > 0.3 {
                insights.append("\(Int(dormantRatio * 100))% of your relationships are dormant. Consider reaching out!")
            }
        }
        
        // Follow-up insights
        if followUp.overdueFollowUps > 0 {
            insights.append("You have \(followUp.overdueFollowUps) overdue follow-ups. Time to reconnect!")
        }
        
        if followUp.upcomingFollowUps > 0 {
            insights.append("\(followUp.upcomingFollowUps) follow-ups coming up this week. Stay on track!")
        }
        
        // Contact completeness insights
        let incompleteContacts = totalContacts - stats.contactsWithBothEmailAndPhone
        if incompleteContacts > totalContacts / 2 {
            insights.append("Many contacts are missing email or phone. Complete profiles for better networking!")
        }
        
        return insights
    }
}