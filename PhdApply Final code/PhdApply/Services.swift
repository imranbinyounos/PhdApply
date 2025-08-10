//
//  Services.swift
//  PhdApply
//
//  Created by Assistant on 9/8/25.
//

import Foundation
import AppKit
import UniformTypeIdentifiers

// MARK: - CSV Import/Export

enum CSVService {
    static func export(records: [ApplicationRecord]) -> Data {
        let header = [
            "Professor Name","Email","University","Department","Interests",
            "Deadline","Status","Stage","Priority","ColorHex","Notes","Links"
        ].joined(separator: ",")

        let rows = records.map { r -> String in
            // Cache formatter to avoid repeated allocations
            struct Cache { static let iso = ISO8601DateFormatter() }
            let dateString = r.deadline.map { Cache.iso.string(from: $0) } ?? ""
            let linksJoined = r.links.map { "\($0.title):\($0.urlString)" }.joined(separator: " | ")
            let cols: [String] = [
                r.professorName, r.email, r.universityName, r.department, r.researchInterests,
                dateString, r.statusRaw, r.stageRaw, String(r.priorityLevel), r.colorHex ?? "",
                r.notes.replacingOccurrences(of: "\n", with: " "),
                linksJoined
            ]
            return cols.map { escapeCSV($0) }.joined(separator: ",")
        }

        let csv = ([header] + rows).joined(separator: "\n")
        return Data(csv.utf8)
    }

    private static func escapeCSV(_ field: String) -> String {
        if field.contains(",") || field.contains("\n") || field.contains("\"") {
            return "\"" + field.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return field
    }

    static func `import`(data: Data) -> [ApplicationRecord] {
        guard let string = String(data: data, encoding: .utf8) else { return [] }
        var lines = string.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        guard !lines.isEmpty else { return [] }
        // Drop header if present (simple heuristic)
        if lines.first?.lowercased().contains("professor name") == true { lines.removeFirst() }

        let formatter = ISO8601DateFormatter()
        return lines.map { line in
            let cols = parseCSV(line)
            let links: [LinkItem] = (cols[safe: 11] ?? "").split(separator: "|").map { frag in
                let parts = frag.split(separator: ":", maxSplits: 1).map(String.init).map { $0.trimmingCharacters(in: .whitespaces) }
                guard parts.count == 2 else { return nil }
                return LinkItem(title: parts[0], urlString: parts[1])
            }.compactMap { $0 }

            let date = (cols[safe: 5]).flatMap { formatter.date(from: $0) }
            let rec = ApplicationRecord(
                professorName: cols[safe: 0] ?? "",
                email: cols[safe: 1] ?? "",
                universityName: cols[safe: 2] ?? "",
                department: cols[safe: 3] ?? "",
                researchInterests: cols[safe: 4] ?? "",
                deadline: date,
                status: ApplicationStatus(rawValue: cols[safe: 6] ?? "") ?? .researching,
                stage: ApplicationStatus(rawValue: cols[safe: 7] ?? "") ?? .researching,
                priorityLevel: Int(cols[safe: 8] ?? "0") ?? 0,
                colorHex: cols[safe: 9],
                notes: cols[safe: 10] ?? "",
                links: links
            )
            return rec
        }
    }

    private static func parseCSV(_ line: String) -> [String] {
        var result: [String] = []
        var field = ""
        var inQuotes = false
        var iterator = line.makeIterator()
        while let char = iterator.next() {
            if char == "\"" {
                if inQuotes {
                    if let peek = iterator.next() {
                        if peek == "\"" { field.append("\"") } else if peek == "," { result.append(field); field = ""; inQuotes = false } else { field.append(peek) }
                    } else {
                        inQuotes = false
                    }
                } else {
                    inQuotes = true
                }
            } else if char == "," && !inQuotes {
                result.append(field)
                field = ""
            } else {
                field.append(char)
            }
        }
        result.append(field)
        return result
    }
}

// MARK: - Email Service

enum EmailService {
    static func composeEmail(to recipient: String, subject: String, body: String) {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let mailto = "mailto:\(recipient)?subject=\(subjectEncoded)&body=\(bodyEncoded)"
        guard let url = URL(string: mailto) else { return }
        NSWorkspace.shared.open(url)
    }
}

// MARK: - GradKit CSV Export (All Sections)

enum GradKitCSVService {
    static func exportAllSectionsCSV(db: GradKitDB) -> Data {
        // Build per-section CSV blocks and join with blank line between
        var blocks: [String] = []

        func makeBlock(sectionName: String, data: SectionData) -> String {
            let headers = data.columns.map { $0.name }
            let headerLine = headers.joined(separator: ",")
            let rows: [String] = data.rows.map { row in
                headers.map { escape(row[$0] ?? "") }.joined(separator: ",")
            }
            return (["# Section: \(sectionName)", headerLine] + rows).joined(separator: "\n")
        }

        blocks.append(makeBlock(sectionName: "Universities", data: db.universities))
        blocks.append(makeBlock(sectionName: "Professors", data: db.professors))
        blocks.append(makeBlock(sectionName: "Scholarships", data: db.scholarships))

        let joined = blocks.joined(separator: "\n\n")
        return Data(joined.utf8)
    }

    private static func escape(_ field: String) -> String {
        if field.contains(",") || field.contains("\n") || field.contains("\"") {
            return "\"" + field.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return field
    }
}

// MARK: - Notifications

import UserNotifications

enum NotificationService {
    static func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    static func scheduleDeadlineNotification(for record: ApplicationRecord, daysBefore: Int) {
        guard let deadline = record.deadline else { return }
        let triggerDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: deadline)
        guard let date = triggerDate, date > .now else { return }

        let content = UNMutableNotificationContent()
        content.title = "Approaching Deadline"
        content.body = "\(record.universityName) - \(record.professorName) due in \(daysBefore) days"

        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let req = UNNotificationRequest(identifier: record.id.uuidString + "-\(daysBefore)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req)
    }
}

// MARK: - Safe Collection Access

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


