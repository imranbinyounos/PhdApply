# API Documentation for GradKit Pro

This document provides technical details for developers working with GradKit Pro's codebase.

## Core Data Models

### ApplicationRecord

The primary data model for tracking PhD applications.

```swift
@Model
final class ApplicationRecord {
    var id: UUID
    var professorName: String
    var email: String
    var universityName: String
    var department: String
    var researchInterests: String
    var deadline: Date?
    var statusRaw: String
    var stageRaw: String
    var priorityLevel: Int
    var colorHex: String?
    var notes: String
    @Relationship(deleteRule: .cascade) var links: [LinkItem]
    @Relationship(deleteRule: .cascade) var interactions: [InteractionLog]
    var customFieldsJSON: String?
    var createdAt: Date
    var updatedAt: Date
}
```

#### Properties
- **id**: Unique identifier (UUID)
- **professorName**: Full name of the professor or supervisor
- **email**: Contact email address
- **universityName**: Institution name
- **department**: Academic department or school
- **researchInterests**: Detailed research areas and interests
- **deadline**: Application deadline (optional)
- **statusRaw/stageRaw**: Current application status (stored as string)
- **priorityLevel**: Numeric priority (0-10 scale)
- **colorHex**: Optional color coding for visual organization
- **notes**: Free-form text notes
- **links**: Related URLs and resources
- **interactions**: Communication history
- **customFieldsJSON**: Flexible custom data storage
- **createdAt/updatedAt**: Audit timestamps

#### Computed Properties
```swift
var status: ApplicationStatus {
    get { ApplicationStatus(rawValue: statusRaw) ?? .researching }
    set { statusRaw = newValue.rawValue }
}

var stage: ApplicationStatus {
    get { ApplicationStatus(rawValue: stageRaw) ?? .researching }
    set { stageRaw = newValue.rawValue }
}
```

### LinkItem

Stores URLs and related resources.

```swift
@Model
final class LinkItem {
    var id: UUID
    var title: String
    var urlString: String
    
    init(id: UUID = UUID(), title: String, urlString: String) {
        self.id = id
        self.title = title
        self.urlString = urlString
    }
}
```

### InteractionLog

Tracks communications and interactions.

```swift
@Model
final class InteractionLog {
    var id: UUID
    var date: Date
    var typeRaw: String
    var notes: String
    
    var type: InteractionType {
        get { InteractionType(rawValue: typeRaw) ?? .note }
        set { typeRaw = newValue.rawValue }
    }
}
```

## Enumerations

### ApplicationStatus

Defines the possible states of an application.

```swift
enum ApplicationStatus: String, CaseIterable, Identifiable, Codable {
    case researching = "Researching"
    case draftingEmail = "Drafting Email"
    case contacted = "Contacted"
    case awaitingResponse = "Awaiting Response"
    case interviewScheduled = "Interview Scheduled"
    case submitted = "Submitted"
    case accepted = "Accepted"
    case rejected = "Rejected"
    
    var id: String { rawValue }
}
```

### InteractionType

Types of interactions that can be logged.

```swift
enum InteractionType: String, CaseIterable, Identifiable, Codable {
    case emailSent = "Email Sent"
    case emailReceived = "Email Received"
    case meeting = "Meeting"
    case note = "Note"
    
    var id: String { rawValue }
}
```

## Services

### CSVService

Handles import and export of application data.

#### Export
```swift
static func export(records: [ApplicationRecord]) -> Data
```

Exports application records to CSV format. Returns UTF-8 encoded data.

**Exported Fields:**
- Professor Name, Email, University, Department
- Research Interests, Deadline, Status, Stage
- Priority Level, Color Hex, Notes, Links

#### Import
```swift
static func `import`(data: Data) -> [ApplicationRecord]
```

Imports application records from CSV data.

**Expected CSV Format:**
```csv
Professor Name,Email,University,Department,Interests,Deadline,Status,Stage,Priority,ColorHex,Notes,Links
```

**Date Format:** ISO 8601 (YYYY-MM-DD)
**Links Format:** "Title:URL | Title:URL"

### NotificationService

Manages deadline reminders and notifications.

```swift
enum NotificationService {
    static func requestAuthorization()
    static func scheduleDeadlineReminder(for record: ApplicationRecord)
    static func cancelNotifications(for recordID: UUID)
}
```

## State Management

### GradKitStore

Central state management using ObservableObject.

```swift
final class GradKitStore: ObservableObject {
    @Published var db: GradKitDB
    @AppStorage("GradKitProDarkMode") var darkMode: Bool
    
    // Section management
    func addRecord(to section: GradKitSection, data: [String: String])
    func updateRecord(in section: GradKitSection, id: String, data: [String: String])
    func deleteRecord(from section: GradKitSection, id: String)
    
    // Data persistence
    private func save()
    private func load() -> GradKitDB?
}
```

