//
//  Views.swift
//  PhdApply
//
//  Created by Assistant on 9/8/25.
//

import SwiftUI
import SwiftData
import AppKit
import UniformTypeIdentifiers

// MARK: - Column Configuration

struct ColumnConfig: Identifiable, Codable, Hashable {
    let id: String
    var title: String
    var isShown: Bool
    var width: CGFloat?

    static let `default`: [ColumnConfig] = [
        .init(id: "professorName", title: "Professor", isShown: true, width: 160),
        .init(id: "email", title: "Email", isShown: true, width: 180),
        .init(id: "universityName", title: "University", isShown: true, width: 160),
        .init(id: "department", title: "Department", isShown: true, width: 140),
        .init(id: "researchInterests", title: "Interests", isShown: false, width: 200),
        .init(id: "deadline", title: "Deadline", isShown: true, width: 120),
        .init(id: "status", title: "Status", isShown: true, width: 140),
        .init(id: "stage", title: "Stage", isShown: true, width: 160),
        .init(id: "priorityLevel", title: "Priority", isShown: true, width: 80),
        .init(id: "links", title: "Links", isShown: true, width: 120)
    ]
}

// Persist column config via AppStorage
struct ColumnConfigStorage {
    static func load() -> [ColumnConfig] {
        let raw = UserDefaults.standard.string(forKey: AppStorageKeys.shownColumns)
        if let raw, let data = raw.data(using: .utf8) {
            if let decoded = try? JSONDecoder().decode([ColumnConfig].self, from: data) {
                return decoded
            }
        }
        return ColumnConfig.default
    }

    static func save(_ configs: [ColumnConfig]) {
        if let data = try? JSONEncoder().encode(configs), let raw = String(data: data, encoding: .utf8) {
            UserDefaults.standard.set(raw, forKey: AppStorageKeys.shownColumns)
        }
    }
}

// MARK: - Main View

struct MainView: View {
    var body: some View {
        NavigationSplitView {
            SidebarView()
        } detail: {
            DashboardView()
        }
    }
}

// MARK: - Sidebar

