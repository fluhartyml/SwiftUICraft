//
//  AlarmCoordinator.swift
//  SwiftUICraft (display name: Routines)
//
//  Schedules AlarmKit prominent alarms matching a ScheduledEvent's recurrence.
//
//  AlarmKit's full configuration requires a StopIntent (AppIntent) so the
//  alarm's Lock-Screen button can run app-side code on dismiss. That intent
//  lives in the Widget Extension target (Phase 8). Until Phase 8 lands,
//  this coordinator handles authorization + reconciliation but the actual
//  schedule() call uses a minimal config that the SDK accepts at v1.
//
//  Three pitfalls per book Appendix C:
//   1. Alarms are deleted from the daemon when they fire — reconcile on foreground.
//   2. Countdown presentations require a Live Activity in the widget extension.
//   3. Missing/empty NSAlarmKitUsageDescription silently fails.
//

import Foundation

#if canImport(AlarmKit)
import AlarmKit

@MainActor
final class AlarmCoordinator {
    static let shared = AlarmCoordinator()
    private let manager = AlarmManager.shared

    private init() {}

    func requestAuthorizationIfNeeded() async -> Bool {
        switch manager.authorizationState {
        case .authorized:
            return true
        case .denied:
            return false
        case .notDetermined:
            do {
                let state = try await manager.requestAuthorization()
                return state == .authorized
            } catch {
                return false
            }
        @unknown default:
            return false
        }
    }

    /// Bring the AlarmKit daemon's set of scheduled alarms in sync with
    /// the ScheduledEvent rows that have alarmEnabled = true.
    func reconcile(events: [ScheduledEvent]) async {
        let granted = await requestAuthorizationIfNeeded()
        guard granted else { return }

        let validIDs = Set(
            events
                .filter { $0.alarmEnabled }
                .map { $0.id }
        )

        // Cancel alarms that no longer have alarmEnabled = true.
        let existingAlarms = (try? manager.alarms) ?? []
        for alarm in existingAlarms {
            if !validIDs.contains(alarm.id) {
                try? await manager.cancel(id: alarm.id)
            }
        }

        // Re-schedule the rest.
        for event in events where event.alarmEnabled {
            await schedule(event: event)
        }
    }

    func schedule(event: ScheduledEvent) async {
        let granted = await requestAuthorizationIfNeeded()
        guard granted else { return }

        // Cancel any prior alarm for this event before re-scheduling.
        try? await manager.cancel(id: event.id)

        // Phase 7 ships the auth + reconciliation flow; the full alarm
        // configuration with StopIntent lives in Phase 8 once the widget
        // extension target supplies the AppIntent. Until then, emit a
        // log line so behavior is observable without crashing.
        print("[AlarmCoordinator] schedule pending Phase 8 wiring for \(event.name) (\(event.id))")
    }

    func remove(event: ScheduledEvent) async {
        try? await manager.cancel(id: event.id)
    }
}
#else
// AlarmKit not available on this platform — stub so callers compile cleanly.
@MainActor
final class AlarmCoordinator {
    static let shared = AlarmCoordinator()
    private init() {}
    func requestAuthorizationIfNeeded() async -> Bool { false }
    func reconcile(events: [ScheduledEvent]) async {}
    func schedule(event: ScheduledEvent) async {}
    func remove(event: ScheduledEvent) async {}
}
#endif
