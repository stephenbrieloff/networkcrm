# Network CRM iOS App - MVP Task List (This Week)

## Focus: Get MVP Running This Week

**Goal:** Build the absolute minimum viable version that proves the "5-second rule" works for networking.

## Critical MVP Tasks (Week 1)

### Task 1: Development Environment Setup (Day 1)
- **Priority:** Critical
- **Effort:** Half day
- **Description:** Get Xcode project running with basic structure
- **Acceptance Criteria:**
  - Xcode project created and running
  - SwiftUI + Combine setup
  - Basic Core Data stack
  - App runs on simulator and device
  - Basic navigation structure

### Task 2: Super Simple Contact Addition (Day 1-2)
- **Priority:** Critical  
- **Effort:** 1.5 days
- **Description:** The fastest possible way to add a contact (no business card scanning yet)
- **Acceptance Criteria:**
  - Quick add form: First Name + Last Name + Company (required)
  - Email and Phone (optional, easy to add)
  - Save contact under 5 seconds
  - Immediate success feedback
  - "Add Another" option

### Task 3: Basic Contact List (Day 2)
- **Priority:** Critical
- **Effort:** Half day
- **Description:** See all your contacts in a simple list
- **Acceptance Criteria:**
  - Scrollable list of contacts
  - Show name, company, date added
  - Tap to view contact details
  - Basic search functionality
  - Empty state with "Add First Contact" call-to-action

### Task 4: Contact Detail View (Day 3)
- **Priority:** High
- **Effort:** 1 day
- **Description:** View and edit contact information
- **Acceptance Criteria:**
  - Display all contact information
  - Edit mode to update details
  - Quick action buttons (call, text, email if available)
  - Simple notes section
  - Back to list navigation

### Task 5: Basic Follow-Up Reminder (Day 4)
- **Priority:** High
- **Effort:** 1 day
- **Description:** Set a simple reminder to follow up with someone
- **Acceptance Criteria:**
  - "Remind me to follow up" button on contact detail
  - Simple date picker (tomorrow, next week, custom date)
  - Local notification when reminder triggers
  - Basic notification handling

### Task 6: MVP Polish & Testing (Day 5)
- **Priority:** High
- **Effort:** 1 day
- **Description:** Make it feel polished enough to use daily
- **Acceptance Criteria:**
  - Smooth animations and transitions
  - Proper iOS styling
  - Handle edge cases (empty states, errors)
  - Basic user testing with 2-3 people
  - Fix critical bugs

## MVP Success Criteria

**The MVP succeeds if:**
1. You can add a new contact in under 5 seconds
2. You can set a follow-up reminder in under 5 seconds  
3. The app feels native and smooth on iOS
4. Someone who has never used it can add their first contact in under 60 seconds
5. It's something you'd actually use daily

## What We're NOT Building in Week 1
- Business card scanning (Week 2 priority)
- Voice notes (nice to have)
- Advanced dashboard (Week 2)
- Widgets/Siri integration (Week 3)
- Message templates (Week 2)
- Tags system (Week 2)

## Daily Check-ins
- **End of Day 1:** Can add and save a contact
- **End of Day 2:** Can see list of contacts and view details
- **End of Day 3:** Can edit contacts and basic follow-up works
- **End of Day 4:** Notifications working, app feels complete
- **End of Day 5:** Ready for daily use and user feedback

## Quick Development Notes

### Technology Stack (Simplified)
- **SwiftUI** for UI (fastest development)
- **Core Data** for storage (built-in, reliable)
- **Local notifications** for reminders
- **No backend** (local-first for MVP)
- **No complex animations** (focus on functionality)

### Key Design Decisions for Speed
1. **Pre-built iOS components** wherever possible
2. **Standard iOS navigation patterns** (don't reinvent)
3. **Minimal custom styling** (use system defaults)
4. **Simple data structure** (optimize later)
5. **No user accounts** (local app only for MVP)

---

**Week 1 Mantra:** "Make it work, make it fast, make it feel native. Everything else is Week 2."

---

*This focused task list prioritizes getting a usable app in your hands as quickly as possible for real-world testing.*