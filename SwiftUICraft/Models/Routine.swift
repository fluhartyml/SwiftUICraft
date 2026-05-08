//
//  Routine.swift
//  SwiftUICraft (display name: Routines)
//

import Foundation
import SwiftData

@Model
final class Routine {
    var id: UUID
    var tracker: Tracker?
    var name: String
    var iconName: String
    var colorHex: String
    var hour: Int
    var minute: Int

    // Recurrence stored as discrete fields so SwiftData can index/query natively.
    // Phase 3 builds the schedule editor and wires these via the RecurrencePattern struct.
    var recurrenceKindRaw: String       // RecurrenceKind.rawValue
    var recurrenceWeekdaysBitmask: Int  // bit 0 = Sunday, bit 1 = Monday, ..., bit 6 = Saturday
    var recurrenceMonthDay: Int         // 1...31
    var recurrenceOneOffDate: Date?

    var alarmEnabled: Bool
    var notificationEnabled: Bool

    init(
        id: UUID = UUID(),
        tracker: Tracker?,
        name: String,
        iconName: String = "circle.fill",
        colorHex: String = "#3B82F6",
        hour: Int,
        minute: Int = 0,
        recurrenceKindRaw: String = RecurrenceKind.daily.rawValue,
        recurrenceWeekdaysBitmask: Int = 0,
        recurrenceMonthDay: Int = 1,
        recurrenceOneOffDate: Date? = nil,
        alarmEnabled: Bool = false,
        notificationEnabled: Bool = false
    ) {
        self.id = id
        self.tracker = tracker
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.hour = hour
        self.minute = minute
        self.recurrenceKindRaw = recurrenceKindRaw
        self.recurrenceWeekdaysBitmask = recurrenceWeekdaysBitmask
        self.recurrenceMonthDay = recurrenceMonthDay
        self.recurrenceOneOffDate = recurrenceOneOffDate
        self.alarmEnabled = alarmEnabled
        self.notificationEnabled = notificationEnabled
    }
}
