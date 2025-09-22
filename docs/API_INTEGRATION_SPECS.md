# API Integration Technical Specifications
## Network CRM iOS App - MLP Implementation

### Overview
This document provides detailed technical specifications for all API integrations required for the Network CRM MLP, including authentication flows, data models, error handling, and implementation guidelines.

## 1. Authentication Architecture

### OAuth 2.0 Implementation Strategy
```swift
class OAuthManager {
    enum Provider {
        case zoom, linkedin, google, microsoft, otter, grain
    }
    
    struct OAuthConfig {
        let clientId: String
        let redirectURI: String
        let scopes: [String]
        let authURL: URL
        let tokenURL: URL
        let usesPKCE: Bool
    }
    
    func authenticate(provider: Provider) async throws -> AuthToken
    func refreshToken(for provider: Provider) async throws -> AuthToken
    func revokeToken(for provider: Provider) async throws
}

struct AuthToken {
    let accessToken: String
    let refreshToken: String?
    let expiresAt: Date
    let scopes: [String]
    let tokenType: String
}
```

### API Key Management
```swift
class APIKeyManager {
    private let keychain = Keychain(service: "com.networkcrm.apikeys")
    
    enum APIProvider: String, CaseIterable {
        case openai = "openai_api_key"
        case anthropic = "anthropic_api_key"
        case assemblyai = "assemblyai_api_key"
        case granola = "granola_api_key"
        case crunchbase = "crunchbase_api_key"
    }
    
    func storeKey(_ key: String, for provider: APIProvider) throws
    func retrieveKey(for provider: APIProvider) throws -> String
    func rotateKey(for provider: APIProvider, newKey: String) throws
}
```

## 2. Detailed API Specifications

### Zoom API Implementation

#### Authentication Flow
```swift
class ZoomAPIClient {
    private let config = OAuthConfig(
        clientId: "YOUR_ZOOM_CLIENT_ID",
        redirectURI: "com.networkcrm://zoom-oauth",
        scopes: ["meeting:read", "recording:read", "user:read"],
        authURL: URL(string: "https://zoom.us/oauth/authorize")!,
        tokenURL: URL(string: "https://zoom.us/oauth/token")!,
        usesPKCE: true
    )
    
    func fetchRecordings(for userId: String, from date: Date) async throws -> [ZoomRecording]
    func downloadRecording(recordingId: String) async throws -> Data
    func getRecordingTranscript(recordingId: String) async throws -> String?
}

struct ZoomRecording: Codable {
    let uuid: String
    let id: Int64
    let accountId: String
    let hostId: String
    let topic: String
    let type: Int
    let startTime: Date
    let duration: Int
    let totalSize: Int64
    let recordingCount: Int
    let shareUrl: String?
    let recordingFiles: [ZoomRecordingFile]
    let participant_audio_files: [ZoomParticipantAudioFile]?
}

struct ZoomRecordingFile: Codable {
    let id: String
    let meetingId: String
    let recordingStart: Date
    let recordingEnd: Date
    let fileType: String // "MP4", "M4A", "TIMELINE", "TRANSCRIPT"
    let fileExtension: String
    let fileSize: Int64
    let downloadUrl: String
    let status: String
}
```

#### Webhook Configuration
```swift
class ZoomWebhookHandler {
    enum EventType: String {
        case recordingCompleted = "recording.completed"
        case recordingTranscriptCompleted = "recording.transcript_completed"
    }
    
    func handleWebhook(_ payload: Data) async throws {
        let event = try JSONDecoder().decode(ZoomWebhookEvent.self, from: payload)
        
        switch event.event {
        case .recordingCompleted:
            await processNewRecording(event.payload.object)
        case .recordingTranscriptCompleted:
            await processTranscriptCompletion(event.payload.object)
        }
    }
}
```

### LinkedIn API Implementation

