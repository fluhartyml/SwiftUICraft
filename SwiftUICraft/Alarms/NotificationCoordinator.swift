//
//  NotificationCoordinator.swift
//  SwiftUICraft (display name: Routines)
//
//  Schedules UNUserNotifications matching a Routine's recurrence.
//  One Routine may produce multiple UNNotificationRequests
//  (one per applicable weekday for .weekdays / .weekends / .custom).
//  Identifiers use the form "<eventID>-<index>" so we can remove an
//  event's requests in bulk.
//

import Foundation
@preconcurrency import UserNotifications

@MainActor
final class NotificationCoordinator {
    static let shared = NotificationCoordinator()
    private let center = UNUserNotificationCenter.current()

    private init() {}

    func requestAuthorizationIfNeeded() async -> Bool {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            do {
                return try await center.requestAuthorization(options: [.alert, .sound, .badge])
            } catch {
                return false
            }
        @unknown default:
            return false
        }
    }

    func reconcile(routines: [Routine]) async {
        let pending = await center.pendingNotificationRequests()
        let pendingIDs = Set(pending.map(\.identifier))

        // Remove requests for events that no longer have notificationEnabled.
        let validIDs = Set(routines.compactMap { routine in
            routine.notificationEnabled ? routine.id.uuidString : nil
        })
        let toRemove = pendingIDs.filter { id in
            // request id format: "<eventUUID>-<n>"
            guard let dashIndex = id.lastIndex(of: "-") else { return true }
            let eventID = String(id[..<dashIndex])
            return !validIDs.contains(eventID)
        }
        if !toRemove.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: Array(toRemove))
        }

        // Schedule fresh for events with notificationEnabled = true.
        for routine in routines where routine.notificationEnabled {
            await schedule(routine: routine)
        }
    }

    func schedule(routine: Routine) async {
        let granted = await requestAuthorizationIfNeeded()
        guard granted else { return }

        // Remove any existing requests for this event before scheduling fresh.
        await remove(routine: routine)

        let kind = RecurrenceKind(rawValue: routine.recurrenceKindRaw) ?? .daily
        let triggers: [(suffix: String, trigger: UNNotificationTrigger)] = makeTriggers(
            kind: kind,
            routine: routine
        )

        let content = UNMutableNotificationContent()
        content.title = routine.subject?.name ?? "Routines"
        content.body = routine.name
        content.sound = .default

        for (suffix, trigger) in triggers {
            let request = UNNotificationRequest(
                identifier: "\(routine.id.uuidString)-\(suffix)",
                content: content,
                trigger: trigger
            )
            try? await center.add(request)
        }
    }

    func remove(routine: Routine) async {
        let pending = await center.pendingNotificationRequests()
        let prefix = "\(routine.id.uuidString)-"
        let ids = pending.map(\.identifier).filter { $0.hasPrefix(prefix) }
        if !ids.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }

    // MARK: - Trigger builders

    private func makeTriggers(kind: RecurrenceKind, routine: Routine) -> [(String, UNNotificationTrigger)] {
        switch kind {
        case .daily:
            var components = DateComponents()
            components.hour = routine.hour
            components.minute = routine.minute
            return [("daily", UNCalendarNotificationTrigger(dateMatching: components, repeats: true))]
        case .weekdays:
            return weekdayTriggers(routine: routine, weekdays: 2...6)
        case .weekends:
            return weekdayTriggers(routine: routine, weekdays: [1, 7])
        case .custom:
            let days = Weekday.allCases
                .filter { routine.recurrenceWeekdaysBitmask.contains($0) }
                .map { $0.rawValue }
            return weekdayTriggers(routine: routine, weekdays: days)
        case .monthly:
            var components = DateComponents()
            components.day = routine.recurrenceMonthDay
            components.hour = routine.hour
            components.minute = routine.minute
            return [("monthly", UNCalendarNotificationTrigger(dateMatching: components, repeats: true))]
        case .oneOff:
            guard let date = routine.recurrenceOneOffDate else { return [] }
            var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
            components.hour = routine.hour
            components.minute = routine.minute
            return [("oneOff", UNCalendarNotificationTrigger(dateMatching: components, repeats: false))]
        }
    }

    private func weekdayTriggers<S: Sequence>(routine: Routine, weekdays: S) -> [(String, UNNotificationTrigger)] where S.Element == Int {
        weekdays.map { weekday in
            var components = DateComponents()
            components.weekday = weekday
            components.hour = routine.hour
            components.minute = routine.minute
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            return ("wk\(weekday)", trigger)
        }
    }
}
