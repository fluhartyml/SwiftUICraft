//
//  RecurrenceMatching.swift
//  SwiftUICraft (display name: Routines)
//
//  Decides whether a ScheduledEvent applies to a given calendar day.
//

import Foundation

extension ScheduledEvent {
    /// True if this scheduled event should appear on the given day.
    func applies(on date: Date, calendar: Calendar = .current) -> Bool {
        guard let kind = RecurrenceKind(rawValue: recurrenceKindRaw) else { return false }
        let weekday = calendar.component(.weekday, from: date)
        switch kind {
        case .daily:
            return true
        case .weekdays:
            return (2...6).contains(weekday)
        case .weekends:
            return weekday == 1 || weekday == 7
        case .custom:
            guard let day = Weekday(rawValue: weekday) else { return false }
            return recurrenceWeekdaysBitmask.contains(day)
        case .monthly:
            return calendar.component(.day, from: date) == recurrenceMonthDay
        case .oneOff:
            guard let target = recurrenceOneOffDate else { return false }
            return calendar.isDate(target, inSameDayAs: date)
        }
    }

    /// Combined hour:minute as a fixed-day Date for sort and display.
    func scheduledTimeOn(_ day: Date, calendar: Calendar = .current) -> Date {
        calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
    }

    /// Display string like "7:00 AM".
    var formattedTime: String {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        guard let date = Calendar.current.date(from: components) else { return "" }
        return date.formatted(date: .omitted, time: .shortened)
    }
}