#### Limited API Considerations
```swift
class LinkedInAPIClient {
    // Note: LinkedIn API is highly restricted
    // May require LinkedIn Partnership Program for full access
    
    private let baseURL = "https://api.linkedin.com/v2"
    
    func getCurrentUserProfile() async throws -> LinkedInProfile
    func getConnections() async throws -> [LinkedInConnection] // Very limited
    func sendMessage(to personId: String, message: String) async throws
    
    // Alternative: Web scraping approach (use cautiously)
    func scrapeProfileData(profileURL: String) async throws -> LinkedInProfileData
}

struct LinkedInProfile: Codable {
    let id: String
    let firstName: String
    let lastName: String
    let headline: String?
    let profilePicture: LinkedInProfilePicture?
    let emailAddress: String?
}

// Fallback: Browser automation for LinkedIn data
class LinkedInWebAutomation {
    func extractProfileData(from url: String) async throws -> LinkedInProfileData
    func monitorActivityFeed() async throws -> [LinkedInActivity]
    // Note: This approach has legal and technical risks
}
```

### Meeting Intelligence Processing

#### OpenAI Integration for Meeting Analysis
```swift
class MeetingIntelligenceProcessor {
    private let openAIClient: OpenAIClient
    private let anthropicClient: AnthropicClient
    
    func processTranscript(_ transcript: String, participants: [String]) async throws -> MeetingInsights {
        let prompt = buildAnalysisPrompt(transcript: transcript, participants: participants)
        
        let response = try await openAIClient.chatCompletion(
            model: "gpt-4-turbo",
            messages: [
                .system("You are an expert at analyzing business meetings..."),
                .user(prompt)
            ],
            temperature: 0.3,
            maxTokens: 2000
        )
        
        return try parseInsights(from: response.choices.first?.message.content ?? "")
    }
    
    func extractActionItems(_ transcript: String) async throws -> [ActionItem]
    func analyzeSentiment(_ transcript: String) async throws -> SentimentAnalysis
    func identifyKeyTopics(_ transcript: String) async throws -> [Topic]
}

struct MeetingInsights: Codable {
    let summary: String
    let keyPoints: [String]
    let decisions: [Decision]
    let actionItems: [ActionItem]
    let sentiment: SentimentAnalysis
    let topics: [Topic]
    let participantInsights: [ParticipantInsight]
    let followUpSuggestions: [FollowUpSuggestion]
}

struct ActionItem: Codable {
    let id: UUID
    let description: String
    let assignedTo: String?
    let dueDate: Date?
    let priority: Priority
    let context: String // Quote from meeting
    let status: ActionItemStatus
}
```

## 3. Rate Limiting & Error Handling

### Comprehensive Rate Limiting Strategy
```swift
class RateLimitManager {
    private var buckets: [String: TokenBucket] = [:]
    
    func canMakeRequest(for api: String) -> Bool
    func recordRequest(for api: String)
    func waitForAvailableSlot(for api: String) async
    
    private struct TokenBucket {
        var tokens: Int
        var capacity: Int
        var refillRate: Double
        var lastRefill: Date
    }
}

class APIClient {
    private let rateLimitManager: RateLimitManager
    private let retryPolicy: RetryPolicy
    
    func makeRequest<T: Codable>(
        to endpoint: String,
        method: HTTPMethod,
        parameters: [String: Any]? = nil,
        retries: Int = 3
    ) async throws -> T {
        
        // Wait for rate limit availability
        await rateLimitManager.waitForAvailableSlot(for: endpoint)
        
        do {
            let response = try await performRequest(endpoint, method, parameters)
            rateLimitManager.recordRequest(for: endpoint)
            return try JSONDecoder().decode(T.self, from: response)
            
        } catch let error as APIError {
            switch error {
            case .rateLimited(let resetTime):
                if retries > 0 {
                    await Task.sleep(nanoseconds: UInt64(resetTime * 1_000_000_000))
                    return try await makeRequest(to: endpoint, method: method, parameters: parameters, retries: retries - 1)
                }
                throw error
                
            case .temporaryFailure:
                if retries > 0 {
                    let delay = retryPolicy.calculateDelay(attempt: 3 - retries)
                    await Task.sleep(nanoseconds: delay)
                    return try await makeRequest(to: endpoint, method: method, parameters: parameters, retries: retries - 1)
                }
                throw error
                
            default:
                throw error
            }
        }
    }
}

enum APIError: Error {
    case rateLimited(resetTime: TimeInterval)
    case temporaryFailure
    case authenticationFailed
    case invalidResponse
    case quotaExceeded
    case serviceUnavailable
}
```

