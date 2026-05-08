//
//  Tracker.swift
//  SwiftUICraft (display name: Routines)
//

import Foundation
import SwiftData

@Model
final class Tracker {
    var id: UUID
    var name: String
    var iconName: String
    var colorHex: String
    var sortOrder: Int

    @Relationship(deleteRule: .cascade, inverse: \Routine.tracker)
    var schedules: [Routine] = []

    @Relationship(deleteRule: .cascade, inverse: \LogEntry.tracker)
    var logs: [LogEntry] = []

    init(id: UUID = UUID(), name: String, iconName: String = "person.fill", colorHex: String = "#3B82F6", sortOrder: Int = 0) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.sortOrder = sortOrder
    }
}
