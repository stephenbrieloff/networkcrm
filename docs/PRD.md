# Product Requirements Document: Network CRM iOS App

## Project Overview

**Project Name:** Network CRM iOS App  
**Version:** 1.0  
**Date:** September 2025  
**Status:** Draft  
**Platform:** iOS Native App

## Vision Statement

Create the fastest, most frictionless iOS app that transforms networking-avoiders into networking champions by making relationship management so simple that it becomes effortless and habitual.

## Core Philosophy: "5-Second Rule"

Every core action in the app must be completable in 5 seconds or less. If someone who has never prioritized networking can't use this app intuitively and immediately, we've failed.

## Problem Statement

**Target Problem:** Professionals who KNOW networking is important but consistently fail to do it because:
- It feels overwhelming and time-consuming
- They don't know what to say or when to reach out
- They forget about people immediately after meeting them
- Existing tools are too complex and require too much setup
- They lack a simple system to track who they've met

**Core Insight:** The biggest barrier isn't capability—it's friction. Remove all friction, and networking becomes automatic.

## Target Users

**Primary User Persona: "The Reluctant Networker"**
- Knows networking is important but avoids it
- Gets anxious about follow-up conversations
- Meets people but never stays in touch
- Wants to be better at relationships but doesn't know how to start
- Values efficiency and simplicity above all else

**Secondary Personas:**
- Busy professionals who need dead-simple tools
- Introverts who find networking draining
- People re-entering the workforce who need to rebuild networks

## Core Design Principles

### 1. Instant Capture
- Add a contact in under 5 seconds
- Use camera to scan business cards instantly
- Voice notes for immediate thoughts
- One-tap import from recent contacts/meetings

### 2. Zero Configuration
- Works perfectly out of the box
- No setup wizards or complicated onboarding
- Smart defaults for everything
- Learn user preferences automatically