## 4. Data Synchronization Strategy

### Efficient Data Sync Architecture
```swift
class DataSyncManager {
    private let coreDataStack: CoreDataStack
    private let apiClients: [String: APIClient]
    
    func syncMeetingRecordings() async throws {
        let lastSyncDate = getUserDefaults().lastMeetingSyncDate ?? Date().addingTimeInterval(-30 * 24 * 3600)
        
        // Parallel sync from multiple sources
        async let zoomRecordings = syncZoomRecordings(since: lastSyncDate)
        async let otterRecordings = syncOtterRecordings(since: lastSyncDate)
        async let granolaRecordings = syncGranolaRecordings(since: lastSyncDate)
        
        let allRecordings = try await [zoomRecordings, otterRecordings, granolaRecordings].flatMap { $0 }
        
        // Process recordings for intelligence
        for recording in allRecordings {
            await processRecordingIntelligence(recording)
        }
        
        getUserDefaults().lastMeetingSyncDate = Date()
    }
    
    func syncContactIntelligence() async throws {
        // Sync LinkedIn updates
        // Sync calendar events
        // Sync email threads
        // Update relationship scores
    }
}

class IncrementalSyncManager {
    func syncChanges<T: SyncableEntity>(
        entityType: T.Type,
        since lastSync: Date,
        batchSize: Int = 100
    ) async throws {
        
        var offset = 0
        var hasMore = true
        
        while hasMore {
            let batch = try await fetchBatch(
                entityType: entityType,
                since: lastSync,
                offset: offset,
                limit: batchSize
            )
            
            if batch.isEmpty {
                hasMore = false
            } else {
                try await processBatch(batch)
                offset += batchSize
            }
        }
    }
}
```

## 5. Offline Support & Caching

### Intelligent Caching Strategy
```swift
class APICache {
    private let cache = NSCache<NSString, CacheEntry>()
    private let diskCache: DiskCache
    
    func cache<T: Codable>(_ object: T, for key: String, ttl: TimeInterval) {
        let entry = CacheEntry(object: object, expiresAt: Date().addingTimeInterval(ttl))
        cache.setObject(entry, forKey: key as NSString)
        
        // Also cache to disk for offline access
        diskCache.store(object, for: key)
    }
    
    func retrieve<T: Codable>(type: T.Type, for key: String) -> T? {
        if let entry = cache.object(forKey: key as NSString),
           entry.expiresAt > Date() {
            return entry.object as? T
        }
        
        // Fallback to disk cache for offline support
        return diskCache.retrieve(type: type, for: key)
    }
}

class OfflineQueueManager {
    private var pendingRequests: [PendingAPIRequest] = []
    
    func queueRequest(_ request: PendingAPIRequest) {
        pendingRequests.append(request)
        persistQueue()
    }
    
    func processPendingRequests() async {
        guard NetworkMonitor.shared.isConnected else { return }
        
        for request in pendingRequests {
            do {
                try await processRequest(request)
                removePendingRequest(request)
            } catch {
                // Keep in queue for later retry
                request.retryCount += 1
                if request.retryCount >= 5 {
                    removePendingRequest(request)
                }
            }
        }
    }
}
```

## 6. Cost Optimization Strategies

### API Cost Management
```swift
class APICostOptimizer {
    private var dailyUsage: [String: Int] = [:]
    private var monthlyCosts: [String: Decimal] = [:]
    
    func shouldMakeRequest(api: String, estimatedCost: Decimal) -> Bool {
        let currentMonthlyCost = monthlyCosts[api] ?? 0
        let budgetLimit = getBudgetLimit(for: api)
        
        return (currentMonthlyCost + estimatedCost) <= budgetLimit
    }
    
    func optimizeAIRequests() -> AIOptimizationStrategy {
        // Use cached responses when possible
        // Batch requests to reduce API calls
        // Use cheaper models for simple tasks
        // Implement request deduplication
        
        return .efficient
    }
    
    private func getBudgetLimit(for api: String) -> Decimal {
        switch api {
        case "openai": return 100.00 // $100/month
        case "anthropic": return 50.00
        case "assemblyai": return 30.00
        default: return 0
        }
    }
}

enum AIOptimizationStrategy {
    case aggressive // Use cheapest options
    case balanced // Balance cost and quality
    case premium // Best quality regardless of cost
    case efficient // Smart caching and batching
}
```

