//
//  LogEntry.swift
//  SwiftUICraft (display name: Routines)
//

import Foundation
import SwiftData

@Model
final class LogEntry {
    var subject: Subject?
    var sourceScheduleID: UUID?

    // Denormalized — survives schedule deletion
    var name: String
    var iconName: String
    var colorHex: String

    var doneAt: Date
    var notes: String

    @Attribute(.externalStorage)
    var photoData: Data?

    init(
        subject: Subject?,
        sourceScheduleID: UUID? = nil,
        name: String,
        iconName: String = "circle.fill",
        colorHex: String = "#3B82F6",
        doneAt: Date = .now,
        notes: String = "",
        photoData: Data? = nil
    ) {
        self.subject = subject
        self.sourceScheduleID = sourceScheduleID
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.doneAt = doneAt
        self.notes = notes
        self.photoData = photoData
    }
}