struct SidebarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ApplicationRecord.createdAt) private var records: [ApplicationRecord]
    @State private var searchText: String = ""
    @State private var selection: ApplicationStatus? = nil

    var filtered: [ApplicationRecord] {
        records.filter { rec in
            let matchesSearch = searchText.isEmpty || rec.professorName.localizedCaseInsensitiveContains(searchText) || rec.universityName.localizedCaseInsensitiveContains(searchText)
            let matchesStatus = selection == nil || rec.status == selection
            return matchesSearch && matchesStatus
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Search", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                Menu {
                    Button("All") { selection = nil }
                    Divider()
                    ForEach(ApplicationStatus.allCases) { status in
                        Button(status.rawValue) { selection = status }
                    }
                } label: {
                    Label(selection?.rawValue ?? "Filter", systemImage: "line.3.horizontal.decrease.circle")
                }
            }
            .padding(8)

            List {
                NavigationLink(value: "dashboard") {
                    Label("Dashboard", systemImage: "rectangle.grid.2x2")
                }
                NavigationLink(value: "sheet") {
                    Label("Spreadsheet", systemImage: "tablecells")
                }
                NavigationLink(value: "kanban") {
                    Label("Kanban", systemImage: "square.grid.3x2")
                }

                Section("Statuses") {
                    ForEach(ApplicationStatus.allCases) { st in
                        let count = records.filter { $0.status == st }.count
                        HStack {
                            Text(st.rawValue)
                            Spacer()
                            Text("\(count)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Records") {
                    ForEach(filtered) { rec in
                        NavigationLink(value: rec.id) {
                            VStack(alignment: .leading) {
                                Text(rec.professorName.isEmpty ? "Untitled" : rec.professorName)
                                    .font(.headline)
                                Text("\(rec.universityName) — \(rec.department)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationDestination(for: String.self) { key in
                switch key {
                case "dashboard": DashboardView()
                case "sheet": SpreadsheetView()
                case "kanban": KanbanView()
                default: DashboardView()
                }
            }
            .navigationDestination(for: UUID.self) { _ in
                SpreadsheetView()
            }

            HStack {
                Button {
                    let rec = ApplicationRecord(professorName: "", universityName: "", department: "")
                    modelContext.insert(rec)
                } label: { Label("New", systemImage: "plus") }

                Button {
                    let data = CSVService.export(records: records)
                    let panel = NSSavePanel()
                    panel.allowedContentTypes = [.commaSeparatedText]
                    panel.nameFieldStringValue = "PhdApply.csv"
                    if panel.runModal() == .OK, let url = panel.url {
                        try? data.write(to: url)
                    }
                } label: { Label("Export CSV", systemImage: "square.and.arrow.up") }

                Button {
                    let panel = NSOpenPanel()
                    panel.allowedContentTypes = [.commaSeparatedText]
                    panel.allowsMultipleSelection = false
                    if panel.runModal() == .OK, let url = panel.url, let data = try? Data(contentsOf: url) {
                        let imported = CSVService.import(data: data)
                        imported.forEach { modelContext.insert($0) }
                    }
                } label: { Label("Import CSV", systemImage: "square.and.arrow.down") }
            }
            .padding(8)
        }
    }
}

// MARK: - Dashboard

struct DashboardView: View {
    @Query private var records: [ApplicationRecord]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("PhdApply Dashboard")
                    .font(.largeTitle)
                    .bold()

                HStack(spacing: 16) {
                    StatCard(title: "Total", value: records.count.description, color: .accentColor)
                    StatCard(title: "Contacted", value: records.filter { $0.status == .contacted }.count.description, color: .blue)
                    StatCard(title: "Submitted", value: records.filter { $0.status == .submitted }.count.description, color: .green)
                    StatCard(title: "Upcoming (30d)", value: records.filter { ($0.daysUntilDeadline ?? 9999) <= 30 && ($0.daysUntilDeadline ?? -9999) >= 0 }.count.description, color: .orange)
                }

                DeadlineTimeline(records: records)
                    .frame(height: 220)
                    .padding(.vertical, 8)
            }
            .padding(16)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.headline)
            Text(value).font(.system(size: 28, weight: .bold))
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(color.opacity(0.15)))
    }
}

struct DeadlineTimeline: View {
    let records: [ApplicationRecord]
    var body: some View {
        GeometryReader { geo in
            let upcoming = records.compactMap { rec -> (ApplicationRecord, Int)? in
                guard let days = rec.daysUntilDeadline else { return nil }
                return (rec, days)
            }.sorted { $0.1 < $1.1 }.prefix(12)

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(upcoming.enumerated()), id: \.0) { _, tup in
                    let rec = tup.0
                    let days = max(0, tup.1)
                    let height = max(12, CGFloat(200 - min(days, 200)))
                    VStack {
                        Text("\(days)d")
                            .font(.caption)
                        RoundedRectangle(cornerRadius: 6)
                            .fill((Color(hex: rec.colorHex ?? "") ?? .accentColor).opacity(0.8))
                            .frame(width: 24, height: height)
                        Text(rec.universityName)
                            .font(.caption2)
                            .lineLimit(1)
                            .frame(width: 60)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
    }
}

// MARK: - Spreadsheet (Excel-like)

struct SpreadsheetView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ApplicationRecord.createdAt) private var records: [ApplicationRecord]
    @State private var configs: [ColumnConfig] = ColumnConfigStorage.load()
    @State private var sortKey: String = "deadline"
    @State private var isAscending: Bool = true
    @State private var sheetKind: SheetKind = .applications

    private var visibleColumns: [ColumnConfig] { configs.filter { $0.isShown } }

    var body: some View {
        VStack(spacing: 8) {
            Picker("", selection: $sheetKind) {
                Text("Applications").tag(SheetKind.applications)
                Text("Professors").tag(SheetKind.professors)
                Text("Universities").tag(SheetKind.universities)
            }
            .pickerStyle(.segmented)

            // Toolbar
            HStack(spacing: 12) {
                if sheetKind == .applications {
                    Button { addRow() } label: { Label("New Row", systemImage: "plus") }
                    Menu("Columns") {
                        ForEach($configs) { $cfg in
                            Toggle(cfg.title, isOn: $cfg.isShown)
                        }
                        Divider()
                        Button("Reset") { configs = ColumnConfig.default }
                    }
                    Button { ColumnConfigStorage.save(configs) } label: { Label("Save Layout", systemImage: "checkmark.seal") }
                    Divider()
                    Picker("Sort", selection: $sortKey) {
                        ForEach(configs.map(\.id), id: \.self) { key in
                            Text(titleFor(key)).tag(key)
                        }
                    }.pickerStyle(.menu)
                    Toggle("Asc", isOn: $isAscending)
                } else if sheetKind == .professors {
                    Button { addProfessor() } label: { Label("Add Professor", systemImage: "plus") }
                } else if sheetKind == .universities {
                    Button { addUniversity() } label: { Label("Add University", systemImage: "plus") }
                }
                Spacer()
                ExportImportButtons(records: records, onImport: { imported in
                    imported.forEach { modelContext.insert($0) }
                })
            }

            // Grid
            Group {
                switch sheetKind {
                case .applications:
                    ScrollView([.horizontal, .vertical]) {
                        VStack(alignment: .leading, spacing: 0) {
                            HStack(spacing: 1) {
                                ForEach(visibleColumns) { col in
                                    Text(titleFor(col.id))
                                        .font(.subheadline.bold())
                                        .frame(width: col.width ?? defaultWidth(for: col.id), alignment: .leading)
                                        .padding(6)
                                        .background(.quaternary)
                                        .contextMenu {
                                            Button("Hide Column") { toggleColumn(col.id, false) }
                                            Button("Move Left") { moveColumn(col.id, -1) }
                                            Button("Move Right") { moveColumn(col.id, 1) }
                                        }
                                }
                                Spacer(minLength: 0)
                            }
                            .background(.thinMaterial)

                            LazyVStack(alignment: .leading, spacing: 1) {
                                ForEach(filteredAndSorted(records)) { rec in
                                    SpreadsheetRow(record: rec, columns: visibleColumns)
                                        .background(Color(NSColor.textBackgroundColor))
                                }
                            }
                        }
                        .padding(1)
                    }
                case .professors:
                    ProfessorSheet(records: records, updateAll: updateProfessorFields)
                case .universities:
                    UniversitySheet(records: records, updateAll: updateUniversityFields)
                }
            }
        }
        .padding(8)
    }

    private func addRow() {
        let rec = ApplicationRecord()
        modelContext.insert(rec)
    }

    private func toggleColumn(_ id: String, _ show: Bool) { if let idx = configs.firstIndex(where: { $0.id == id }) { configs[idx].isShown = show } }
    private func moveColumn(_ id: String, _ delta: Int) {
        guard let idx = configs.firstIndex(where: { $0.id == id }) else { return }
        var newIdx = idx + delta
        newIdx = max(0, min(configs.count - 1, newIdx))
        guard newIdx != idx else { return }
        let item = configs.remove(at: idx)
        configs.insert(item, at: newIdx)
    }

    private func titleFor(_ id: String) -> String { configs.first(where: { $0.id == id })?.title ?? id }
    private func defaultWidth(for id: String) -> CGFloat {
        switch id {
        case "professorName", "universityName": return 180
        case "email": return 200
        case "researchInterests": return 240
        case "deadline": return 140
        case "status", "stage": return 160
        case "department": return 160
        case "priorityLevel": return 100
        default: return 140
        }
    }

    private func filteredAndSorted(_ arr: [ApplicationRecord]) -> [ApplicationRecord] {
        let sorted: [ApplicationRecord] = arr.sorted { a, b in
            func key(_ r: ApplicationRecord) -> ComparableWrapper {
                switch sortKey {
                case "professorName": return .string(r.professorName)
                case "email": return .string(r.email)
                case "universityName": return .string(r.universityName)
                case "department": return .string(r.department)
                case "researchInterests": return .string(r.researchInterests)
                case "deadline": return .date(r.deadline)
                case "status": return .string(r.statusRaw)
                case "stage": return .string(r.stageRaw)
                case "priorityLevel": return .int(r.priorityLevel)
                default: return .date(r.createdAt)
                }
            }
            let ka = key(a), kb = key(b)
            return isAscending ? ka < kb : kb < ka
        }
        return sorted
    }

    private func addProfessor() {
        let rec = ApplicationRecord(professorName: "New Professor")
        modelContext.insert(rec)
    }

    private func addUniversity() {
        let rec = ApplicationRecord(universityName: "New University")
        modelContext.insert(rec)
    }

    private func updateProfessorFields(originalName: String, newName: String?, newEmail: String?, newInterests: String?) {
        for rec in records where rec.professorName.caseInsensitiveCompare(originalName) == .orderedSame {
            if let newName { rec.professorName = newName }
            if let newEmail { rec.email = newEmail }
            if let newInterests { rec.researchInterests = newInterests }
        }
    }

    private func updateUniversityFields(originalName: String, newName: String?) {
        for rec in records where rec.universityName.caseInsensitiveCompare(originalName) == .orderedSame {
            if let newName { rec.universityName = newName }
        }
    }
}

enum SheetKind: Hashable {
    case applications, professors, universities
}

private struct ProfessorSheet: View {
    let records: [ApplicationRecord]
    let updateAll: (_ originalName: String, _ newName: String?, _ newEmail: String?, _ newInterests: String?) -> Void

    struct Row: Identifiable {
        var id: String { originalKey }
        let originalKey: String
        var name: String
        var email: String
        var interests: String
        var count: Int
    }

    var rows: [Row] {
        let grouped = Dictionary(grouping: records, by: { $0.professorName.isEmpty ? "(Untitled)" : $0.professorName })
        return grouped.map { (key, recs) in
            let firstEmail = recs.first(where: { !$0.email.isEmpty })?.email ?? ""
            let firstInterests = recs.first(where: { !$0.researchInterests.isEmpty })?.researchInterests ?? ""
            return Row(originalKey: key, name: key, email: firstEmail, interests: firstInterests, count: recs.count)
        }.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    @State private var edited: [String: Row] = [:]

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 1) {
                    headerCell("Professor", width: 220)
                    headerCell("Email", width: 240)
                    headerCell("Interests", width: 300)
                    headerCell("Count", width: 80)
                    Spacer(minLength: 0)
                }
                .background(.thinMaterial)

                LazyVStack(alignment: .leading, spacing: 1) {
                    ForEach(rows) { row in
                        let bind = Binding<Row>(
                            get: { edited[row.id] ?? row },
                            set: { edited[row.id] = $0 }
                        )
                        HStack(spacing: 1) {
                            TextField("Professor", text: Binding(get: { bind.wrappedValue.name }, set: { bind.wrappedValue.name = $0 }))
                                .frame(width: 220, alignment: .leading)
                                .padding(6)
                            TextField("Email", text: Binding(get: { bind.wrappedValue.email }, set: { bind.wrappedValue.email = $0 }))
                                .frame(width: 240, alignment: .leading)
                                .padding(6)
                            TextField("Interests", text: Binding(get: { bind.wrappedValue.interests }, set: { bind.wrappedValue.interests = $0 }))
                                .frame(width: 300, alignment: .leading)
                                .padding(6)
                            Text("\(row.count)")
                                .frame(width: 80, alignment: .trailing)
                                .padding(6)
                            Button("Apply") { apply(row: bind.wrappedValue) }
                                .buttonStyle(.bordered)
                            Spacer(minLength: 0)
                        }
                        .background(Color(NSColor.textBackgroundColor))
                    }
                }
            }
            .padding(1)
        }
    }

    private func headerCell(_ title: String, width: CGFloat) -> some View {
        Text(title).font(.subheadline.bold()).frame(width: width, alignment: .leading).padding(6).background(.quaternary)
    }

    private func apply(row: Row) {
        updateAll(row.originalKey, row.name, row.email, row.interests)
    }
}

