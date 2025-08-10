//
//  Models.swift
//  PhdApply
//
//  Created by Assistant on 9/8/25.
//

import Foundation
import SwiftData

// MARK: - Enumerations (raw-backed for SwiftData compatibility)

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

enum InteractionType: String, CaseIterable, Identifiable, Codable {
    case emailSent = "Email Sent"
    case emailReceived = "Email Received"
    case meeting = "Meeting"
    case note = "Note"

    var id: String { rawValue }
}

// MARK: - Models

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

    init(id: UUID = UUID(), date: Date = .now, type: InteractionType, notes: String = "") {
        self.id = id
        self.date = date
        self.typeRaw = type.rawValue
        self.notes = notes
    }
}

@Model
final class ApplicationRecord {
    var id: UUID

    // Core fields
    var professorName: String
    var email: String
    var universityName: String
    var department: String
    var researchInterests: String

    // Dates & status
    var deadline: Date?
    var statusRaw: String
    var stageRaw: String

    // Visuals & priority
    var priorityLevel: Int
    var colorHex: String?

    // Notes and links
    var notes: String
    @Relationship(deleteRule: .cascade) var links: [LinkItem]
    @Relationship(deleteRule: .cascade) var interactions: [InteractionLog]

    // Custom fields as JSON string for flexibility
    var customFieldsJSON: String?

    // Audit
    var createdAt: Date
    var updatedAt: Date

    // Derived conveniences
    var status: ApplicationStatus {
        get { ApplicationStatus(rawValue: statusRaw) ?? .researching }
        set { statusRaw = newValue.rawValue }
    }
    var stage: ApplicationStatus {
        get { ApplicationStatus(rawValue: stageRaw) ?? .researching }
        set { stageRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        professorName: String = "",
        email: String = "",
        universityName: String = "",
        department: String = "",
        researchInterests: String = "",
        deadline: Date? = nil,
        status: ApplicationStatus = .researching,
        stage: ApplicationStatus = .researching,
        priorityLevel: Int = 0,
        colorHex: String? = nil,
        notes: String = "",
        links: [LinkItem] = [],
        interactions: [InteractionLog] = [],
        customFieldsJSON: String? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.professorName = professorName
        self.email = email
        self.universityName = universityName
        self.department = department
        self.researchInterests = researchInterests
        self.deadline = deadline
        self.statusRaw = status.rawValue
        self.stageRaw = stage.rawValue
        self.priorityLevel = priorityLevel
        self.colorHex = colorHex
        self.notes = notes
        self.links = links
        self.interactions = interactions
        self.customFieldsJSON = customFieldsJSON
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension ApplicationRecord {
    var daysUntilDeadline: Int? {
        guard let deadline else { return nil }
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: .now)
        let end = calendar.startOfDay(for: deadline)
        return calendar.dateComponents([.day], from: start, to: end).day
    }
}


