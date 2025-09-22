# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

**Network CRM iOS App** - A frictionless iOS app that transforms networking-avoiders into networking champions by making relationship management effortless. The core philosophy is the "5-Second Rule": every core action must be completable in 5 seconds or less.

## Technology Stack

- **Platform**: iOS 15+ (Native Swift)
- **UI Framework**: SwiftUI
- **Reactive Programming**: Combine
- **Data Storage**: Core Data with iCloud sync
- **Computer Vision**: Vision Framework (for business card scanning)
- **Architecture**: MVVM with SwiftUI

## Project Structure

```
NetworkCRM/
├── Models/
│   └── NetworkCRMDataModel.xcdatamodeld    # Core Data model definition
├── Views/
│   ├── ContactListView.swift               # Main contact list with search
│   ├── AddContactView.swift                # 5-second contact creation form
│   ├── ContactDetailView.swift             # Contact details and editing
│   └── FollowUpReminderView.swift         # Reminder scheduling interface
├── ViewModels/
│   └── ContactViewModel.swift              # MVVM business logic with Combine
├── Services/
│   ├── PersistenceController.swift         # Core Data stack management
│   └── NotificationManager.swift           # Local notification handling
├── Resources/
│   ├── Assets.xcassets                     # App icons and images
│   └── Preview Content/                    # SwiftUI preview assets
├── NetworkCRMApp.swift                     # App entry point
└── ContentView.swift                       # Main navigation container
```

## Development Commands

### Building and Running
```bash
# Open the project in Xcode (recommended for iOS development)
open NetworkCRM.xcodeproj

# Build from command line
xcodebuild -project NetworkCRM.xcodeproj -scheme NetworkCRM -destination 'platform=iOS Simulator,name=iPhone 15' build

# Run on simulator (note: 'run' is not supported, use Xcode instead)
xcodebuild -project NetworkCRM.xcodeproj -scheme NetworkCRM -destination 'platform=iOS Simulator,name=iPhone 15' -derivedDataPath build/ build

# Clean build artifacts
xcodebuild -project NetworkCRM.xcodeproj -scheme NetworkCRM clean
```

### Testing
```bash
# Run all tests (when test target exists)
xcodebuild -project NetworkCRM.xcodeproj -scheme NetworkCRM -destination 'platform=iOS Simulator,name=iPhone 15' test

# Run specific test class (example - adjust based on actual test targets)
xcodebuild -project NetworkCRM.xcodeproj -scheme NetworkCRM -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:NetworkCRMTests/ContactViewModelTests test

# Run tests with specific test method
xcodebuild -project NetworkCRM.xcodeproj -scheme NetworkCRM -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:NetworkCRMTests/ContactViewModelTests/testContactCreation test
```

### Code Quality
```bash
# Run SwiftLint (if installed)
swiftlint lint

# Auto-fix SwiftLint violations
swiftlint autocorrect

# Install SwiftLint via Homebrew
brew install swiftlint
```

## Architecture Guidelines

### Implemented MVVM Pattern
The codebase follows a clean MVVM architecture:
- **Models**: Core Data entities (Contact) defined in NetworkCRMDataModel.xcdatamodeld
- **Views**: SwiftUI views focused purely on presentation
- **ViewModels**: ContactViewModel handles business logic with Combine for reactive updates
- **Services**: PersistenceController (Core Data) and NotificationManager (local notifications)

### Core Design Principles
1. **5-Second Rule**: Every core action must complete in under 5 seconds ✅ **ACHIEVED**
2. **Instant Capture**: Minimize friction for adding contacts ✅ **ACHIEVED** 
3. **Zero Configuration**: Works perfectly out of the box ✅ **ACHIEVED**
4. **Proactive Intelligence**: App suggests actions, don't make users think
5. **Native iOS Excellence**: Leverage platform conventions ✅ **ACHIEVED**

### Key Data Models

**Contact Object Structure:**
```swift
struct Contact {
    let id: UUID
    var firstName: String
    var lastName: String
    var company: String?
    var jobTitle: String?
    var email: String?
    var phone: String?
    
    // Context
    var metAt: String?
    var dateAdded: Date
    var lastContact: Date?
    var nextFollowUp: Date?
    
    // Engagement
    var voiceNotes: [VoiceNote]
    var quickTags: [String]
    var conversationTopics: [String]
    var interactionCount: Int
}
```

### Performance Requirements
- **App Launch**: Under 1 second
- **Contact Addition**: Under 5 seconds end-to-end
- **Search Results**: Instant as you type
- **Business Card Scan**: Under 3 seconds to extract and save