private struct UniversitySheet: View {
    let records: [ApplicationRecord]
    let updateAll: (_ originalName: String, _ newName: String?) -> Void

    struct Row: Identifiable {
        var id: String { originalKey }
        let originalKey: String
        var name: String
        var count: Int
    }

    var rows: [Row] {
        let grouped = Dictionary(grouping: records, by: { $0.universityName.isEmpty ? "(Untitled)" : $0.universityName })
        return grouped.map { (key, recs) in
            Row(originalKey: key, name: key, count: recs.count)
        }.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    @State private var edited: [String: Row] = [:]

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 1) {
                    headerCell("University", width: 280)
                    headerCell("Count", width: 80)
                    Spacer(minLength: 0)
                }
                .background(.thinMaterial)

                LazyVStack(alignment: .leading, spacing: 1) {
                    ForEach(rows) { row in
                        let bind = Binding<Row>(
                            get: { edited[row.id] ?? row },
                            set: { edited[row.id] = $0 }
                        )
                        HStack(spacing: 1) {
                            TextField("University", text: Binding(get: { bind.wrappedValue.name }, set: { bind.wrappedValue.name = $0 }))
                                .frame(width: 280, alignment: .leading)
                                .padding(6)
                            Text("\(row.count)")
                                .frame(width: 80, alignment: .trailing)
                                .padding(6)
                            Button("Apply") { apply(row: bind.wrappedValue) }
                                .buttonStyle(.bordered)
                            Spacer(minLength: 0)
                        }
                        .background(Color(NSColor.textBackgroundColor))
                    }
                }
            }
            .padding(1)
        }
    }

    private func headerCell(_ title: String, width: CGFloat) -> some View {
        Text(title).font(.subheadline.bold()).frame(width: width, alignment: .leading).padding(6).background(.quaternary)
    }

    private func apply(row: Row) {
        updateAll(row.originalKey, row.name)
    }
}

