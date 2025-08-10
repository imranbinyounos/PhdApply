# Quick Reference - GradKit Pro

## 🚀 Quick Start
1. **Download** from [Releases](../../releases)
2. **Install** by dragging to Applications
3. **Launch** and start with Dashboard
4. **Add** your first professor or university

## 📊 Application Status Flow
```
Researching → Drafting Email → Contacted → Awaiting Response 
    ↓
Interview Scheduled → Submitted → Accepted/Rejected
```

## ⌨️ Essential Keyboard Shortcuts
| Action | Shortcut |
|--------|----------|
| Dashboard | ⌘1 |
| Universities | ⌘2 |
| Professors | ⌘3 |
| Scholarships | ⌘4 |
| New Record | ⌘N |
| Search | ⌘F |
| Export Data | ⌘E |
| Import Data | ⌘I |

## 📁 CSV Import Format
```csv
Professor Name,Email,University,Department,Interests,Deadline,Status,Stage,Priority,ColorHex,Notes,Links
```

**Required Fields:** Professor Name, Email, University
**Date Format:** YYYY-MM-DD (ISO 8601)
**Links Format:** "Title:URL | Title:URL"

## 🎯 Priority Levels
- **5**: Top choice, perfect fit
- **4**: Strong candidate, good fit
- **3**: Solid option, consider applying
- **2**: Backup option, apply if time permits
- **1**: Low priority, uncertain fit

## 🎨 Color Coding Examples
- **#FF6B6B** (Red): High priority/urgent
- **#4ECDC4** (Teal): Interview scheduled
- **#45B7D1** (Blue): Contacted, awaiting response
- **#96CEB4** (Green): Accepted/positive
- **#FECA57** (Yellow): Submitted/pending
- **#FF9FF3** (Pink): Rejected/declined

## 📋 Common Workflows

### Initial Research Phase
1. Add professor with basic info
2. Set status to "Researching"
3. Add research interests and notes
4. Include relevant links (papers, lab website)
5. Set priority level

### Contact Phase
1. Update status to "Drafting Email"
2. Add interaction log with email draft
3. Change to "Contacted" when sent
4. Set follow-up reminders

### Application Phase
1. Update to "Submitted" when complete
2. Log all interactions and communications
3. Track deadlines and requirements
4. Monitor for responses

## 🔧 Troubleshooting Quick Fixes

| Problem | Solution |
|---------|----------|
| App won't launch | Check macOS version (13.0+ required) |
| Data not saving | Verify disk space and permissions |
| CSV import fails | Check file encoding (UTF-8) and format |
| Performance slow | Restart app, enable performance mode |
| Search not working | Clear search filters, try specific terms |

## 📚 Documentation Links
- **[Full README](README.md)** - Complete overview and features
- **[Installation Guide](INSTALLATION.md)** - Setup and configuration
- **[User Guide](docs/USER_GUIDE.md)** - Detailed tutorials
- **[API Documentation](docs/API.md)** - Developer reference
- **[Contributing](CONTRIBUTING.md)** - How to contribute

## 🆘 Getting Help
- **[GitHub Issues](../../issues)** - Bug reports and feature requests
- **[Discussions](../../discussions)** - Community support
- **[Wiki](../../wiki)** - Additional documentation

## 📊 Sample Data Structure
```json
{
  "professorName": "Dr. Sarah Johnson",
  "email": "s.johnson@stanford.edu",
  "university": "Stanford University",
  "department": "Computer Science",
  "researchInterests": "Machine Learning and AI Ethics",
  "deadline": "2024-12-01",
  "status": "Contacted",
  "priority": 5,
  "notes": "Research aligns perfectly with my interests"
}
```

## 🔄 Backup Strategy
1. **Regular Exports**: Weekly CSV exports
2. **Time Machine**: Automatic macOS backups
3. **Cloud Storage**: Store exports in cloud
4. **Version Control**: Track changes over time

---

*Keep this reference handy while using GradKit Pro. For detailed information, refer to the complete documentation.*