## 7. Testing Strategy

### API Integration Testing
```swift
class APIIntegrationTests: XCTestCase {
    func testZoomAPIAuthentication() async throws {
        let client = ZoomAPIClient()
        
        // Mock authentication flow
        let mockToken = AuthToken(
            accessToken: "test_token",
            refreshToken: "refresh_token",
            expiresAt: Date().addingTimeInterval(3600),
            scopes: ["meeting:read"],
            tokenType: "Bearer"
        )
        
        // Test token storage and retrieval
        try await client.authenticate()
        XCTAssertNotNil(client.currentToken)
    }
    
    func testMeetingIntelligenceProcessing() async throws {
        let processor = MeetingIntelligenceProcessor()
        
        let sampleTranscript = """
        John: Thanks everyone for joining. Let's discuss the Q4 roadmap.
        Sarah: I think we should prioritize the mobile app features.
        Mike: Agreed. I can take ownership of the iOS implementation.
        John: Great. Sarah, can you send the requirements by Friday?
        Sarah: Absolutely, I'll get that to you by end of week.
        """
        
        let insights = try await processor.processTranscript(
            sampleTranscript,
            participants: ["John", "Sarah", "Mike"]
        )
        
        XCTAssertFalse(insights.actionItems.isEmpty)
        XCTAssert(insights.actionItems.contains { $0.assignedTo == "Sarah" })
    }
}

class MockAPIClient: APIClient {
    var responses: [String: Data] = [:]
    
    override func makeRequest<T: Codable>(
        to endpoint: String,
        method: HTTPMethod,
        parameters: [String: Any]?
    ) async throws -> T {
        
        guard let responseData = responses[endpoint] else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode(T.self, from: responseData)
    }
}
```

## 8. Monitoring & Analytics

### Comprehensive API Monitoring
```swift
class APIMonitor {
    private let analytics = Analytics.shared
    
    func trackAPICall(
        api: String,
        endpoint: String,
        duration: TimeInterval,
        success: Bool,
        error: Error?
    ) {
        analytics.track("api_call", parameters: [
            "api": api,
            "endpoint": endpoint,
            "duration_ms": Int(duration * 1000),
            "success": success,
            "error_type": error?.localizedDescription ?? "none"
        ])
        
        // Send to monitoring service
        MonitoringService.shared.recordMetric(
            name: "api_response_time",
            value: duration,
            tags: ["api": api, "endpoint": endpoint]
        )
    }
    
    func trackAPIQuotaUsage(api: String, used: Int, limit: Int) {
        analytics.track("api_quota_usage", parameters: [
            "api": api,
            "used": used,
            "limit": limit,
            "usage_percentage": (Double(used) / Double(limit)) * 100
        ])
    }
}
```

## 9. Implementation Checklist

### Phase 1: Core API Setup (Week 1-2)
- [ ] OAuth 2.0 authentication framework
- [ ] Secure token storage in Keychain
- [ ] Basic rate limiting implementation
- [ ] Zoom API integration for recordings
- [ ] OpenAI API for basic meeting analysis

### Phase 2: Extended Integrations (Week 3-4)
- [ ] Granola API for enhanced summaries
- [ ] Google Calendar integration
- [ ] Gmail API for email analysis
- [ ] LinkedIn basic profile access

### Phase 3: Intelligence Layer (Week 5-6)
- [ ] Meeting transcript processing
- [ ] Action item extraction
- [ ] Sentiment analysis implementation
- [ ] Relationship scoring algorithms

### Phase 4: Optimization & Resilience (Week 7-8)
- [ ] Advanced error handling
- [ ] Offline queue management
- [ ] Cost optimization strategies
- [ ] Comprehensive monitoring

This comprehensive API integration specification ensures robust, scalable, and cost-effective implementation of all MLP features while maintaining high reliability and user experience.