private struct ExportImportButtons: View {
    var records: [ApplicationRecord]
    var onImport: ([ApplicationRecord]) -> Void
    var body: some View {
        HStack(spacing: 8) {
            Button {
                let data = CSVService.export(records: records)
                let panel = NSSavePanel()
                panel.allowedContentTypes = [.commaSeparatedText]
                panel.nameFieldStringValue = "PhdApply.csv"
                if panel.runModal() == .OK, let url = panel.url { try? data.write(to: url) }
            } label: { Label("Export", systemImage: "square.and.arrow.up") }

            Button {
                let panel = NSOpenPanel()
                panel.allowedContentTypes = [.commaSeparatedText]
                if panel.runModal() == .OK, let url = panel.url, let data = try? Data(contentsOf: url) {
                    let imported = CSVService.import(data: data)
                    onImport(imported)
                }
            } label: { Label("Import", systemImage: "square.and.arrow.down") }
        }
    }
}

private struct SpreadsheetRow: View {
    @Bindable var record: ApplicationRecord
    let columns: [ColumnConfig]

    var body: some View {
        HStack(spacing: 1) {
            ForEach(columns) { col in
                cell(for: col.id)
                    .frame(width: col.width ?? 140, alignment: .leading)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(.background)
                    .overlay(Rectangle().fill(Color.gray.opacity(0.15)).frame(width: 1), alignment: .trailing)
            }
            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private func cell(for id: String) -> some View {
        switch id {
        case "professorName": TextField("Professor", text: $record.professorName)
        case "email": HStack { TextField("Email", text: $record.email); Button { EmailService.composeEmail(to: record.email, subject: "PhD Inquiry", body: "Dear Professor,") } label: { Image(systemName: "envelope").foregroundStyle(.blue) } .buttonStyle(.borderless) }
        case "universityName": TextField("University", text: $record.universityName)
        case "department": TextField("Department", text: $record.department)
        case "researchInterests": TextField("Interests", text: $record.researchInterests)
        case "deadline": DeadlineEditorCell(record: record)
        case "status": Picker("", selection: Binding(get: { record.status }, set: { record.status = $0 })) { ForEach(ApplicationStatus.allCases) { Text($0.rawValue).tag($0) } }.labelsHidden()
        case "stage": Picker("", selection: Binding(get: { record.stage }, set: { record.stage = $0 })) { ForEach(ApplicationStatus.allCases) { Text($0.rawValue).tag($0) } }.labelsHidden()
        case "priorityLevel": Stepper(value: $record.priorityLevel, in: 0...5) { Text("\(record.priorityLevel)") }
        case "links": LinksCell(record: record)
        default: Text("—").foregroundStyle(.secondary)
        }
    }
}

private struct DeadlineEditorCell: View {
    @Bindable var record: ApplicationRecord
    var body: some View {
        HStack(spacing: 6) {
            if let _ = record.deadline {
                DatePicker("", selection: Binding(get: { record.deadline ?? Date() }, set: { record.deadline = $0 }), displayedComponents: [.date])
                    .labelsHidden()
                Text("\(record.daysUntilDeadline ?? 0)d")
                    .foregroundStyle((record.daysUntilDeadline ?? 999) <= 7 ? .red : (record.daysUntilDeadline ?? 999) <= 15 ? .orange : .secondary)
                Button { record.deadline = nil } label: { Image(systemName: "xmark.circle") }
                    .buttonStyle(.borderless)
            } else {
                Button("Set Date") { record.deadline = Date() }
            }
        }
    }
}

private struct LinksCell: View {
    @Bindable var record: ApplicationRecord
    @State private var newTitle: String = ""
    @State private var newURL: String = ""
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                TextField("Title", text: $newTitle)
                TextField("URL", text: $newURL)
                Button { addLink() } label: { Image(systemName: "plus.circle") }
                    .buttonStyle(.borderless)
            }
            ScrollView(.horizontal) {
                HStack(spacing: 6) {
                    ForEach(record.links) { link in
                        Button(link.title.isEmpty ? "Link" : link.title) {
                            if let url = URL.from(link.urlString) { NSWorkspace.shared.open(url) }
                        }
                        .buttonStyle(.bordered)
                        .contextMenu {
                            Button("Delete") { delete(link) }
                        }
                    }
                }
            }
        }
    }
    private func addLink() { guard !newURL.isEmpty else { return }; record.links.append(LinkItem(title: newTitle.isEmpty ? "Link" : newTitle, urlString: newURL)); newTitle = ""; newURL = "" }
    private func delete(_ link: LinkItem) { if let idx = record.links.firstIndex(where: { $0.id == link.id }) { record.links.remove(at: idx) } }
}

