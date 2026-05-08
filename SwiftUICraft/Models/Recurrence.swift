//
//  Recurrence.swift
//  SwiftUICraft (display name: Routines)
//

import Foundation

/// What kind of recurrence a Routine uses.
/// Stored as the `recurrenceKindRaw` field on Routine.
enum RecurrenceKind: String, CaseIterable, Codable {
    case daily
    case weekdays   // Mon–Fri
    case weekends   // Sat–Sun
    case custom     // specific weekday subset, encoded in recurrenceWeekdaysBitmask
    case monthly    // same day-of-month, encoded in recurrenceMonthDay
    case oneOff     // specific date, encoded in recurrenceOneOffDate
}

/// Calendar weekday bit positions for the bitmask field.
/// Matches Calendar.Component.weekday: Sunday = 1.
enum Weekday: Int, CaseIterable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday

    var bit: Int { 1 << (rawValue - 1) }
    var shortLabel: String {
        switch self {
        case .sunday:    return "Sun"
        case .monday:    return "Mon"
        case .tuesday:   return "Tue"
        case .wednesday: return "Wed"
        case .thursday:  return "Thu"
        case .friday:    return "Fri"
        case .saturday:  return "Sat"
        }
    }
}

extension Int {
    func contains(_ day: Weekday) -> Bool { (self & day.bit) != 0 }
    mutating func toggle(_ day: Weekday) { self ^= day.bit }
}
