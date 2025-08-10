# GradKit Pro - Installation & Setup Guide

## System Requirements

### Minimum Requirements
- **Operating System**: macOS 13.0 (Ventura) or later
- **Architecture**: Apple Silicon (M1/M2/M3) or Intel x64
- **Memory**: 4GB RAM minimum, 8GB recommended
- **Storage**: 100MB available disk space
- **Display**: 1280x800 minimum resolution

### Recommended Configuration
- **Operating System**: macOS 14.0 (Sonoma) or later
- **Architecture**: Apple Silicon (M1/M2/M3) for optimal performance
- **Memory**: 8GB+ RAM for large datasets
- **Storage**: 1GB+ available for data and backups
- **Display**: 1920x1080 or higher for optimal viewing

## Installation Methods

### Method 1: Direct Download (Recommended)
1. Visit the [Releases](../../releases) page
2. Download the latest `GradKitPro-vX.X.X.dmg` file
3. Double-click the downloaded `.dmg` file
4. Drag **GradKit Pro** to your **Applications** folder
5. Eject the disk image
6. Launch from Applications folder

### Method 2: Build from Source
```bash
# Clone the repository
git clone https://github.com/imranbinyounos/PhdApply.git
cd PhdApply

# Open in Xcode
open "PhdApply Final code/PhdApply.xcodeproj"

# Build and run from Xcode
# Product → Run (⌘R)
```

## First Launch Setup

### Initial Configuration
1. **Launch GradKit Pro** from your Applications folder
2. **Grant Permissions** if prompted for notifications or file access
3. **Choose Theme**: Select Light or Dark mode (follows system preference by default)
4. **Review Interface**: Familiarize yourself with the main sections

### Data Import (Optional)
If you have existing data in spreadsheet format:

1. **Prepare CSV File** with the following columns:
   ```
   Professor Name, Email, University, Department, Interests,
   Deadline, Status, Stage, Priority, ColorHex, Notes, Links
   ```

2. **Import Process**:
   - File → Import CSV
   - Select your prepared CSV file
   - Review imported data
   - Make any necessary adjustments

### Backup Configuration
1. **Enable Time Machine** (if not already enabled)
2. **Verify Backup Location**: `~/Library/Application Support/GradKit Pro/`
3. **Manual Backup**: File → Export → All Data (CSV)

## Configuration Options

### Application Preferences
Access via **GradKit Pro** → **Preferences** (⌘,)

#### General Settings
- **Theme**: Light, Dark, or System
- **Startup Behavior**: Last view or Dashboard
- **Notification Preferences**: Deadline alerts and reminders
- **Data Backup**: Automatic backup frequency

#### Display Options
- **Default Column Configuration**: Customize initial table view
- **Row Height**: Compact, Standard, or Large
- **Font Size**: Adjust for accessibility
- **Color Scheme**: Accent color selection

#### Advanced Settings
- **Performance**: Large dataset optimization
- **Privacy**: Data sharing preferences
- **Debugging**: Developer options (if available)

## Troubleshooting

### Common Issues

#### App Won't Launch
- **Solution 1**: Check macOS version compatibility
- **Solution 2**: Clear application cache
  ```bash
  rm -rf ~/Library/Caches/com.gradkit.pro
  ```
- **Solution 3**: Reset preferences
  ```bash
  defaults delete com.gradkit.pro
  ```

#### Data Not Saving
- **Check Permissions**: Ensure app has file system access
- **Disk Space**: Verify adequate storage available
- **Backup Restore**: Restore from Time Machine backup

#### Performance Issues
- **Memory Usage**: Restart application to clear memory
- **Large Datasets**: Enable performance optimization in preferences
- **Background Apps**: Close unnecessary applications

#### Import/Export Problems
- **CSV Format**: Verify column headers match expected format
- **File Encoding**: Ensure UTF-8 encoding
- **Data Validation**: Check for invalid dates or email formats

### Getting Help

#### Built-in Help
- **Help Menu**: GradKit Pro → Help
- **Tooltips**: Hover over interface elements
- **Keyboard Shortcuts**: View → Show Keyboard Shortcuts

#### Online Resources
- **GitHub Issues**: [Report problems](../../issues)
- **Documentation**: [Wiki pages](../../wiki)
- **Discussions**: [Community support](../../discussions)

#### Contact Support
- **Bug Reports**: Use GitHub Issues with detailed information
- **Feature Requests**: Submit enhancement requests
- **General Questions**: Use GitHub Discussions

## Advanced Setup

### Development Environment
For developers wanting to contribute:

#### Prerequisites
- **Xcode 15.0+**: Latest version recommended
- **Swift 5.9+**: Language compatibility
- **Git**: Version control access

#### Build Configuration
```bash
# Development build
xcodebuild -scheme GradKitPro -configuration Debug

# Release build  
xcodebuild -scheme GradKitPro -configuration Release
```

#### Testing
```bash
# Unit tests
xcodebuild test -scheme GradKitProTests

# UI tests
xcodebuild test -scheme GradKitProUITests
```

### Custom Deployment
For institutional or team deployment:

#### Configuration Management
- **Plist Configuration**: Customize default settings
- **Bundle Customization**: Institution-specific branding
- **Data Templates**: Pre-configured templates

#### Security Considerations
- **Code Signing**: Verify application authenticity
- **Gatekeeper**: Ensure macOS security compliance
- **Privacy**: Review data handling requirements

## Updates & Maintenance

### Automatic Updates
- **Check for Updates**: GradKit Pro → Check for Updates
- **Notification Settings**: Configure update notifications
- **Background Downloads**: Enable automatic update downloads

### Manual Updates
1. **Download Latest Version**: Visit releases page
2. **Backup Current Data**: Export all data before updating
3. **Install New Version**: Follow installation process
4. **Verify Data Migration**: Ensure all data transferred correctly

### Data Migration
Between major versions:
1. **Export Current Data**: File → Export → All Data
2. **Install New Version**: Follow installation steps
3. **Import Data**: File → Import → Select exported file
4. **Verify Integrity**: Review imported data completeness

---

*For additional installation support, please refer to our [GitHub Issues](../../issues) or [community discussions](../../discussions).*