### 3. Proactive Intelligence
- App suggests when to follow up (don't make users think)
- Pre-written message templates that feel personal
- Automatic reminders based on context
- Smart notifications that actually help

### 4. Native iOS Excellence
- Feels like it belongs on iOS
- Uses platform conventions users already know
- Leverages iOS features (Siri, Shortcuts, Widgets)
- Optimized for one-handed use

## Core Features (MVP)

### 1. Lightning-Fast Contact Addition
**5-Second Goal: Add someone you just met**

- **Scan Business Card:** Point camera, auto-extract info, tap save
- **Quick Add:** Name + Company in two taps, everything else is optional
- **From Recent:** Import from recent calls/messages with one tap
- **Voice Memo:** Say their name and key details while walking away

### 2. Effortless Follow-Up Reminders
**5-Second Goal: Set a follow-up reminder**

- **Smart Defaults:** App suggests timing based on context (1 day for urgent, 1 week for general, 1 month for casual)
- **One-Tap Scheduling:** "Remind me to follow up" button on every contact
- **Context-Aware:** Knows if it's a new connection vs. existing relationship
- **Natural Language:** "Remind me next week" works perfectly

### 3. Instant Follow-Up Actions
**5-Second Goal: Actually follow up when reminded**

- **Pre-Written Templates:** "Hi [Name], great meeting you at [Event]. Would love to continue our conversation about [Topic]."
- **One-Tap Send:** Choose template, customize if needed, send via preferred method
- **Multiple Channels:** Email, text, LinkedIn message, phone call
- **Smart Suggestions:** App recommends what to say based on previous conversations

### 4. Minimal Note-Taking
**5-Second Goal: Remember important details**

- **Voice Notes:** Speak your thoughts while they're fresh
- **Quick Tags:** One-tap tags like "follow up," "potential client," "mentor"
- **Photo Notes:** Take a quick photo to remember something visual
- **Context Clues:** Where you met, what you talked about, mutual connections

### 5. Relationship Dashboard
**5-Second Goal: See who needs attention**

- **Today's Focus:** 2-3 people you should reach out to today
- **Quick Win List:** Easy follow-ups you can knock out in 5 minutes
- **Relationship Health:** Visual indicators of who you're losing touch with
- **Streak Counter:** Gamification for consistent networking habits

## User Experience Flow

### Onboarding (30 seconds max)
1. "Welcome! Let's add your first contact in 5 seconds"
2. Demo the business card scanner
3. "You're ready to go!"

### Daily Use Pattern
1. **Morning Widget:** "3 people to reach out to today"
2. **Meeting Someone New:** Scan card or quick-add while shaking hands
3. **Walking Away:** Voice note with first impressions
4. **Getting Notification:** One-tap to send follow-up message
5. **Weekly Review:** 2-minute check-in on relationship health

## Technical Requirements

### iOS Native Development
- **Language:** Swift
- **Minimum iOS Version:** iOS 15+
- **Architecture:** SwiftUI + Combine
- **Data Storage:** Core Data with iCloud sync
- **Camera Integration:** Vision framework for business card scanning
- **ML Integration:** Natural language processing for smart suggestions

### Key iOS Integrations
- **Contacts App:** Seamless import/export
- **Siri Shortcuts:** "Add networking contact" or "Check my follow-ups"
- **Widgets:** Home screen networking dashboard
- **Spotlight Search:** Find contacts instantly
- **Share Sheet:** Add contacts from other apps
- **Background App Refresh:** Smart notification timing

### Performance Requirements
- **App Launch:** Under 1 second
- **Contact Addition:** Under 5 seconds end-to-end
- **Search Results:** Instant as you type
- **Business Card Scan:** Under 3 seconds to extract and save

## Data Model

### Contact Object
```swift
struct Contact {
    let id: UUID
    var firstName: String
    var lastName: String
    var company: String?
    var jobTitle: String?
    var email: String?
    var phone: String?
    var linkedInURL: String?
    
    // Context
    var metAt: String? // "TechCrunch Disrupt", "Coffee shop"
    var dateAdded: Date
    var lastContact: Date?
    var nextFollowUp: Date?
    var relationship: RelationshipType
    
    // Quick capture
    var voiceNotes: [VoiceNote]
    var quickTags: [String]
    var conversationTopics: [String]
    var mutualConnections: [String]
    
    // Engagement tracking
    var interactionCount: Int
    var lastInteractionType: InteractionType
    var relationshipStrength: RelationshipStrength
}
```

## Success Metrics

### Behavioral Metrics (Most Important)
- **Time to First Contact Added:** Must be under 60 seconds
- **Daily Active Users:** People opening app daily
- **Follow-Up Completion Rate:** % of reminders that result in actual outreach
- **Retention:** People still using app after 30 days
- **Habit Formation:** Users who add contacts consistently for 7+ days

### Feature Usage
- **Business Card Scans per User:** Measure adoption of key feature
- **Voice Notes Usage:** Indicates ease of capture
- **Template Usage:** Shows follow-up friction reduction
- **Widget Interactions:** Measure daily engagement

## MLP Features (v2 - Minimum Lovable Product)

### 1. AI-Powered Message Intelligence
**Goal: Remove the "what do I say?" barrier completely**

#### Smart Message Recommendations
- **Context-Aware Suggestions:** AI analyzes conversation history, mutual connections, recent LinkedIn activity, and industry news to suggest personalized messages
- **Relationship Stage Recognition:** Different message types for first follow-up vs. maintaining existing relationships vs. re-engaging dormant connections
- **Industry-Specific Templates:** Tech, finance, consulting, sales, etc. with appropriate language and topics
- **Tone Matching:** Professional, casual, or warm based on relationship context and previous interactions

#### Dynamic Message Generation
```swift
struct MessageRecommendation {
    let id: UUID
    let contactId: UUID
    let messageType: MessageType // followUp, checkIn, reEngagement, introduction
    let suggestedText: String
    let reasoning: String // "It's been 3 weeks since your coffee meeting about AI startups"
    let confidence: Float // AI confidence in recommendation quality
    let channels: [ContactChannel] // email, LinkedIn, text, call
    let urgency: UrgencyLevel // immediate, thisWeek, thisMonth
}
```

#### Message Types:
- **Initial Follow-Up:** "Great meeting you at [Event]. I've been thinking about your point on [Topic]..."
- **Value-Add Check-In:** "Saw this article about [Industry Trend] and thought you'd find it interesting..."
- **Introduction Facilitation:** "I'd love to introduce you to [Name] who's working on something similar..."
- **Re-Engagement:** "It's been a while since we connected. How's [Project/Company] going?"
- **Event-Based:** "Congratulations on [LinkedIn update/company news]!"

### 2. Intelligent Timing Engine
**Goal: Know exactly when to reach out for maximum impact**

#### Dynamic Follow-Up Scheduling
- **Relationship Velocity Tracking:** How quickly this person typically responds and engages
- **Industry Pattern Recognition:** When people in specific industries are most responsive
- **Personal Rhythm Analysis:** Individual contact's preferred communication cadence
- **Event-Triggered Timing:** Automatic suggestions based on LinkedIn activity, company news, job changes

#### Smart Timing Factors:
```swift
struct TimingIntelligence {
    let contactId: UUID
    let lastInteractionDate: Date
    let averageResponseTime: TimeInterval
    let preferredContactDays: [Weekday] // Based on historical data
    let industryOptimalTiming: OptimalTiming
    let relationshipStage: RelationshipStage
    let urgencyMultiplier: Float // Based on context importance
    let nextOptimalContact: Date
    let reasoning: String
}
```

#### Timing Recommendations:
- **Hot Leads:** Within 24 hours with high-priority notification
- **New Connections:** 2-3 days for initial follow-up, then 2 weeks, then monthly
- **Warm Relationships:** Every 4-6 weeks with value-add content
- **Dormant Connections:** Quarterly re-engagement with personalized context
- **Industry Events:** Immediate outreach for event-based connections

### 3. Deep Platform Integrations
**Goal: Seamless relationship building across all communication channels**

#### LinkedIn Integration
- **Activity Feed Monitoring:** Real-time tracking of connections' posts, job changes, company updates
- **Automated Engagement Suggestions:** "John just posted about AI regulation - perfect time to reconnect"
- **Profile Enrichment:** Auto-update contact details from LinkedIn changes
- **Message Sync:** Send LinkedIn messages directly from the app
- **Mutual Connection Discovery:** Identify shared connections for warm introductions
- **Company Intelligence:** Track when contacts' companies are in the news

```swift
struct LinkedInIntegration {
    let contactLinkedInURL: String
    let recentActivity: [LinkedInActivity]
    let mutualConnections: [Contact]
    let companyUpdates: [CompanyNews]
    let profileChanges: [ProfileChange]
    let engagementOpportunities: [EngagementSuggestion]
}
```

#### Calendar Integration
- **Meeting-Based Contact Creation:** Auto-create contacts for meeting attendees
- **Pre-Meeting Research:** Surface relevant context before scheduled meetings
- **Post-Meeting Follow-Up:** Automatic follow-up suggestions 24 hours after meetings
- **Meeting Context Capture:** Notes, attendees, and outcomes automatically linked to contacts
- **Recurring Meeting Intelligence:** Track relationship development over time

#### Gmail/Outlook Integration
- **Email Thread Analysis:** Understand conversation context and sentiment
- **Automatic Contact Enrichment:** Extract details from email signatures and conversations
- **Response Time Tracking:** Learn individual communication patterns
- **Email Template Integration:** Send recommended messages directly through preferred email client
- **Meeting Scheduling:** Inline calendar booking for follow-up meetings

#### Meeting Recording Integration
- **Multi-Platform Support:** Zoom, Granola, Otter.ai, Grain, Gong, and other recording tools
- **Automatic Meeting Detection:** Identify and link recordings to relevant contacts
- **AI-Powered Transcription Analysis:** Extract key topics, decisions, action items, and sentiment
- **Relationship Context Building:** Use meeting content to enhance contact profiles and conversation history
- **Follow-Up Intelligence:** Generate personalized follow-up messages based on meeting content
- **Meeting Insights Dashboard:** Track discussion themes, relationship development, and engagement patterns

```swift
struct MeetingRecording {
    let id: UUID
    let meetingId: String // External platform meeting ID
    let platform: RecordingPlatform // zoom, granola, otter, grain, etc.
    let title: String
    let date: Date
    let duration: TimeInterval
    let participants: [Contact]
    let transcript: MeetingTranscript?
    let summary: MeetingSummary
    let actionItems: [ActionItem]
    let keyTopics: [Topic]
    let decisions: [Decision]
    let followUpSuggestions: [MessageRecommendation]
    let sentimentAnalysis: SentimentScore
}

struct MeetingSummary {
    let executiveSummary: String
    let keyDiscussionPoints: [String]
    let participantInsights: [ParticipantInsight]
    let relationshipDynamics: RelationshipInsight
    let businessOpportunities: [Opportunity]
    let personalNotes: [PersonalDetail] // Family updates, interests mentioned
}
```

#### Advanced Communication Features
- **Multi-Channel Messaging:** Send via email, LinkedIn, SMS from single interface
- **Message Scheduling:** Send at optimal times based on recipient patterns
- **Response Tracking:** Monitor engagement and adjust future recommendations
- **A/B Testing:** Test different message approaches and learn what works

### 4. Meeting Recording Intelligence
**Goal: Transform meeting recordings into actionable relationship insights**

#### Core Meeting Recording Features

##### Multi-Platform Integration
- **Zoom Integration:** Direct API access to cloud recordings, transcripts, and meeting metadata
- **Granola Integration:** Advanced meeting summaries and AI-generated insights
- **Otter.ai Integration:** Real-time transcription and speaker identification
- **Grain Integration:** Video highlights and key moment extraction
- **Gong Integration:** Sales conversation intelligence and coaching insights
- **Google Meet/Teams:** Basic recording access through calendar integration
- **Manual Upload:** Support for any recording file format (MP3, MP4, WAV)

##### Intelligent Meeting Processing
```swift
struct MeetingIntelligence {
    let recordingId: UUID
    let processingStatus: ProcessingStatus // queued, processing, completed, failed
    let confidence: Float // AI confidence in analysis quality
    let languageDetection: [Language] // Multiple languages in same meeting
    let speakerIdentification: [SpeakerProfile]
    let emotionalTone: EmotionalAnalysis
    let engagementMetrics: EngagementScore
    let followUpPriority: PriorityLevel
}

enum ProcessingStatus {
    case queued
    case transcribing
    case analyzing
    case generatingInsights
    case completed
    case failed(Error)
}
```

##### Advanced Content Analysis
- **Topic Extraction:** Identify main discussion themes and subject areas
- **Decision Tracking:** Capture commitments, agreements, and next steps
- **Action Item Generation:** Automatically create follow-up tasks with ownership
- **Sentiment Analysis:** Understand meeting tone and participant engagement
- **Key Quote Extraction:** Highlight important statements and insights
- **Business Opportunity Detection:** Identify potential deals, partnerships, or collaborations

##### Relationship Context Enhancement
- **Speaker Profiling:** Build detailed profiles of how each contact communicates
- **Communication Style Analysis:** Understand preferences for data vs. stories, detail vs. big picture
- **Interest Mapping:** Track topics that generate engagement from specific contacts
- **Influence Patterns:** Identify who drives decisions and influences outcomes
- **Relationship Dynamics:** Understand power structures and communication flows

##### Intelligent Follow-Up Generation
- **Context-Aware Messages:** Reference specific meeting moments and discussions
- **Action-Based Follow-Ups:** Tie messages to commitments made during meetings
- **Personalized Tone Matching:** Adapt message style to match meeting participants' communication preferences
- **Multi-Stakeholder Messaging:** Different follow-up messages for different meeting participants
- **Timeline-Aware Scheduling:** Suggest follow-up timing based on commitments made

#### Meeting-Enhanced Contact Profiles

##### Dynamic Contact Intelligence
```swift
struct ContactMeetingProfile {
    let contactId: UUID
    let meetingHistory: [MeetingParticipation]
    let communicationStyle: CommunicationProfile
    let topicInterests: [TopicEngagement]
    let decisionMakingPattern: DecisionStyle
    let relationshipEvolution: [RelationshipMilestone]
    let businessContext: BusinessProfile
    let personalInsights: PersonalProfile
}

struct CommunicationProfile {
    let preferredMeetingLength: TimeInterval
    let engagementPatterns: [EngagementPattern]
    let questioningStyle: QuestioningType
    let decisionSpeed: DecisionVelocity
    let informationPreference: InformationType // data-driven, story-driven, visual
}
```

##### Conversation Memory System
- **Meeting-to-Meeting Continuity:** Track discussion threads across multiple meetings
- **Promise Tracking:** Monitor follow-through on commitments made
- **Topic Evolution:** See how discussions on specific topics develop over time
- **Relationship Milestones:** Identify key moments that strengthened or changed relationships
- **Business Development Pipeline:** Track how relationships translate to business outcomes

#### Meeting Analytics & Insights

##### Relationship Health Indicators
- **Engagement Scores:** Measure active participation vs. passive listening
- **Response Patterns:** Track how contacts respond to different topics or approaches
- **Meeting Frequency Optimization:** Suggest optimal cadence based on relationship stage
- **Quality Metrics:** Assess meeting productivity and relationship development

##### Predictive Intelligence
- **Follow-Up Success Prediction:** Likelihood of positive response based on meeting analysis
- **Deal Progression Signals:** Early indicators of business opportunities
- **Relationship Risk Assessment:** Detect potential issues or declining engagement
- **Optimal Next Meeting Timing:** Suggest best times for follow-up meetings

##### Business Intelligence Dashboard
- **Meeting ROI Analysis:** Track which meetings lead to valuable outcomes
- **Network Effect Mapping:** Understand how introductions and referrals develop
- **Industry Intelligence:** Aggregate insights across similar roles or industries
- **Personal Performance Metrics:** Improve your own meeting effectiveness

### 5. Relationship Intelligence Dashboard
**Goal: Proactive relationship management with predictive insights**

#### AI-Powered Insights
- **Relationship Health Score:** Algorithm combining recency, frequency, and engagement quality
- **Networking ROI Tracking:** Which connections lead to opportunities, introductions, or value
- **Attention Alerts:** "Sarah hasn't heard from you in 6 weeks - she typically expects monthly check-ins"
- **Opportunity Identification:** "3 of your contacts are hiring - perfect time for introductions"
- **Network Growth Suggestions:** "You have strong tech connections but weak finance network"

#### Predictive Features
- **Churn Risk Detection:** Identify relationships likely to go dormant
- **Introduction Opportunities:** Suggest valuable connections between contacts
- **Career Move Prediction:** Early signals of job changes or company moves
- **Event Attendance Suggestions:** Which networking events your contacts might attend

### 5. Enhanced User Experience

#### Conversation Memory
- **Topic Tracking:** Remember what you discussed and suggest follow-up topics
- **Interest Mapping:** Build profiles of contacts' professional interests and goals
- **Project Tracking:** Follow up on mentioned projects, initiatives, or challenges
- **Personal Details:** Remember family, hobbies, and personal interests for warmer conversations

#### Smart Notifications
- **Priority-Based Alerts:** Only interrupt for high-value opportunities
- **Batched Suggestions:** Daily digest of networking actions rather than constant pings
- **Context-Aware Timing:** Deliver suggestions when you're most likely to act
- **Success Feedback Loop:** Learn from which suggestions you act on

### 6. Integration Architecture

#### API Integrations Required:
- **LinkedIn API:** Profile data, activity feed, messaging
- **Google Calendar/Outlook:** Meeting data, scheduling
- **Gmail/Outlook APIs:** Email analysis, sending
- **OpenAI/Claude:** Message generation and timing intelligence
- **Company databases:** Crunchbase, LinkedIn Company Pages for business context

##### Meeting Recording Platform APIs:
- **Zoom API:** Cloud recordings, transcripts, meeting metadata, participant data
- **Granola API:** AI-generated meeting summaries and insights
- **Otter.ai API:** Real-time transcription, speaker identification, highlights
- **Grain API:** Video clips, key moments, conversation intelligence
- **Gong API:** Sales conversation analytics and coaching insights
- **Google Meet API:** Basic meeting data through Workspace integration
- **Microsoft Teams API:** Meeting recordings through Graph API
- **Whisper API:** For local transcription of uploaded recordings
- **Assembly AI:** Advanced audio intelligence for uploaded files

#### Data Privacy & Security:
- **Local-First Architecture:** Sensitive data stays on device
- **Encrypted Sync:** End-to-end encryption for cloud backup
- **Minimal Data Collection:** Only store what's necessary for functionality
- **User Control:** Granular privacy settings for each integration

## API Integration Requirements

### 1. Meeting Recording Platform APIs

#### Zoom API Integration
**Endpoint:** `https://api.zoom.us/v2/`
- **Authentication:** OAuth 2.0 with PKCE for mobile apps
- **Required Scopes:**
  - `meeting:read` - Access meeting details
  - `recording:read` - Access cloud recordings
  - `user:read` - Basic user information
- **Key Endpoints:**
  - `GET /users/{userId}/recordings` - List recordings
  - `GET /meetings/{meetingId}/recordings` - Get meeting recordings
  - `GET /meetings/{meetingId}` - Meeting details and participants
- **Rate Limits:** 2,000 requests/day (can request increase)
- **Webhook Support:** Real-time notifications for new recordings
- **Cost:** Free tier available, paid plans for higher limits
- **Data Format:** MP4 video, M4A audio, VTT transcripts

#### Granola API Integration  
**Endpoint:** `https://api.granola.ai/v1/`
- **Authentication:** API Key-based authentication
- **Required Permissions:**
  - Meeting summaries access
  - AI insights and analysis
  - Action item extraction
- **Key Endpoints:**
  - `POST /meetings/upload` - Upload meeting recording
  - `GET /meetings/{id}/summary` - Get AI-generated summary
  - `GET /meetings/{id}/insights` - Get meeting insights
  - `GET /meetings/{id}/action-items` - Extract action items
- **Rate Limits:** 100 requests/hour (varies by plan)
- **Processing Time:** 2-5 minutes for analysis
- **Cost:** Usage-based pricing per meeting processed
- **Data Format:** JSON responses with structured insights

#### Otter.ai API Integration
**Endpoint:** `https://otter.ai/forward/api/v1/`
- **Authentication:** OAuth 2.0 or API Key
- **Required Scopes:**
  - `read:transcripts` - Access transcriptions
  - `read:summaries` - Access AI summaries
- **Key Endpoints:**
  - `GET /speeches` - List all transcripts
  - `GET /speeches/{id}` - Get specific transcript
  - `GET /speeches/{id}/summary` - Get summary
- **Rate Limits:** 600 requests/hour
- **Real-time:** WebSocket support for live transcription
- **Cost:** Tiered pricing based on transcription hours
- **Data Format:** JSON with timestamps and speaker identification

#### Grain API Integration
**Endpoint:** `https://api.grain.co/v1/`
- **Authentication:** OAuth 2.0
- **Required Scopes:**
  - `recordings:read` - Access meeting recordings
  - `highlights:read` - Access video highlights
- **Key Endpoints:**
  - `GET /recordings` - List recordings
  - `GET /recordings/{id}/highlights` - Get key moments
  - `GET /recordings/{id}/transcript` - Get transcript
- **Rate Limits:** 1,000 requests/hour
- **Features:** Video clip generation, moment detection
- **Cost:** Per-seat pricing model
- **Data Format:** Video clips (MP4) and JSON metadata

#### Gong API Integration
**Endpoint:** `https://api.gong.io/v2/`
- **Authentication:** OAuth 2.0 (Enterprise requirement)
- **Required Scopes:**
  - `api:calls:read:basic` - Basic call information
  - `api:calls:read:extensive` - Detailed call analytics
- **Key Endpoints:**
  - `GET /calls` - List calls/meetings
  - `GET /calls/{id}` - Get call details and insights
  - `GET /calls/{id}/transcript` - Get transcript
- **Rate Limits:** 3,000 requests/day
- **Features:** Sales conversation intelligence
- **Cost:** Enterprise-level pricing
- **Data Format:** Comprehensive JSON analytics

### 2. Communication Platform APIs

#### LinkedIn API Integration
**Endpoint:** `https://api.linkedin.com/v2/`
- **Authentication:** OAuth 2.0 with LinkedIn Login
- **Required Scopes:**
  - `r_liteprofile` - Basic profile information
  - `r_emailaddress` - Email address
  - `w_member_social` - Share content and send messages
- **Key Endpoints:**
  - `GET /people/~` - Current user profile
  - `GET /people/{person-id}` - Contact profiles
  - `POST /messaging/conversations` - Send messages
  - `GET /shares` - Activity feed (limited)
- **Rate Limits:** Varies by endpoint (100-500/day typical)
- **Limitations:** Restricted API access, requires partnership for full features
- **Cost:** Free for basic use, partner fees for advanced access
- **Data Format:** JSON with LinkedIn-specific schemas

#### Gmail API Integration
**Endpoint:** `https://gmail.googleapis.com/gmail/v1/`
- **Authentication:** OAuth 2.0 with Google Sign-In
- **Required Scopes:**
  - `gmail.readonly` - Read emails
  - `gmail.send` - Send emails
  - `gmail.compose` - Create drafts
- **Key Endpoints:**
  - `GET /users/{userId}/messages` - List messages
  - `GET /users/{userId}/messages/{id}` - Get message
  - `POST /users/{userId}/messages/send` - Send message
- **Rate Limits:** 1 billion quota units/day (varies by operation)
- **Features:** Thread analysis, attachment handling
- **Cost:** Free with Google account
- **Data Format:** RFC 2822 email format in JSON

#### Outlook API Integration
**Endpoint:** `https://graph.microsoft.com/v1.0/`
- **Authentication:** OAuth 2.0 with Microsoft identity platform
- **Required Scopes:**
  - `Mail.Read` - Read user mail
  - `Mail.Send` - Send mail as user
  - `Contacts.Read` - Read contacts
- **Key Endpoints:**
  - `GET /me/messages` - List messages
  - `POST /me/sendMail` - Send message
  - `GET /me/contacts` - Get contacts
- **Rate Limits:** 10,000 requests/10 minutes
- **Features:** Advanced query capabilities
- **Cost:** Free with Microsoft account
- **Data Format:** OData JSON responses

### 3. Calendar Platform APIs

#### Google Calendar API
**Endpoint:** `https://www.googleapis.com/calendar/v3/`
- **Authentication:** OAuth 2.0 with Google Sign-In
- **Required Scopes:**
  - `calendar.readonly` - Read calendar events
  - `calendar.events` - Manage events
- **Key Endpoints:**
  - `GET /calendars/{calendarId}/events` - List events
  - `GET /calendars/{calendarId}/events/{eventId}` - Get event
  - `POST /calendars/{calendarId}/events` - Create event
- **Rate Limits:** 1,000,000 queries/day
- **Features:** Meeting participant extraction, location data
- **Cost:** Free with Google account
- **Data Format:** JSON with RFC 3339 timestamps

#### Outlook Calendar API
**Endpoint:** `https://graph.microsoft.com/v1.0/`
- **Authentication:** OAuth 2.0 with Microsoft identity platform
- **Required Scopes:**
  - `Calendars.Read` - Read calendars
  - `Calendars.ReadWrite` - Modify calendars
- **Key Endpoints:**
  - `GET /me/events` - List events
  - `GET /me/events/{id}` - Get event details
  - `POST /me/events` - Create event
- **Rate Limits:** 10,000 requests/10 minutes
- **Features:** Teams meeting integration
- **Cost:** Free with Microsoft account
- **Data Format:** OData JSON with ISO 8601 timestamps

### 4. AI and Intelligence APIs

#### OpenAI API Integration
**Endpoint:** `https://api.openai.com/v1/`
- **Authentication:** Bearer token (API Key)
- **Key Endpoints:**
  - `POST /chat/completions` - GPT-4 conversations
  - `POST /audio/transcriptions` - Whisper transcription
  - `POST /embeddings` - Text embeddings for similarity
- **Rate Limits:** Varies by model and tier
- **Features:** Message generation, meeting analysis, sentiment analysis
- **Cost:** Token-based pricing ($0.03/1K tokens for GPT-4)
- **Data Format:** JSON with structured responses

#### Claude API Integration (Anthropic)
**Endpoint:** `https://api.anthropic.com/v1/`
- **Authentication:** x-api-key header
- **Key Endpoints:**
  - `POST /messages` - Claude conversations
  - `POST /complete` - Text completions
- **Rate Limits:** 1,000 requests/minute (varies by tier)
- **Features:** Long-context analysis, nuanced relationship insights
- **Cost:** Input/output token pricing
- **Data Format:** JSON responses

#### Assembly AI Integration
**Endpoint:** `https://api.assemblyai.com/v2/`
- **Authentication:** API Key in authorization header
- **Key Endpoints:**
  - `POST /upload` - Upload audio file
  - `POST /transcript` - Start transcription
  - `GET /transcript/{id}` - Get results
- **Rate Limits:** Concurrent processing limits
- **Features:** Speaker diarization, sentiment analysis, topic detection
- **Cost:** Per-hour transcription pricing
- **Data Format:** JSON with detailed audio intelligence

### 5. Business Intelligence APIs

#### Crunchbase API
**Endpoint:** `https://api.crunchbase.com/api/v4/`
- **Authentication:** User Key parameter
- **Key Endpoints:**
  - `GET /entities/organizations/{permalink}` - Company data
  - `GET /entities/people/{permalink}` - Person data
  - `GET /searches/organizations` - Search companies
- **Rate Limits:** 200 requests/minute
- **Features:** Company funding, news, key people
- **Cost:** Tiered API access pricing
- **Data Format:** JSON with comprehensive business data

### 6. Implementation Architecture

#### API Management Strategy
```swift
protocol APIIntegration {
    var baseURL: String { get }
    var authenticationMethod: AuthMethod { get }
    var rateLimits: RateLimit { get }
    var requiredScopes: [String] { get }
    
    func authenticate() async throws -> AuthToken
    func makeRequest<T: Codable>(_ endpoint: Endpoint) async throws -> T
    func handleRateLimit(_ error: RateLimitError) async throws
}

enum AuthMethod {
    case oauth2(clientId: String, scopes: [String])
    case apiKey(String)
    case bearerToken(String)
}

struct RateLimit {
    let requestsPerHour: Int
    let requestsPerDay: Int
    let burstLimit: Int?
    let resetWindow: TimeInterval
}
```

#### Error Handling & Resilience
- **Retry Logic:** Exponential backoff for transient failures
- **Circuit Breakers:** Prevent cascade failures across integrations
- **Fallback Strategies:** Graceful degradation when APIs unavailable
- **Offline Support:** Cache critical data for offline functionality
- **Rate Limit Management:** Intelligent queuing and request spacing

#### Security Considerations
- **Token Storage:** Secure Keychain storage for all API credentials
- **Token Refresh:** Automatic OAuth token renewal
- **Scope Minimization:** Request only necessary permissions
- **Data Encryption:** End-to-end encryption for sensitive API responses
- **API Key Rotation:** Support for regular credential rotation

#### Monitoring & Analytics
- **API Health Monitoring:** Track success rates and response times
- **Usage Analytics:** Monitor API quota consumption
- **Error Tracking:** Detailed logging for integration failures
- **Performance Metrics:** Latency and throughput monitoring
- **Cost Tracking:** Monitor API usage costs across all integrations

### 7. Success Metrics for MLP

#### Behavioral Impact:
- **Message Send Rate:** Increase from current baseline
- **Response Rates:** Higher engagement from AI-recommended messages
- **Relationship Maintenance:** Reduced relationship churn rate
- **Follow-Up Completion:** % of AI suggestions that result in actual outreach
- **Time to Action:** Reduced friction in reaching out to contacts

#### Intelligence Effectiveness:
- **Message Relevance Score:** User ratings of AI suggestions
- **Timing Accuracy:** Success rate of optimal timing predictions
- **Integration Usage:** Adoption of LinkedIn, calendar, email features
- **Relationship Health:** Improved scores over time with AI guidance

#### Meeting Intelligence Metrics:
- **Meeting Processing Accuracy:** Quality of transcripts, summaries and extracted insights
- **Action Item Completion Rate:** % of meeting-generated action items completed
- **Follow-Up Impact:** Response rates to meeting-based follow-up messages
- **Meeting Context Utilization:** How often meeting insights are leveraged in future interactions
- **Meeting Platform Integration:** % of meetings successfully captured and processed
- **Relationship Development Velocity:** Speed of relationship progression with meeting intelligence

## Additional MLP Suggestions

### 8. Voice-First Interactions
- **Voice Message Composition:** Speak messages, AI converts to polished text
- **Siri Integration:** "Remind me to follow up with John about the startup discussion"
- **Voice Notes Processing:** AI extracts action items and contact updates from voice memos

### 9. Team/Organization Features
- **Relationship Handoffs:** Transfer contact context when changing roles
- **Team Introductions:** Help colleagues connect with your network appropriately
- **Shared Contact Intelligence:** Aggregate insights across team members (with permission)

### 10. Advanced Automation
- **Auto-Introduction Facilitation:** AI identifies and suggests valuable connections
- **Event-Based Automation:** Automatic outreach triggers based on news, LinkedIn activity, job changes
- **Content Sharing Engine:** Share relevant articles/resources with appropriate contacts automatically

### 11. Analytics & Insights
- **Networking ROI Dashboard:** Track career opportunities, partnerships, referrals from network
- **Influence Mapping:** Identify key connectors and influencers in your network
- **Geographic/Industry Analysis:** Visualize network distribution and gaps
- **Relationship Lifecycle Analytics:** Understand patterns in your networking effectiveness

## Future Enhancements (v3+)

### Advanced Intelligence Layer
- **Personality Analysis:** Adapt communication style to individual preferences
- **Industry Trend Integration:** Leverage current events for conversation starters
- **Network Effect Optimization:** Maximize introductions and referrals
- **Predictive Networking:** Suggest new connections before you need them

### Enterprise Features
- **CRM Integration:** Bidirectional sync with Salesforce, HubSpot, etc.
- **Team Networking Insights:** Collective relationship intelligence
- **Compliance Features:** Industry-specific communication guidelines
- **Advanced Analytics:** Custom reporting and relationship ROI tracking

## Risk Mitigation

### User Adoption Risks
- **Risk:** Users abandon after initial download
- **Mitigation:** Obsessive focus on first-time user experience

### Privacy Concerns
- **Risk:** Users worry about contact data privacy
- **Mitigation:** Local-first storage, clear privacy messaging, no data sharing

### Habit Formation Risks
- **Risk:** Users don't develop consistent usage
- **Mitigation:** Smart notifications, gamification, minimal friction

## Development Priorities

### Phase 1 (MVP - 6 weeks) ✅ COMPLETED
1. Core contact addition (scan + quick add)
2. Basic follow-up reminders
3. Simple note-taking
4. Essential iOS integrations

### Phase 2 (MLP Core Intelligence - 10 weeks)
**Focus: AI-powered messaging, timing intelligence, and meeting recording integration**
1. **AI Message Generation Engine (2 weeks)**
   - OpenAI/Claude API integration
   - Context-aware message templates
   - Relationship stage recognition
   - Message confidence scoring

2. **Meeting Recording Integration Foundation (2 weeks)**
   - Zoom API integration and authentication
   - Granola API setup for advanced summaries
   - Basic transcription processing with Whisper
   - Meeting-to-contact linking system
   - File upload support for manual recordings

3. **Meeting Intelligence Processing (2 weeks)**
   - AI-powered content analysis (topics, sentiment, decisions)
   - Action item extraction and assignment
   - Speaker identification and profiling
   - Key quote and insight extraction
   - Meeting summary generation

4. **Intelligent Timing System (2 weeks)**
   - Response pattern analysis enhanced with meeting data
   - Optimal timing recommendations based on meeting outcomes
   - Event-triggered suggestions from meeting content
   - Priority-based notifications with meeting context

5. **LinkedIn Integration Foundation (2 weeks)**
   - LinkedIn API setup and authentication
   - Profile data synchronization
   - Activity feed monitoring
   - Basic messaging capabilities integrated with meeting insights

### Phase 3 (Deep Platform Integration - 8 weeks)
**Focus: Calendar, email, communication channels, and expanded meeting platforms**
1. **Calendar Integration (2 weeks)**
   - Google Calendar/Outlook API integration
   - Meeting-based contact creation with recording detection
   - Pre/post-meeting intelligence enhanced with historical meeting data
   - Automatic follow-up scheduling based on meeting outcomes

2. **Extended Meeting Platform Support (2 weeks)**
   - Otter.ai API integration for real-time transcription
   - Grain API for video highlights and key moments
   - Gong API for sales conversation intelligence
   - Google Meet/Teams basic recording access
   - Assembly AI for advanced audio intelligence

3. **Email Integration (2 weeks)**
   - Gmail/Outlook API setup
   - Email thread analysis enhanced with meeting context
   - Automatic contact enrichment from meeting insights
   - Multi-channel message sending with meeting-based personalization

4. **Communication Hub (2 weeks)**
   - Unified messaging interface with meeting context
   - Response tracking and analytics across all channels
   - Message scheduling and optimization based on meeting patterns
   - A/B testing framework for meeting follow-up effectiveness

### Phase 4 (Advanced Intelligence - 6 weeks)
**Focus: Predictive features, meeting-powered insights, and advanced automation**
1. **Meeting-Powered Relationship Dashboard (2 weeks)**
   - AI-powered insights enhanced with meeting intelligence
   - Meeting ROI tracking and relationship development metrics
   - Network analysis with meeting-based relationship strength
   - Churn risk detection using meeting engagement patterns
   - Meeting effectiveness coaching and suggestions

2. **Advanced Meeting Analytics (2 weeks)**
   - Cross-meeting pattern recognition
   - Relationship evolution tracking through meeting history
   - Business opportunity pipeline from meeting insights
   - Personal communication effectiveness analysis
   - Industry benchmarking for meeting outcomes

3. **Advanced Automation (2 weeks)**
   - Auto-introduction facilitation based on meeting insights
   - Meeting-triggered automation workflows
   - Content sharing engine with meeting context
   - Voice-first interactions for meeting follow-ups

### Phase 5 (Polish & Launch - 3 weeks)
1. **Performance Optimization (1 week)**
   - AI response time optimization
   - Integration reliability improvements
   - Battery and data usage optimization

2. **User Experience Refinement (1 week)**
   - Advanced user testing with AI features
   - Privacy controls and transparency
   - Onboarding for complex features

3. **Launch Preparation (1 week)**
   - App Store compliance for AI features
   - Privacy policy updates
   - Feature documentation

## Success Definition

**The app succeeds when someone who has never prioritized networking:**
1. Downloads the app
2. Adds their first contact within 60 seconds
3. Actually follows up when reminded
4. Continues using it daily for 30+ days
5. Tells others it "made networking finally click for them"

---

**Key Mantra:** "If it takes more than 5 seconds, we're doing it wrong."

---

*This PRD prioritizes ruthless simplicity and iOS-native excellence to solve the networking problem for people who have historically avoided it.*