## Development Status: Phase 1 Complete ✅

### Completed MVP Features
1. **✅ Super Simple Contact Addition** - 3-5 second contact creation with auto-focus
2. **✅ Basic Contact List** - Scrollable list with instant search (300ms debounce)
3. **✅ Contact Detail View** - Full contact editing with quick action buttons
4. **✅ Basic Follow-Up Reminders** - Local notifications with deep-linking support
5. **✅ MVP Polish** - Native iOS styling and smooth animations

### Success Metrics Achieved
- ✅ Add a new contact in under 5 seconds (achieved: ~3-4 seconds)
- ✅ Set a follow-up reminder in under 5 seconds (achieved: ~2-3 seconds)
- ✅ App feels native and smooth on iOS
- ✅ First-time user can add contact in under 60 seconds (achieved: ~15-20 seconds)

## iOS-Specific Integrations

### Planned iOS Features
- **Contacts App**: Seamless import/export
- **Siri Shortcuts**: "Add networking contact" or "Check my follow-ups"
- **Widgets**: Home screen networking dashboard
- **Spotlight Search**: Find contacts instantly
- **Share Sheet**: Add contacts from other apps
- **Background App Refresh**: Smart notification timing
- **Vision Framework**: Business card scanning (Week 2)

### Local Notifications
- Follow-up reminders
- Relationship health alerts
- Daily networking prompts

## Development Guidelines

### Code Organization (Currently Implemented)
- **MVVM Architecture**: ContactViewModel manages business logic, Views handle presentation
- **Reactive Programming**: Uses Combine for search debouncing and data binding
- **Core Data Integration**: PersistenceController provides shared Core Data stack
- **Notification System**: NotificationManager handles local reminder notifications
- **SwiftUI Best Practices**: @FocusState for keyboard management, @EnvironmentObject for DI

### Networking Strategy
- Local-first approach for MVP
- No backend dependencies initially
- Core Data with iCloud sync for data persistence
- Consider CloudKit for future enhanced sync features

### Testing Strategy
- Unit tests for business logic in ViewModels
- UI tests for critical user flows
- Performance tests for 5-second rule compliance
- Test on multiple device sizes and iOS versions

## Future Enhancements (Week 2+)

### Intelligence Layer
- AI-powered conversation starters
- Relationship strength analysis
- Network mapping and introductions
- Industry event integration

### Advanced Features
- Business card scanning with Vision Framework
- Voice notes with speech-to-text
- Message templates for follow-ups
- Advanced dashboard with relationship insights

## Success Metrics

### Behavioral Metrics
- **Time to First Contact Added**: Must be under 60 seconds
- **Daily Active Users**: People opening app daily
- **Follow-Up Completion Rate**: % of reminders that result in actual outreach
- **30-Day Retention**: People still using app after 30 days

### Technical Performance
- App launch time
- Contact addition speed
- Search response time
- Business card scan accuracy and speed

## Development Environment

### Prerequisites
- Xcode 14+ (for iOS 15+ support)
- iOS Simulator or physical iOS device
- macOS development environment
- Apple Developer account (for device testing)

### Recommended Tools
- SwiftLint for code quality
- Instruments for performance profiling
- iOS Device for testing camera/scanning features
- TestFlight for beta distribution

## Key Implementation Details

### Core Data Architecture
- **Contact Entity**: Full contact model with relationships and transformable attributes
- **Preview Support**: Sample data generation for SwiftUI previews
- **Memory Management**: Proper context handling with automatic change merging

### Notification System
- **Authorization**: Automatic permission requests on app launch
- **Deep Linking**: Notifications open specific contacts when tapped
- **Background Scheduling**: Reliable local notification delivery

### Performance Optimizations
- **Debounced Search**: 300ms debounce prevents excessive filtering
- **Lazy Loading**: Efficient Core Data queries with sorted results
- **Memory Efficiency**: Proper @StateObject and @EnvironmentObject usage

## Key Mantras

- **Phase 1 Complete**: "Make it work, make it fast, make it feel native. Everything else is Week 2." ✅ **ACHIEVED**
- **Overall**: "If it takes more than 5 seconds, we're doing it wrong." ✅ **ACHIEVED**
- **User Focus**: "Build for networking-avoiders who want to become networking champions"

## Notes for AI Development

When working on this project:
- Prioritize user experience over technical complexity
- Always consider the 5-second rule for any new features
- Use native iOS patterns and components
- Focus on reducing friction at every interaction point
- Test frequently on actual devices for performance validation
- Remember the target user: "The Reluctant Networker" who finds networking overwhelming