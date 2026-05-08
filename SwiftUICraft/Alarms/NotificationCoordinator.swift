//
//  NotificationCoordinator.swift
//  SwiftUICraft (display name: Routines)
//
//  Schedules UNUserNotifications matching a ScheduledEvent's recurrence.
//  One ScheduledEvent may produce multiple UNNotificationRequests
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

    func reconcile(events: [ScheduledEvent]) async {
        let pending = await center.pendingNotificationRequests()
        let pendingIDs = Set(pending.map(\.identifier))

        // Remove requests for events that no longer have notificationEnabled.
        let validIDs = Set(events.compactMap { event in
            event.notificationEnabled ? event.id.uuidString : nil
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
        for event in events where event.notificationEnabled {
            await schedule(event: event)
        }
    }

    func schedule(event: ScheduledEvent) async {
        let granted = await requestAuthorizationIfNeeded()
        guard granted else { return }

        // Remove any existing requests for this event before scheduling fresh.
        await remove(event: event)

        let kind = RecurrenceKind(rawValue: event.recurrenceKindRaw) ?? .daily
        let triggers: [(suffix: String, trigger: UNNotificationTrigger)] = makeTriggers(
            kind: kind,
            event: event
        )

        let content = UNMutableNotificationContent()
        content.title = event.subject?.name ?? "Routines"
        content.body = event.name
        content.sound = .default

        for (suffix, trigger) in triggers {
            let request = UNNotificationRequest(
                identifier: "\(event.id.uuidString)-\(suffix)",
                content: content,
                trigger: trigger
            )
            try? await center.add(request)
        }
    }

    func remove(event: ScheduledEvent) async {
        let pending = await center.pendingNotificationRequests()
        let prefix = "\(event.id.uuidString)-"
        let ids = pending.map(\.identifier).filter { $0.hasPrefix(prefix) }
        if !ids.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }

    // MARK: - Trigger builders

    private func makeTriggers(kind: RecurrenceKind, event: ScheduledEvent) -> [(String, UNNotificationTrigger)] {
        switch kind {
        case .daily:
            var components = DateComponents()
            components.hour = event.hour
            components.minute = event.minute
            return [("daily", UNCalendarNotificationTrigger(dateMatching: components, repeats: true))]
        case .weekdays:
            return weekdayTriggers(event: event, weekdays: 2...6)
        case .weekends:
            return weekdayTriggers(event: event, weekdays: [1, 7])
        case .custom:
            let days = Weekday.allCases
                .filter { event.recurrenceWeekdaysBitmask.contains($0) }
                .map { $0.rawValue }
            return weekdayTriggers(event: event, weekdays: days)
        case .monthly:
            var components = DateComponents()
            components.day = event.recurrenceMonthDay
            components.hour = event.hour
            components.minute = event.minute
            return [("monthly", UNCalendarNotificationTrigger(dateMatching: components, repeats: true))]
        case .oneOff:
            guard let date = event.recurrenceOneOffDate else { return [] }
            var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
            components.hour = event.hour
            components.minute = event.minute
            return [("oneOff", UNCalendarNotificationTrigger(dateMatching: components, repeats: false))]
        }
    }

    private func weekdayTriggers<S: Sequence>(event: ScheduledEvent, weekdays: S) -> [(String, UNNotificationTrigger)] where S.Element == Int {
        weekdays.map { weekday in
            var components = DateComponents()
            components.weekday = weekday
            components.hour = event.hour
            components.minute = event.minute
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            return ("wk\(weekday)", trigger)
        }
    }
}
