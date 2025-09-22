import SwiftUI
import Charts

struct AnalyticsDashboardView: View {
    @StateObject private var analyticsService: AnalyticsService
    @Environment(\.managedObjectContext) private var viewContext
    
    init(viewContext: NSManagedObjectContext) {
        self._analyticsService = StateObject(wrappedValue: AnalyticsService(viewContext: viewContext))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                if analyticsService.isLoading {
                    loadingView
                } else {
                    analyticsContent
                }
            }
            .navigationTitle("Analytics")
            .refreshable {
                analyticsService.refreshAnalytics()
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Analyzing your networking data...")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var analyticsContent: some View {
        LazyVStack(spacing: 20) {
            // Networking Score Card
            networkingScoreCard
            
            // Key Insights
            insightsSection
            
            // Networking Statistics
            networkingStatsSection
            
            // Relationship Health
            relationshipHealthSection
            
            // Follow-Up Metrics
            followUpMetricsSection
            
            // Weekly Follow-Up Trend
            weeklyTrendChart
            
            // Top Companies
            topCompaniesSection
        }
        .padding()
    }
    
    private var networkingScoreCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Networking Score")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Overall performance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("\(analyticsService.getNetworkingScore())")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(scoreColor)
                    
                    Text(analyticsService.getNetworkingGrade())
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(scoreColor)
                }
            }
            
            // Score breakdown
            VStack(spacing: 8) {
                scoreBreakdownRow(title: "Contact Activity", score: contactActivityScore, maxScore: 25)
                scoreBreakdownRow(title: "Relationship Health", score: relationshipHealthScore, maxScore: 25)
                scoreBreakdownRow(title: "Follow-Up Rate", score: followUpScore, maxScore: 25)
                scoreBreakdownRow(title: "Network Size", score: networkSizeScore, maxScore: 25)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Key Insights")
                .font(.headline)
                .foregroundColor(.primary)
            
            let insights = analyticsService.getInsights()
            if insights.isEmpty {
                Text("Great job! Your networking game is strong. 🎉")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(insights.prefix(3), id: \.self) { insight in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        
                        Text(insight)
                            .font(.body)
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var networkingStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Networking Statistics")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                statCard(
                    title: "Total Contacts",
                    value: "\(analyticsService.networkingStats.totalContacts)",
                    icon: "person.2.fill",
                    color: .blue
                )
                
                statCard(
                    title: "This Week",
                    value: "\(analyticsService.networkingStats.contactsAddedThisWeek)",
                    icon: "calendar.badge.plus",
                    color: .green
                )
                
                statCard(
                    title: "This Month",
                    value: "\(analyticsService.networkingStats.contactsAddedThisMonth)",
                    icon: "calendar",
                    color: .orange
                )
                
                statCard(
                    title: "Weekly Avg",
                    value: String(format: "%.1f", analyticsService.networkingStats.averageContactsPerWeek),
                    icon: "chart.line.uptrend.xyaxis",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var relationshipHealthSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Relationship Health")
                .font(.headline)
                .foregroundColor(.primary)
            
            if analyticsService.networkingStats.totalContacts > 0 {
                // Relationship strength chart
                Chart(relationshipStrengthData, id: \.category) { item in
                    SectorMark(
                        angle: .value("Count", item.count),
                        innerRadius: .ratio(0.5)
                    )
                    .foregroundStyle(by: .value("Strength", item.category))
                    .opacity(0.8)
                }
                .chartForegroundStyleScale([
                    "Strong": .green,
                    "Moderate": .blue,
                    "Weak": .orange,
                    "Dormant": .red
                ])
                .frame(height: 200)
                .chartLegend(position: .bottom)
                
                // Health metrics
                VStack(spacing: 8) {
                    healthMetricRow(
                        title: "Average days since contact",
                        value: String(format: "%.0f days", analyticsService.relationshipHealth.averageDaysSinceLastContact),
                        color: daysSinceContactColor
                    )
                }
                .padding(.top)
            } else {
                Text("Add some contacts to see relationship health metrics!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var followUpMetricsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Follow-Up Performance")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                statCard(
                    title: "Overdue",
                    value: "\(analyticsService.followUpMetrics.overdueFollowUps)",
                    icon: "exclamationmark.triangle.fill",
                    color: analyticsService.followUpMetrics.overdueFollowUps > 0 ? .red : .gray
                )
                
                statCard(
                    title: "Upcoming",
                    value: "\(analyticsService.followUpMetrics.upcomingFollowUps)",
                    icon: "clock.badge.checkmark",
                    color: .blue
                )
                
                statCard(
                    title: "Completion Rate",
                    value: String(format: "%.0f%%", analyticsService.followUpMetrics.followUpCompletionRate * 100),
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                statCard(
                    title: "Avg Response Time",
                    value: String(format: "%.0f days", analyticsService.followUpMetrics.averageFollowUpTime),
                    icon: "timer",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var weeklyTrendChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Follow-Up Trend (8 weeks)")
                .font(.headline)
                .foregroundColor(.primary)
            
            if !analyticsService.followUpMetrics.followUpsByWeek.isEmpty {
                Chart(analyticsService.followUpMetrics.followUpsByWeek, id: \.0) { item in
                    BarMark(
                        x: .value("Week", item.0),
                        y: .value("Follow-ups", item.1)
                    )
                    .foregroundStyle(Color.accentColor.gradient)
                    .cornerRadius(4)
                }
                .frame(height: 150)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartXAxis {
                    AxisMarks(position: .bottom) { value in
                        AxisValueLabel() {
                            if let stringValue = value.as(String.self) {
                                Text(stringValue)
                                    .font(.caption)
                            }
                        }
                    }
                }
            } else {
                Text("No follow-up data available yet.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var topCompaniesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Top Companies")
                .font(.headline)
                .foregroundColor(.primary)
            
            if !analyticsService.networkingStats.mostActiveCompanies.isEmpty {
                VStack(spacing: 12) {
                    ForEach(Array(analyticsService.networkingStats.mostActiveCompanies.enumerated()), id: \.offset) { index, company in
                        HStack {
                            Text("#\(index + 1)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .frame(width: 24)
                            
                            Text(company.0)
                                .font(.body)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Text("\(company.1)")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.accentColor)
                            
                            Text("contact\(company.1 == 1 ? "" : "s")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                        
                        if index < analyticsService.networkingStats.mostActiveCompanies.count - 1 {
                            Divider()
                        }
                    }
                }
            } else {
                Text("Add company information to contacts to see top companies.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Helper Views
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func scoreBreakdownRow(title: String, score: Int, maxScore: Int) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text("\(score)/\(maxScore)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            ProgressView(value: Double(score), total: Double(maxScore))
                .frame(width: 60)
                .tint(scoreColor)
        }
    }
    
    private func healthMetricRow(title: String, value: String, color: Color) -> some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
    
    // MARK: - Computed Properties
    
    private var scoreColor: Color {
        let score = analyticsService.getNetworkingScore()
        switch score {
        case 80...100: return .green
        case 60...79: return .blue
        case 40...59: return .orange
        default: return .red
        }
    }
    
    private var relationshipStrengthData: [(category: String, count: Int)] {
        let health = analyticsService.relationshipHealth
        return [
            ("Strong", health.strongRelationships),
            ("Moderate", health.moderateRelationships),
            ("Weak", health.weakRelationships),
            ("Dormant", health.dormantRelationships)
        ].filter { $0.count > 0 }
    }
    
    private var daysSinceContactColor: Color {
        let days = analyticsService.relationshipHealth.averageDaysSinceLastContact
        switch days {
        case 0..<30: return .green
        case 30..<90: return .blue
        case 90..<180: return .orange
        default: return .red
        }
    }
    
    private var contactActivityScore: Int {
        let stats = analyticsService.networkingStats
        return min((stats.contactsAddedThisWeek * 25) / 3, 25)
    }
    
    private var relationshipHealthScore: Int {
        let stats = analyticsService.networkingStats
        let health = analyticsService.relationshipHealth
        guard stats.totalContacts > 0 else { return 0 }
        
        let healthyRatio = Double(health.strongRelationships + health.moderateRelationships) / Double(stats.totalContacts)
        return Int(healthyRatio * 25)
    }
    
    private var followUpScore: Int {
        let rate = analyticsService.followUpMetrics.followUpCompletionRate
        return Int(rate * 25)
    }
    
    private var networkSizeScore: Int {
        let total = analyticsService.networkingStats.totalContacts
        return min((total * 25) / 50, 25)
    }
}

struct AnalyticsDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsDashboardView(viewContext: PersistenceController.preview.container.viewContext)
    }
}