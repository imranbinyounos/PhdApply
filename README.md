# GradKit Pro

<div align="center">
  <img src="PhdApply Final code/logo.png" alt="GradKit Pro Logo" width="128" height="128">
  
  **The Ultimate PhD Application Management Tool for macOS**
  
  [![macOS](https://img.shields.io/badge/macOS-13.0+-blue.svg)](https://developer.apple.com/macos/)
  [![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0+-orange.svg)](https://developer.apple.com/documentation/swiftui/)
  [![Swift](https://img.shields.io/badge/Swift-5.9+-red.svg)](https://swift.org)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
</div>

## 📋 Overview

GradKit Pro is a powerful macOS application designed to streamline and organize your PhD application process. Whether you're applying to multiple programs, tracking professor contacts, or managing scholarship opportunities, GradKit Pro provides an intuitive interface to keep everything organized in one place.

## ✨ Key Features

### 🎓 Application Management
- **Professor Tracking**: Manage contacts with potential supervisors including research interests, contact information, and communication history
- **University Database**: Organize target universities with departmental information and program details
- **Scholarship Opportunities**: Track funding opportunities, deadlines, and application requirements

### 📊 Status Tracking
- **Application Stages**: Track progress from initial research to final decisions
  - Researching
  - Drafting Email
  - Contacted
  - Awaiting Response
  - Interview Scheduled
  - Submitted
  - Accepted/Rejected
- **Priority Management**: Assign priority levels with custom color coding
- **Deadline Management**: Never miss important application deadlines

### 💬 Communication Logging
- **Interaction History**: Log emails, meetings, phone calls, and notes
- **Timeline View**: Track all communications chronologically
- **Follow-up Reminders**: Stay on top of your correspondence

### 🔧 Customization & Organization
- **Custom Columns**: Tailor the interface to your specific needs
- **Flexible Data Fields**: Add custom information relevant to your applications
- **Dark Mode Support**: Modern interface with system appearance integration
- **Search & Filter**: Quickly find specific applications or contacts

### 📁 Data Management
- **CSV Import/Export**: Easily backup or migrate your data
- **SwiftData Integration**: Robust local data persistence
- **Audit Trails**: Track when records were created and modified
- **Link Management**: Store and organize relevant websites, publications, and resources

## 🚀 Getting Started

### System Requirements
- macOS 13.0 (Ventura) or later
- Apple Silicon (M1/M2) or Intel Mac

### Installation
1. Download the latest release from the [Releases](../../releases) page
2. Open the `.dmg` file and drag GradKit Pro to your Applications folder
3. Launch GradKit Pro from your Applications folder

### First Launch
1. **Dashboard Overview**: Get familiar with the main dashboard showing your application progress
2. **Add Your First Entry**: Start by adding a professor, university, or scholarship
3. **Customize Columns**: Tailor the view to match your workflow
4. **Import Existing Data**: Use the CSV import feature if you have existing spreadsheets

## 📱 Interface Overview

### Main Sections
- **Dashboard**: Overview of your entire application pipeline with statistics and progress tracking
- **Professors**: Manage potential supervisor contacts and research fit
- **Universities**: Organize target institutions and program information  
- **Scholarships**: Track funding opportunities and application requirements

### Key Views
- **Table View**: Organized, spreadsheet-like interface for bulk data management
- **Detail Views**: Comprehensive forms for managing individual records
- **Search & Filter**: Powerful tools to find specific information quickly

## 🛠 Advanced Features

### CSV Data Management
```swift
// Export your data
let csvData = CSVService.export(records: applicationRecords)

// Import existing spreadsheets
let importedRecords = CSVService.import(data: csvData)
```

### Custom Fields
Add custom information fields using JSON storage for maximum flexibility:
- Research fit scores
- Application fees
- Program-specific requirements
- Personal notes and observations

### Notification System
- Deadline reminders
- Follow-up notifications
- Application status updates

## 🎯 Use Cases

### For Current Students
- **Research Phase**: Organize potential supervisors and research opportunities
- **Application Season**: Track multiple applications with deadlines and requirements
- **Interview Preparation**: Maintain detailed notes on each program and contact

### For Advisors
- **Student Guidance**: Help students organize their application process
- **Program Recommendations**: Maintain databases of suitable programs and contacts
- **Success Tracking**: Monitor student application outcomes

### For International Students
- **Visa Requirements**: Track additional documentation needs
- **Program Comparison**: Compare programs across different countries
- **Cultural Notes**: Maintain information about different academic systems

## 🏗 Technical Architecture

### Built With
- **SwiftUI**: Modern, declarative UI framework
- **SwiftData**: Powerful data persistence with CloudKit integration
- **Combine**: Reactive programming for real-time updates
- **AppKit Integration**: Native macOS functionality

### Data Models
- `ApplicationRecord`: Core application tracking with comprehensive metadata
- `LinkItem`: URL and resource management
- `InteractionLog`: Communication and activity tracking
- `GradKitStore`: Centralized state management

### Performance Features
- Lazy loading for large datasets
- Efficient search and filtering
- Background data processing
- Memory-optimized table views

## 📈 Development & Contribution

### Project Structure
```
PhdApply/
├── PhdApply/                 # Main application code
│   ├── Models.swift          # Data models and core structures
│   ├── Views.swift           # SwiftUI view components
│   ├── Services.swift        # Business logic and utilities
│   ├── GradKitStore.swift    # State management
│   └── ...
├── Tests/                    # Unit and UI tests
└── Resources/               # Assets and configurations
```

### Key Components
- **Models**: SwiftData models for persistent storage
- **Views**: Modular SwiftUI components
- **Services**: CSV handling, notifications, and utilities
- **Store**: Centralized state management with ObservableObject

## 🔒 Privacy & Security

- **Local Data Storage**: All your information stays on your Mac
- **No Cloud Dependency**: Works completely offline
- **Data Export**: Full control over your data with CSV export
- **Secure by Design**: No third-party data collection

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with love for the graduate school application community
- Inspired by the challenges of managing complex application processes
- Designed for researchers, by researchers

## 📞 Support

- **Issues**: Report bugs or request features via [GitHub Issues](../../issues)
- **Discussions**: Join the community in [GitHub Discussions](../../discussions)
- **Documentation**: Comprehensive guides available in the [Wiki](../../wiki)

---

<div align="center">
  <strong>Make your PhD application journey organized and stress-free with GradKit Pro</strong>
  
  [Download Latest Release](../../releases) • [View Documentation](../../wiki) • [Report Issues](../../issues)
</div>