enum ComparableWrapper: Comparable {
    case string(String)
    case int(Int)
    case date(Date?)

    static func < (lhs: ComparableWrapper, rhs: ComparableWrapper) -> Bool {
        switch (lhs, rhs) {
        case let (.string(a), .string(b)): return a.localizedCaseInsensitiveCompare(b) == .orderedAscending
        case let (.int(a), .int(b)): return a < b
        case let (.date(a), .date(b)):
            switch (a, b) {
            case (nil, nil): return false
            case (nil, _): return true
            case (_, nil): return false
            case let (a?, b?): return a < b
            }
        default: return false
        }
    }
}

struct RowCell: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var record: ApplicationRecord
    var body: some View {
        HStack(spacing: 6) {
            Circle().fill((Color(hex: record.colorHex ?? "") ?? .accentColor)).frame(width: 8, height: 8)
            TextField("Professor", text: $record.professorName)
            Button("Links (\(record.links.count))") {
                // no-op placeholder
            }
        }
    }
}

struct EmailCell: View {
    var email: String
    var body: some View {
        HStack {
            Text(email).lineLimit(1)
            Spacer()
            Button {
                EmailService.composeEmail(to: email, subject: "PhD Inquiry", body: "Dear Professor,")
            } label: { Image(systemName: "envelope") }
            .buttonStyle(.borderless)
        }
    }
}

