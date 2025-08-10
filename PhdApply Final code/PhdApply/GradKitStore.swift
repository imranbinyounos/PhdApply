//
//  GradKitStore.swift
//  GradKit Pro
//
//  Created by Assistant on 9/8/25.
//

import Foundation
import SwiftUI

enum GradKitSection: String, CaseIterable, Identifiable, Codable {
    case universities, professors, scholarships
    var id: String { rawValue }
}

enum ColumnType: String, Codable, CaseIterable {
    case text, link, date, notes, status, priority
}

struct ColumnDef: Codable, Hashable, Identifiable {
    var id: String { name }
    var name: String
    var type: ColumnType
}

struct SectionData: Codable {
    var columns: [ColumnDef]
    var rows: [[String: String]]
}

struct GradKitDB: Codable {
    var universities: SectionData
    var professors: SectionData
    var scholarships: SectionData
}

final class GradKitStore: ObservableObject {
    @Published var db: GradKitDB {
        didSet { save() }
    }

    @AppStorage("GradKitProDarkMode") var darkMode: Bool = false

    private let storageKey = "phdapply:v3-custom-columns"

    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(GradKitDB.self, from: data) {
            db = decoded
        } else {
            db = GradKitStore.makeDefaultDB()
        }
        // Ensure mandatory columns exist even for older saved data
        migrateIfNeeded()
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(db) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    static func makeDefaultDB() -> GradKitDB {
        let universities = SectionData(columns: [
            .init(name: "Name", type: .text),
            .init(name: "Country", type: .text),
            .init(name: "Website", type: .link),
            .init(name: "Status", type: .status)
        ], rows: [])

        let professors = SectionData(columns: [
            .init(name: "Name", type: .text),
            .init(name: "Country", type: .text),
            .init(name: "Email", type: .text),
            .init(name: "University", type: .text),
            .init(name: "Department", type: .text),
            .init(name: "Website", type: .link),
            .init(name: "Research Interests", type: .notes),
            .init(name: "Status", type: .status),
            .init(name: "Deadline", type: .date),
            .init(name: "Priority", type: .priority),
            .init(name: "Notes", type: .notes)
        ], rows: [])

        let scholarships = SectionData(columns: [
            .init(name: "Name", type: .text),
            .init(name: "Country", type: .text),
            .init(name: "Description", type: .notes),
            .init(name: "Deadline", type: .date),
            .init(name: "Amount", type: .text),
            .init(name: "Eligibility", type: .notes),
            .init(name: "Link", type: .link),
            .init(name: "Notes", type: .notes)
        ], rows: [])

        return GradKitDB(universities: universities, professors: professors, scholarships: scholarships)
    }

    private func migrateIfNeeded() {
        // Add Status column to Universities if missing
        var uni = db.universities
        if uni.columns.first(where: { $0.type == .status }) == nil {
            uni.columns.append(.init(name: "Status", type: .status))
            uni.rows = uni.rows.map { row in
                var r = row
                r["Status"] = "Not Applied"
                return r
            }
            db.universities = uni
        }

        // Ensure Professors use Mailed/Not Mailed wording and that a Status column exists
        var prof = db.professors
        if prof.columns.first(where: { $0.type == .status }) == nil {
            prof.columns.append(.init(name: "Status", type: .status))
        }
        prof.rows = prof.rows.map { row in
            var r = row
            let cur = (r["Status"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            if cur == "Contacted" { r["Status"] = "Mailed" }
            else if cur == "Not Contacted" { r["Status"] = "Not Mailed" }
            return r
        }
        db.professors = prof

        // Ensure Scholarships have a Status column with Applied/Not Applied
        var sch = db.scholarships
        if sch.columns.first(where: { $0.type == .status }) == nil {
            sch.columns.append(.init(name: "Status", type: .status))
            sch.rows = sch.rows.map { row in
                var r = row
                r["Status"] = "Not Applied"
                return r
            }
        }
        db.scholarships = sch
    }

    func data(for section: GradKitSection) -> SectionData {
        switch section {
        case .universities: return db.universities
        case .professors: return db.professors
        case .scholarships: return db.scholarships
        }
    }

    func setData(_ section: GradKitSection, _ data: SectionData) {
        switch section {
        case .universities: db.universities = data
        case .professors: db.professors = data
        case .scholarships: db.scholarships = data
        }
    }

    // MARK: - Row operations
    func addRow(_ section: GradKitSection) {
        var sec = data(for: section)
        var row: [String: String] = [:]
        for col in sec.columns {
            switch col.type {
            case .status:
                switch section {
                case .universities: row[col.name] = "Not Applied"
                case .professors: row[col.name] = "Not Mailed"
                case .scholarships: row[col.name] = "Not Applied"
                }
            case .priority: row[col.name] = PriorityOptions[1]
            default: row[col.name] = ""
            }
        }
        sec.rows.append(row)
        setData(section, sec)
    }

    func deleteRow(_ section: GradKitSection, rowIndex: Int) {
        var sec = data(for: section)
        guard sec.rows.indices.contains(rowIndex) else { return }
        sec.rows.remove(at: rowIndex)
        setData(section, sec)
    }

    func updateCell(_ section: GradKitSection, rowIndex: Int, columnName: String, value: String) {
        var sec = data(for: section)
        guard sec.rows.indices.contains(rowIndex) else { return }
        sec.rows[rowIndex][columnName] = value
        setData(section, sec)
    }

    // MARK: - Column operations
    func addColumn(_ section: GradKitSection) {
        var sec = data(for: section)
        let defaultName = "New Column"
        var nameTry = defaultName
        var suffix = 1
        let existing = Set(sec.columns.map { $0.name })
        while existing.contains(nameTry) { suffix += 1; nameTry = "\(defaultName) \(suffix)" }
        sec.columns.append(.init(name: nameTry, type: .text))
        sec.rows = sec.rows.map { var r = $0; r[nameTry] = ""; return r }
        setData(section, sec)
    }

    func deleteColumn(_ section: GradKitSection, index: Int) {
        var sec = data(for: section)
        guard sec.columns.indices.contains(index) else { return }
        let colName = sec.columns[index].name
        sec.columns.remove(at: index)
        for i in sec.rows.indices { sec.rows[i].removeValue(forKey: colName) }
        setData(section, sec)
    }

    func updateColumn(_ section: GradKitSection, index: Int, key: String, value: String) {
        var sec = data(for: section)
        guard sec.columns.indices.contains(index) else { return }
        var col = sec.columns[index]
        if key == "name" {
            let old = col.name
            if old != value {
                col.name = value
                for i in sec.rows.indices {
                    let oldVal = sec.rows[i][old] ?? ""
                    sec.rows[i][value] = oldVal
                    sec.rows[i].removeValue(forKey: old)
                }
            }
        } else if key == "type" {
            if let t = ColumnType(rawValue: value) { col.type = t }
        }
        sec.columns[index] = col
        setData(section, sec)
    }
}

let StatusOptions: [String] = [
    "Not Contacted",
    "Contacted",
    "Awaiting Response",
    "Interview Scheduled",
    "Submitted",
    "Accepted",
    "Rejected"
]

let PriorityOptions: [String] = ["Low", "Medium", "High", "Urgent"]


