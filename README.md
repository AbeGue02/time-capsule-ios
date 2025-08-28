# Time Capsule iOS App

A digital time capsule application for iOS that allows users to lock photos, text entries, and memories until a specified date and time in the future.

## Features

### 🔒 Time-Based Access Control
- Content remains completely hidden until the unlock date
- Real-time countdown timers show time remaining
- Automatic content reveal when date is reached
- Visual lock/unlock indicators throughout the app

### 📱 Content Types
- **Text Entries**: Write messages, thoughts, or memories
- **Photos**: Add images from your photo library
- **Mixed Content**: Combine text and photos in single capsules

### ☁️ Cloud Sync
- Built with CloudKit integration for seamless sync across devices
- Your time capsules are automatically backed up and shared across your Apple devices

### 🎨 Modern iOS Design
- Native SwiftUI interface following iOS design guidelines
- Intuitive navigation and user experience
- Support for iOS 18.5+

## Screenshots

*Coming soon - screenshots of the main interface, creation flow, and detail views*

## Installation

### Requirements
- iOS 18.5 or later
- Xcode 16.0 or later
- Apple Developer Account (for device testing)

### Building from Source

1. **Clone the repository**
   ```bash
   git clone https://github.com/AbeGue02/time-capsule-ios.git
   cd time-capsule-ios
   ```

2. **Open in Xcode**
   ```bash
   open "Time Capsule.xcodeproj"
   ```

3. **Configure signing**
   - Select your development team in Project Settings
   - Update the bundle identifier if needed

4. **Build and run**
   - Select your target device or simulator
   - Press `Cmd + R` to build and run

## Usage

### Creating a Time Capsule

1. Tap the **+** button in the top navigation bar
2. Enter a name for your time capsule
3. Add optional notes/description
4. Set the unlock date and time
5. Add content:
   - Tap "Add Photos" to select images from your library
   - Tap "Add Text Entry" to write messages or thoughts
6. Tap "Create" to save your time capsule

### Viewing Time Capsules

- **Locked capsules** show a countdown timer and locked content placeholders
- **Unlocked capsules** reveal all content and can be freely browsed
- Tap any capsule to view its details and content

### Managing Time Capsules

- Swipe left on any capsule to delete it
- Use the Edit button to enter deletion mode
- All content is permanently deleted when a capsule is removed

## Technical Architecture

### Core Technologies
- **SwiftUI** - Modern declarative UI framework
- **Core Data** - Local data persistence with CloudKit sync
- **CloudKit** - Cloud synchronization across devices
- **PhotosUI** - Native photo picker integration

### Data Model
```
TimeCapsule
├── id: UUID
├── name: String
├── notes: String?
├── createdDate: Date
├── openDate: Date
└── contents: [TimeCapsuleContent]

TimeCapsuleContent
├── id: UUID
├── contentType: String ("text" or "image")
├── textContent: String?
├── data: Data? (for images)
├── fileName: String?
├── createdDate: Date
└── timeCapsule: TimeCapsule
```

### Project Structure
```
Time Capsule/
├── Time_CapsuleApp.swift          # App entry point
├── ContentView.swift              # Main list interface
├── CreateTimeCapsuleView.swift    # Creation flow
├── TimeCapsuleDetailView.swift    # Detail/reveal view
├── Persistence.swift              # Core Data stack
├── Time_Capsule.xcdatamodeld/     # Data model
└── Assets.xcassets/               # App icons and colors
```

## Privacy & Security

- All data is stored locally on your device using Core Data
- CloudKit sync uses your personal iCloud account - data is not accessible by others
- No analytics, tracking, or data collection
- Content is only revealed when the specified time is reached

## Known Issues

- UUID fields in Core Data model are optional due to CloudKit constraints
- Large image files may impact performance (consider adding compression)
- Background app refresh required for accurate countdown timers

## Acknowledgments

- Built with modern iOS development best practices
- Inspired by the concept of physical time capsules
- Uses Apple's recommended patterns for Core Data and CloudKit integration

---

**Note**: This app is designed as a personal project and learning exercise. It demonstrates modern iOS development patterns including SwiftUI, Core Data, CloudKit sync, and time-based functionality.