### GradKitSection

Defines the main application sections.

```swift
enum GradKitSection: String, CaseIterable, Identifiable, Codable {
    case universities
    case professors
    case scholarships
    
    var id: String { rawValue }
}
```

## View Architecture

### Main Views

#### GradKitProMainView
The primary application interface with navigation and section management.

```swift
struct GradKitProMainView: View {
    @StateObject private var store = GradKitStore()
    @State private var active: GradKitSection? = .professors
    
    var body: some View {
        VStack {
            header
            nav
            SectionEditorView(section: active)
        }
        .environmentObject(store)
    }
}
```

#### DashboardViewGK
Overview dashboard with statistics and progress tracking.

#### SectionEditorView
Generic section editor for managing different data types.

### Column Configuration

#### ColumnConfig
Defines customizable table columns.

```swift
struct ColumnConfig: Identifiable, Codable, Hashable {
    let id: String
    var title: String
    var isShown: Bool
    var width: CGFloat?
    
    static let `default`: [ColumnConfig] = [
        .init(id: "professorName", title: "Professor", isShown: true, width: 160),
        .init(id: "email", title: "Email", isShown: true, width: 180),
        // ... more columns
    ]
}
```

## Data Persistence

### SwiftData Integration

GradKit Pro uses SwiftData for local persistence with the following configuration:

```swift
var sharedModelContainer: ModelContainer = {
    let schema = Schema([
        ApplicationRecord.self,
        LinkItem.self,
        InteractionLog.self
    ])
    let modelConfiguration = ModelConfiguration(
        schema: schema, 
        isStoredInMemoryOnly: false
    )
    
    do {
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}()
```

### UserDefaults Storage

Application preferences and settings are stored using UserDefaults:

```swift
struct AppStorageKeys {
    static let shownColumns = "shownColumns"
    static let darkMode = "GradKitProDarkMode"
    static let lastUsedSection = "lastUsedSection"
}
```

## Utilities

### Array Extensions

Safe array access to prevent index out of bounds errors:

```swift
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
```

### CSV Parsing

Robust CSV parsing with proper escaping:

```swift
private static func parseCSV(_ line: String) -> [String] {
    // Implementation handles quoted fields, commas, and escape characters
}

private static func escapeCSV(_ field: String) -> String {
    // Implementation properly escapes CSV fields
}
```

## Performance Considerations

### Memory Management
- Use `@StateObject` for view ownership of ObservableObject instances
- Implement lazy loading for large datasets
- Clean up observations and timers in view cleanup

### Data Operations
- Batch database operations when possible
- Use background queues for heavy CSV operations
- Implement efficient search algorithms for large datasets

### UI Responsiveness
- Use `@MainActor` for UI updates
- Implement proper loading states
- Provide user feedback for long operations

## Error Handling

### Data Validation
```swift
// Example validation for email addresses
extension String {
    var isValidEmail: Bool {
        let emailRegex = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return range(of: emailRegex, options: [.regularExpression, .caseInsensitive]) != nil
    }
}
```

### Error Types
```swift
enum GradKitError: LocalizedError {
    case invalidCSVFormat
    case dataCorruption
    case fileNotFound
    case permissionDenied
    
    var errorDescription: String? {
        switch self {
        case .invalidCSVFormat:
            return "The CSV file format is invalid or corrupted."
        case .dataCorruption:
            return "The application data appears to be corrupted."
        case .fileNotFound:
            return "The requested file could not be found."
        case .permissionDenied:
            return "Permission denied to access the file."
        }
    }
}
```

## Testing

### Unit Test Examples

```swift
final class ApplicationRecordTests: XCTestCase {
    func testApplicationRecordInitialization() {
        let record = ApplicationRecord(
            professorName: "Dr. Test",
            email: "test@university.edu",
            universityName: "Test University"
        )
        
        XCTAssertEqual(record.professorName, "Dr. Test")
        XCTAssertEqual(record.status, .researching)
        XCTAssertNotNil(record.id)
    }
    
    func testStatusTransitions() {
        let record = ApplicationRecord()
        record.status = .contacted
        XCTAssertEqual(record.statusRaw, "Contacted")
    }
}
```

### UI Test Examples

```swift
final class GradKitProUITests: XCTestCase {
    func testAddNewProfessor() {
        let app = XCUIApplication()
        app.launch()
        
        app.buttons["Professors"].tap()
        app.buttons["Add Professor"].tap()
        
        let nameField = app.textFields["Professor Name"]
        nameField.tap()
        nameField.typeText("Dr. Test Professor")
        
        app.buttons["Save"].tap()
        
        XCTAssertTrue(app.staticTexts["Dr. Test Professor"].exists)
    }
}
```

---

*This API documentation is maintained alongside the codebase. For questions or clarifications, please refer to the source code or submit questions via [GitHub Issues](../../issues).*