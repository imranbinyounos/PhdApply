# Contributing to GradKit Pro

Thank you for your interest in contributing to GradKit Pro! This document provides guidelines and information for contributors.

## 🤝 How to Contribute

### Types of Contributions
- **Bug Reports**: Help us identify and fix issues
- **Feature Requests**: Suggest new functionality
- **Code Contributions**: Submit pull requests with improvements
- **Documentation**: Improve guides, comments, and examples
- **Testing**: Help test new features and report feedback
- **UI/UX**: Design improvements and accessibility enhancements

## 🐛 Reporting Bugs

### Before Submitting a Bug Report
1. **Check existing issues** to avoid duplicates
2. **Update to latest version** to ensure the bug still exists
3. **Gather system information** (macOS version, app version, etc.)

### Bug Report Template
```markdown
**Description**: Clear description of the bug

**Steps to Reproduce**:
1. Step one
2. Step two
3. Step three

**Expected Behavior**: What should happen

**Actual Behavior**: What actually happens

**Environment**:
- macOS Version: 
- GradKit Pro Version:
- Hardware: (Intel/Apple Silicon)

**Screenshots**: If applicable, add screenshots

**Additional Context**: Any other relevant information
```

## 💡 Feature Requests

### Before Submitting
- Check if similar features have been requested
- Consider if the feature aligns with the app's core purpose
- Think about implementation complexity and user benefit

### Feature Request Template
```markdown
**Feature Summary**: Brief description of the feature

**Problem Statement**: What problem does this solve?

**Proposed Solution**: How should this feature work?

**Alternative Solutions**: Other approaches considered

**Use Cases**: When would users utilize this feature?

**Additional Context**: Any other relevant information
```

## 🔧 Development Setup

### Prerequisites
- **macOS 13.0+**: Development environment
- **Xcode 15.0+**: Latest version recommended
- **Swift 5.9+**: Language requirements
- **Git**: Version control

### Local Development
```bash
# Fork the repository on GitHub
# Clone your fork
git clone https://github.com/YOUR-USERNAME/PhdApply.git
cd PhdApply

# Add upstream remote
git remote add upstream https://github.com/imranbinyounos/PhdApply.git

# Open in Xcode
open "PhdApply Final code/PhdApply.xcodeproj"
```

### Project Structure
```
PhdApply Final code/
├── PhdApply/
│   ├── Models.swift           # Data models
│   ├── Views.swift            # UI components
│   ├── Services.swift         # Business logic
│   ├── GradKitStore.swift     # State management
│   ├── GradKitProViews.swift  # Main views
│   ├── Utilities.swift        # Helper functions
│   └── Assets.xcassets/       # Images and assets
├── PhdApplyTests/             # Unit tests
└── PhdApplyUITests/           # UI tests
```

## 📝 Code Guidelines

### Swift Style Guide
- Follow [Apple's Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use descriptive variable and function names
- Add comments for complex logic
- Maintain consistent indentation (4 spaces)

### Code Quality
- **Write tests** for new functionality
- **Update documentation** for API changes
- **Follow SOLID principles** where applicable
- **Use SwiftLint** for consistent formatting

### Example Code Style
```swift
// Good: Descriptive names and clear structure
final class ApplicationRecordManager {
    private let dataStore: GradKitStore
    
    func createNewApplication(
        professorName: String,
        university: String,
        deadline: Date?
    ) -> ApplicationRecord {
        let record = ApplicationRecord(
            professorName: professorName,
            universityName: university,
            deadline: deadline
        )
        dataStore.addRecord(record)
        return record
    }
}
```

### SwiftUI Best Practices
- **Extract reusable components** into separate views
- **Use @ObservableObject** for shared state
- **Prefer @StateObject** over @ObservedObject** for ownership
- **Handle loading states** and error conditions

## 🧪 Testing

### Running Tests
```bash
# Unit tests
xcodebuild test -scheme PhdApplyTests

# UI tests
xcodebuild test -scheme PhdApplyUITests

# All tests
xcodebuild test -scheme PhdApply
```

### Writing Tests
- **Unit tests** for business logic and data models
- **UI tests** for critical user workflows
- **Integration tests** for data persistence
- **Performance tests** for large datasets

### Test Example
```swift
final class ApplicationRecordTests: XCTestCase {
    func testApplicationRecordCreation() {
        let record = ApplicationRecord(
            professorName: "Dr. Smith",
            email: "smith@university.edu",
            universityName: "Example University"
        )
        
        XCTAssertEqual(record.professorName, "Dr. Smith")
        XCTAssertEqual(record.status, .researching)
        XCTAssertNotNil(record.id)
    }
}
```

## 🔄 Pull Request Process

### Before Submitting
1. **Create feature branch** from main
2. **Write descriptive commits** using conventional format
3. **Add tests** for new functionality
4. **Update documentation** if needed
5. **Run all tests** and ensure they pass

### Pull Request Template
```markdown
**Summary**: Brief description of changes

**Related Issue**: Fixes #issue-number

**Changes Made**:
- Change 1
- Change 2
- Change 3

**Testing**:
- [ ] Unit tests added/updated
- [ ] UI tests added/updated
- [ ] Manual testing completed

**Screenshots**: If UI changes, include before/after

**Checklist**:
- [ ] Code follows style guidelines
- [ ] Tests pass locally
- [ ] Documentation updated
- [ ] No breaking changes (or clearly documented)
```

### Commit Message Format
```
type(scope): brief description

Detailed explanation of the change, including motivation
and context for the change.

Fixes #issue-number
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

## 📚 Documentation

### Code Documentation
- **Add docstrings** to public APIs
- **Include usage examples** where helpful
- **Document complex algorithms** with comments
- **Update README** for significant changes

### Documentation Style
```swift
/// Creates a new application record with the specified details.
///
/// - Parameters:
///   - professorName: The name of the professor or supervisor
///   - university: The target university name
///   - deadline: Optional application deadline
/// - Returns: A new ApplicationRecord instance
/// - Note: The record is automatically assigned a unique ID
func createApplication(
    professorName: String,
    university: String,
    deadline: Date? = nil
) -> ApplicationRecord {
    // Implementation
}
```

## 🎨 Design Contributions

### UI/UX Guidelines
- **Follow macOS Human Interface Guidelines**
- **Maintain consistency** with existing design patterns
- **Consider accessibility** (VoiceOver, contrast, sizing)
- **Test on different screen sizes** and resolutions

### Design Assets
- **Use SF Symbols** when possible for icons
- **Maintain color consistency** with system themes
- **Provide dark mode variants** for custom assets
- **Include high-resolution versions** (@2x, @3x)

## 🌐 Localization

### Adding Translations
- Use Xcode's localization tools
- Test right-to-left language support
- Consider cultural differences in date/time formats
- Validate translations with native speakers

## 📋 Review Process

### What We Look For
- **Code quality** and adherence to guidelines
- **Test coverage** for new functionality
- **Documentation** completeness
- **Performance** impact assessment
- **Accessibility** considerations

### Review Timeline
- Initial review within 48-72 hours
- Feedback and iteration as needed
- Final approval and merge

## 🙏 Recognition

Contributors are recognized in:
- **Contributors section** of README
- **Release notes** for significant contributions
- **Special thanks** in app about section

## ❓ Questions?

- **GitHub Discussions**: General questions and ideas
- **GitHub Issues**: Bug reports and feature requests
- **Code Review**: Comments on pull requests

---

Thank you for contributing to GradKit Pro! Your efforts help make PhD applications more manageable for students worldwide.