struct DeadlineCell: View {
    let record: ApplicationRecord
    var body: some View {
        HStack {
            if let d = record.deadline {
                let days = record.daysUntilDeadline ?? 0
                Text(d.formattedDate())
                Text("(\(days)d)")
                    .foregroundStyle(days <= 7 ? .red : days <= 15 ? .orange : .secondary)
            } else {
                Text("–")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct StatusMenu: View {
    @Bindable var record: ApplicationRecord
    var body: some View {
        Menu(record.status.rawValue) {
            ForEach(ApplicationStatus.allCases) { st in
                Button(st.rawValue) { record.status = st }
            }
        }
    }
}

struct StageMenu: View {
    @Bindable var record: ApplicationRecord
    var body: some View {
        Menu(record.stage.rawValue) {
            ForEach(ApplicationStatus.allCases) { st in
                Button(st.rawValue) { record.stage = st }
            }
        }
    }
}

struct PriorityStepper: View {
    @Bindable var record: ApplicationRecord
    var body: some View {
        Stepper(value: $record.priorityLevel, in: 0...5) {
            Text("\(record.priorityLevel)")
        }
    }
}

// MARK: - Kanban

struct KanbanView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var records: [ApplicationRecord]
    @State private var dragging: ApplicationRecord?

    private var grouped: [(ApplicationStatus, [ApplicationRecord])] {
        ApplicationStatus.allCases.map { status in
            (status, records.filter { $0.stage == status }.sorted { ($0.priorityLevel, $0.createdAt) > ($1.priorityLevel, $1.createdAt) })
        }
    }

    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 16) {
                ForEach(grouped, id: \.0) { status, items in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(status.rawValue).bold()
                            Spacer()
                            Text("\(items.count)").foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 8)

                        VStack(spacing: 8) {
                            ForEach(items) { rec in
                                KanbanCard(record: rec)
                                    .onDrag {
                                        dragging = rec
                                        return NSItemProvider(object: rec.id.uuidString as NSString)
                                    }
                            }
                        }
                        .padding(8)
                        .frame(width: 260)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.1)))
                        .onDrop(of: [.text], isTargeted: nil) { providers in
                            guard let dragging else { return false }
                            dragging.stage = status
                            self.dragging = nil
                            return true
                        }
                    }
                }
            }
            .padding(16)
        }
    }
}

struct KanbanCard: View {
    @Bindable var record: ApplicationRecord
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(record.professorName.isEmpty ? "Untitled" : record.professorName)
                    .font(.headline)
                Spacer()
                Circle().fill((Color(hex: record.colorHex ?? "") ?? .accentColor)).frame(width: 8, height: 8)
            }
            Text("\(record.universityName) — \(record.department)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if let days = record.daysUntilDeadline { Text("Due in \(days)d").font(.caption) }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 10).fill(.background).shadow(radius: 1))
    }
}


