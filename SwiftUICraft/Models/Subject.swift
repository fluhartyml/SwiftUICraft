//
//  Subject.swift
//  SwiftUICraft (display name: Routines)
//

import Foundation
import SwiftData

@Model
final class Subject {
    var name: String
    var iconName: String
    var colorHex: String
    var sortOrder: Int

    @Relationship(deleteRule: .cascade, inverse: \ScheduledEvent.subject)
    var schedules: [ScheduledEvent] = []

    @Relationship(deleteRule: .cascade, inverse: \LogEntry.subject)
    var logs: [LogEntry] = []

    init(name: String, iconName: String = "person.fill", colorHex: String = "#3B82F6", sortOrder: Int = 0) {
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.sortOrder = sortOrder
    }
}
