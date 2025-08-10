import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct GradKitProMainView: View {
    @StateObject private var store = GradKitStore()
    @State private var active: GradKitSection? = .professors

    var body: some View {
        VStack(spacing: 16) {
            header
            nav
            if let active {
                SectionEditorView(section: active)
                    .environmentObject(store)
            } else {
                HStack { // center dashboard horizontally
                    Spacer()
                    DashboardViewGK()
                        .environmentObject(store)
                        .frame(maxWidth: 1200)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .foregroundColor(store.darkMode ? .white : .primary)
        .environment(\.colorScheme, store.darkMode ? .dark : .light)
        .background(store.darkMode ? Color(red: 17/255, green: 24/255, blue: 39/255) : Color(NSColor.windowBackgroundColor))
    }

    private var header: some View {
        HStack {
            Text("GradKit Pro").font(.system(size: 28, weight: .bold))
            Spacer()
            Button(store.darkMode ? "Light Mode" : "Dark Mode") { store.darkMode.toggle() }
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: 1400)
        .frame(maxWidth: .infinity)
    }

    private var nav: some View {
        HStack(spacing: 12) {
            ForEach(["dashboard", GradKitSection.universities.rawValue, GradKitSection.professors.rawValue, GradKitSection.scholarships.rawValue], id: \.self) { key in
                Button(key.capitalized) {
                    if key == "dashboard" { active = nil } else { active = GradKitSection(rawValue: key) }
                }
                .buttonStyle(.borderedProminent)
                .tint(active?.rawValue == key ? .blue : .gray)
            }
            Spacer()
        }
        .frame(maxWidth: 1400)
        .frame(maxWidth: .infinity)
    }
}

struct SectionEditorView: View {
    @EnvironmentObject var store: GradKitStore
    let section: GradKitSection
    @State private var filterText: String = ""
    @State private var sortKey: String? = nil
    @State private var sortAsc: Bool = true
    @State private var showColumnsManager: Bool = false
    @State private var managerHeight: CGFloat = 0

    var body: some View {
        let data = store.data(for: section)
        let theme = Theme(dark: store.darkMode)
        return VStack(alignment: .leading, spacing: 6) {
            controlBar(data: data, theme: theme)
            ZStack(alignment: .topLeading) {
                // Table sits directly under the control bar. When the manager opens,
                // we push the table down by the measured manager height so it looks
                // like it slides the table.
                table(data: data, theme: theme)
                    .padding(.top, showColumnsManager ? (managerHeight + 8) : 0)

                if showColumnsManager {
                    columnManager(data: data, theme: theme)
                        .background(theme.rowBgEven.opacity(0.6))
                        .overlay(
                            GeometryReader { proxy in
                                Color.clear
                                    .preference(key: ColumnsManagerHeightKey.self, value: proxy.size.height)
                            }
                        )
                }
            }
            .onPreferenceChange(ColumnsManagerHeightKey.self) { h in managerHeight = h }
        }
        .frame(maxWidth: 1400)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .foregroundColor(store.darkMode ? .white : .primary)
    }

    private func controlBar(data: SectionData, theme: Theme) -> some View {
        HStack(spacing: 12) {
            TextField("Search/filter rows...", text: $filterText)
                .textFieldStyle(.roundedBorder)
                .padding(.vertical, 2)
                .background(theme.inputBg)
                .cornerRadius(6)
                .foregroundColor(store.darkMode ? .white : .primary)
            Button("+ Add Row") { store.addRow(section) }.buttonStyle(.borderedProminent).tint(.blue)
            Button("+ Add Column") { store.addColumn(section) }.buttonStyle(.borderedProminent).tint(.green)
            Button(action: { withAnimation { showColumnsManager.toggle() } }) {
                Label("Manage Columns", systemImage: showColumnsManager ? "chevron.down" : "chevron.right")
            }
            Spacer()
        }
        .padding(.bottom, 0)
    }

    private func columnManager(data: SectionData, theme: Theme) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 8) {
                GridRow { Text("Column Name").bold(); Text("Type").bold(); Text("Actions").bold() }
                ForEach(Array(data.columns.enumerated()), id: \.0) { idx, col in
                    GridRow {
                        TextField("Name", text: Binding(
                            get: { col.name },
                            set: { store.updateColumn(section, index: idx, key: "name", value: $0) }
                        ))
                        .textFieldStyle(.roundedBorder)
                        .foregroundColor(store.darkMode ? .white : .primary)
                        Picker("Type", selection: Binding(
                            get: { col.type.rawValue },
                            set: { store.updateColumn(section, index: idx, key: "type", value: $0) }
                        )) {
                            ForEach(ColumnType.allCases, id: \.self) { t in
                                Text(t.rawValue.capitalized).tag(t.rawValue)
                            }
                        }.pickerStyle(.menu)
                        Button("Delete") { store.deleteColumn(section, index: idx) }
                            .buttonStyle(.bordered)
                            .tint(.red)
                    }
                }
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 8).fill(store.darkMode ? Color.white.opacity(0.06) : Color.secondary.opacity(0.1)))
    }

    private func table(data: SectionData, theme: Theme) -> some View {
        let rows = filteredSortedRows(data)
        let deadlineCol = data.columns.first { $0.type == .date && $0.name.lowercased() == "deadline" }
        let hasRemainingDays = deadlineCol != nil
        let statusCol: ColumnDef? = data.columns.first { $0.type == .status }
        let nonStatusColumns: [ColumnDef] = data.columns.filter { $0.type != .status }
        return ScrollView([.horizontal, .vertical]) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 1) {
                    ForEach(nonStatusColumns, id: \.self) { col in
                        Button(action: { onSort(col.name) }) {
                            HStack {
                                Text(col.name)
                                if sortKey == col.name { Text(sortAsc ? "▲" : "▼") }
                            }
                            .frame(minWidth: 160, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                        .padding(8)
                             .background(theme.headerBg)
                             .foregroundColor(store.darkMode ? .white : .primary)
                    }
                    if statusCol != nil {
                        Text("Status")
                            .frame(minWidth: 140, alignment: .leading)
                            .padding(8)
                            .background(theme.headerBg)
                            .foregroundColor(store.darkMode ? .white : .primary)
                    }
                    if hasRemainingDays {
                        Text("Remaining Days")
                            .frame(minWidth: 140, alignment: .center)
                            .padding(8)
                            .background(theme.headerBg)
                            .foregroundColor(store.darkMode ? .white : .primary)
                    }
                    Text("Actions")
                        .frame(width: 100, alignment: .center)
                        .padding(8)
                        .background(theme.headerBg)
                        .foregroundColor(store.darkMode ? .white : .primary)
                }
                ForEach(Array(rows.enumerated()), id: \.0) { idx, row in
                    HStack(spacing: 1) {
                        ForEach(nonStatusColumns, id: \.self) { col in
                            SpreadsheetInputCell(section: section, rowIndex: idx, col: col)
                                .environmentObject(store)
                                .frame(minWidth: 160)
                                .padding(6)
                                .background(idx % 2 == 0 ? theme.rowBgEven : theme.rowBgOdd)
                                .foregroundColor(store.darkMode ? .white : .primary)
                        }
                        if let statusCol {
                            SpreadsheetInputCell(section: section, rowIndex: idx, col: statusCol)
                                .environmentObject(store)
                                .frame(minWidth: 140)
                                .padding(6)
                                .background(idx % 2 == 0 ? theme.rowBgEven : theme.rowBgOdd)
                                .foregroundColor(store.darkMode ? .white : .primary)
                        }
                        if hasRemainingDays {
                            let val = row[deadlineCol!.name] ?? ""
                            let days = daysUntilString(val)
                            Text(days.map { "\($0)" } ?? "")
                                .frame(minWidth: 140, alignment: .center)
                                .padding(6)
                                .foregroundColor((days ?? 999) <= 7 ? .red : (store.darkMode ? .white.opacity(0.8) : .secondary))
                        }
                        Button("Delete") { store.deleteRow(section, rowIndex: idx) }.buttonStyle(.bordered).tint(.red).frame(width: 100)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .id(section) // ensure view identity resets when switching sections
        .padding(.top, 0)
        .padding(.bottom, 0)
        .background(Color.clear)
    }

    private func filteredSortedRows(_ data: SectionData) -> [[String: String]] {
        var rows = data.rows
        if !filterText.isEmpty {
            let ft = filterText.lowercased()
            rows = rows.filter { row in
                data.columns.contains { col in
                    (row[col.name] ?? "").lowercased().contains(ft)
                }
            }
        }
        if let sortKey {
            let type = data.columns.first(where: { $0.name == sortKey })?.type
            rows.sort { a, b in
                let av = a[sortKey] ?? ""
                let bv = b[sortKey] ?? ""
                if type == .date {
                    let ad = parseDate(av)
                    let bd = parseDate(bv)
                    switch (ad, bd) {
                    case (nil, nil): return false
                    case (nil, _): return !sortAsc
                    case (_, nil): return sortAsc
                    case let (aDate?, bDate?):
                        return sortAsc ? aDate < bDate : aDate > bDate
                    }
                }
                return sortAsc ? av.localizedCaseInsensitiveCompare(bv) == .orderedAscending : av.localizedCaseInsensitiveCompare(bv) == .orderedDescending
            }
        }
        return rows
    }

    private func onSort(_ key: String) {
        if sortKey == key { sortAsc.toggle() } else { sortKey = key; sortAsc = true }
    }
}

// MARK: - Theme
private struct Theme {
    let dark: Bool
    var headerBg: Color { dark ? Color(red: 55/255, green: 65/255, blue: 81/255) : Color(red: 229/255, green: 231/255, blue: 235/255) }
    var rowBgOdd: Color { dark ? Color(red: 17/255, green: 24/255, blue: 39/255) : Color.white }
    var rowBgEven: Color { dark ? Color(red: 31/255, green: 41/255, blue: 55/255) : Color(red: 249/255, green: 250/255, blue: 251/255) }
    var inputBg: Color { dark ? Color(red: 55/255, green: 65/255, blue: 81/255) : Color.white }
}

// Preference key to measure Manage Columns height for smooth overlay animation
private struct ColumnsManagerHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// MARK: - Date Helpers (top-level, reused)
private let gkISO8601: ISO8601DateFormatter = {
    let f = ISO8601DateFormatter()
    // Keep defaults; configure explicitly if needed later
    return f
}()

private let gkSimpleDateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.locale = Locale(identifier: "en_US_POSIX")
    f.dateFormat = "yyyy-MM-dd"
    return f
}()

private func parseDate(_ str: String) -> Date? {
    if str.isEmpty { return nil }
    if let d = gkISO8601.date(from: str) { return d }
    if let d = gkSimpleDateFormatter.date(from: str) { return d }
    return nil
}

private func daysUntilString(_ str: String) -> Int? {
    guard let date = parseDate(str) else { return nil }
    let cal = Calendar.current
    let s = cal.startOfDay(for: Date())
    let e = cal.startOfDay(for: date)
    return cal.dateComponents([.day], from: s, to: e).day
}

struct SpreadsheetInputCell: View {
    @EnvironmentObject var store: GradKitStore
    let section: GradKitSection
    let rowIndex: Int
    let col: ColumnDef
    // Bind directly into the store so sections remain fully independent
    private var textBinding: Binding<String> {
        Binding<String>(
            get: {
                let data = store.data(for: section)
                guard data.rows.indices.contains(rowIndex) else { return "" }
                return data.rows[rowIndex][col.name] ?? ""
            },
            set: { newVal in
                store.updateCell(section, rowIndex: rowIndex, columnName: col.name, value: newVal)
            }
        )
    }

    var body: some View {
        switch col.type {
        case .date:
            DatePicker("", selection: Binding<Date>(get: {
                parseDate(textBinding.wrappedValue) ?? Date()
            }, set: { newDate in
                textBinding.wrappedValue = gkISO8601.string(from: newDate)
            }), displayedComponents: [.date]).labelsHidden()
        case .status:
            let options: [String] = {
                switch section {
                case .universities: return ["Not Applied", "Applied"]
                case .professors:
                    return StatusOptions.map { opt in
                        if opt == "Not Contacted" { return "Not Mailed" }
                        if opt == "Contacted" { return "Mailed" }
                        return opt
                    }
                case .scholarships: return ["Not Applied", "Applied"]
                }
            }()
            let isDone = (section == .universities && textBinding.wrappedValue == "Applied") || (section == .professors && textBinding.wrappedValue == "Mailed") || (section == .scholarships && textBinding.wrappedValue == "Applied")
            Picker("", selection: textBinding) {
                ForEach(options, id: \.self) { Text($0).tag($0) }
            }
            .labelsHidden()
            .tint(isDone ? .green : .primary)
        case .priority:
            Picker("", selection: textBinding) {
                ForEach(PriorityOptions, id: \.self) { Text($0).tag($0) }
            }.labelsHidden()
        case .link:
            HStack(spacing: 6) {
                TextField("Paste URL", text: textBinding)
                if let url = URL(string: textBinding.wrappedValue), !textBinding.wrappedValue.isEmpty {
                    Button("Link") { NSWorkspace.shared.open(url) }.buttonStyle(.borderedProminent).tint(.blue)
                }
            }
        case .notes:
            TextEditor(text: textBinding)
                .scrollContentBackground(.hidden)
                .background(Theme(dark: store.darkMode).inputBg)
                .frame(minHeight: 60)
        case .text:
            TextField(col.name, text: textBinding)
        }
    }
}

struct DashboardViewGK: View {
    @EnvironmentObject var store: GradKitStore
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Dashboard Overview")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)

                UpcomingDeadlinesViewGK()
                SectionSummariesViewGK()
            }
            .padding()
            .frame(maxWidth: 1400)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .overlay(alignment: .bottomTrailing) {
            Button {
                let data = GradKitCSVService.exportAllSectionsCSV(db: store.db)
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyyMMdd"
                let defaultName = "PhdApply-\(formatter.string(from: Date())).csv"
                let panel = NSSavePanel()
                panel.allowedContentTypes = [.commaSeparatedText]
                panel.nameFieldStringValue = defaultName
                if panel.runModal() == .OK, let url = panel.url {
                    do { try data.write(to: url) } catch { NSAlert(error: error).runModal() }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.down.circle.fill")
                    Text("Download CSV")
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .padding(16)
        }
    }
}

private struct UpcomingDeadlinesViewGK: View {
    @EnvironmentObject var store: GradKitStore

    private var upcomingDeadlines: [DeadlineItemGK] {
        var items: [DeadlineItemGK] = []
        for (sectionName, section) in [
            ("Universities", store.data(for: .universities)),
            ("Professors", store.data(for: .professors)),
            ("Scholarships", store.data(for: .scholarships))
        ] {
            if let deadlineColumn = section.columns.first(where: { $0.name.lowercased() == "deadline" && $0.type == .date }) {
                for row in section.rows {
                    // Skip completed rows based on Status
                    let status = (row["Status"] ?? "").lowercased()
                    let isDone =
                        (sectionName == "Universities" && status == "applied") ||
                        (sectionName == "Professors" && status == "mailed") ||
                        (sectionName == "Scholarships" && status == "applied")
                    if isDone { continue }
                    if let dateStr = row[deadlineColumn.name],
                       let date = parseDate(dateStr) {
                        let days = daysUntil(date)
                        if days >= 0 && days <= 30 {
                            items.append(DeadlineItemGK(
                                section: sectionName,
                                name: row["Name"] ?? "Untitled",
                                deadline: date,
                                daysLeft: days
                            ))
                        }
                    }
                }
            }
        }
        return items.sorted { $0.daysLeft < $1.daysLeft }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Upcoming Deadlines (Next 30 Days)")
                .font(.title2)
                .fontWeight(.semibold)

            if upcomingDeadlines.isEmpty {
                Text("No upcoming deadlines.")
                    .foregroundColor(.secondary)
                    .padding(.vertical)
            } else {
                Table(upcomingDeadlines) {
                    TableColumn("Section", value: \.section)
                    TableColumn("Name", value: \.name)
                    TableColumn("Deadline") { item in
                        Text(item.deadline, style: .date)
                    }.width(120)
                    TableColumn("Days Left") { item in
                        Text("\(item.daysLeft)")
                            .foregroundColor(item.daysLeft <= 7 ? .red : .primary)
                    }.width(90)
                }
                .frame(height: cardHeight)
                .cornerRadius(8)
                .shadow(radius: 3)
            }
        }
        .padding()
        .background(store.darkMode ? Color.white.opacity(0.06) : Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    private var cardHeight: CGFloat {
        let screenH = NSScreen.main?.visibleFrame.height ?? 900
        let proposed = screenH * 0.38
        return max(360, min(proposed, 640))
    }
}

private struct SectionSummariesViewGK: View {
    @EnvironmentObject var store: GradKitStore

    private var items: [SectionSummaryItemGK] {
        [
            makeSummary(for: "Universities", data: store.data(for: .universities)),
            makeSummary(for: "Professors", data: store.data(for: .professors)),
            makeSummary(for: "Scholarships", data: store.data(for: .scholarships))
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Section Summaries")
                .font(.title2)
                .fontWeight(.semibold)

            Table(items) {
                TableColumn("Section", value: \.section)
                TableColumn("Total Rows", value: \.totalRows)
                TableColumn("Status Breakdown", value: \.statusBreakdown)
                TableColumn("Priority Breakdown", value: \.priorityBreakdown)
            }
            .frame(minHeight: 120, maxHeight: 320)
            .cornerRadius(8)
            .shadow(radius: 3)
        }
        .padding()
        .background(store.darkMode ? Color.white.opacity(0.06) : Color.gray.opacity(0.1))
        .cornerRadius(12)
    }


    private func makeSummary(for sectionName: String, data: SectionData) -> SectionSummaryItemGK {
        let statusCounts = counts(in: data, for: .status)
        let priorityCounts = counts(in: data, for: .priority)
        return SectionSummaryItemGK(
            section: sectionName,
            totalRows: "\(data.rows.count)",
            statusBreakdown: statusCounts.map { "\($0.key): \($0.value)" }.joined(separator: ", "),
            priorityBreakdown: priorityCounts.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
        )
    }

    private func counts(in data: SectionData, for type: ColumnType) -> [String: Int] {
        var counts: [String: Int] = [:]
        if let col = data.columns.first(where: { $0.type == type }) {
            for row in data.rows {
                let value = row[col.name] ?? "N/A"
                counts[value, default: 0] += 1
            }
        }
        return counts
    }
}

private struct DeadlineItemGK: Identifiable {
    let id = UUID()
    let section: String
    let name: String
    let deadline: Date
    let daysLeft: Int
}

private struct SectionSummaryItemGK: Identifiable {
    let id = UUID()
    let section: String
    let totalRows: String
    let statusBreakdown: String
    let priorityBreakdown: String
}

private func daysUntil(_ date: Date) -> Int {
    let cal = Calendar.current
    let today = cal.startOfDay(for: Date())
    let target = cal.startOfDay(for: date)
    return cal.dateComponents([.day], from: today, to: target).day ?? 0
}


