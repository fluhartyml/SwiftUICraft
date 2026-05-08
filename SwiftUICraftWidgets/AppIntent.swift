//
//  AppIntent.swift
//  SwiftUICraftWidgets (display name: Routines)
//
//  Two intents:
//   1. ConfigurationAppIntent — widget config (which subject to show, etc.)
//   2. LogEventIntent — interactive widget tap-to-log without opening the app.
//
//  Phase 8 ships the intent shapes. The actual SwiftData write from inside the
//  widget process requires the App Group + shared ModelContainer wiring that
//  Phase 8.5 will add (entitlements on both targets, group container for the
//  SwiftData store). Until then, LogEventIntent.perform() logs and returns,
//  so taps are observable in console but don't yet persist.
//

import AppIntents
import WidgetKit

/// Configuration for the TodayEventsWidget — currently a thin shell; Phase 8.5
/// adds a `Subject` enum parameter so a household with multiple subjects can
/// show one subject per widget.
struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Routines Configuration" }
    static var description: IntentDescription { "Pick what the widget shows." }
}

/// Tap-to-log intent. The widget renders a `Button(intent: LogEventIntent(...))`
/// for each upcoming event; tapping records the event as done without opening
/// the app.
struct LogEventIntent: AppIntent {
    static var title: LocalizedStringResource { "Log Event" }
    static var description: IntentDescription { IntentDescription("Mark a scheduled event as done.") }
    static var openAppWhenRun: Bool { false }

    @Parameter(title: "Event ID")
    var eventIDString: String

    @Parameter(title: "Event Name")
    var eventName: String

    init() {}

    init(eventIDString: String, eventName: String) {
        self.eventIDString = eventIDString
        self.eventName = eventName
    }

    func perform() async throws -> some IntentResult {
        // Phase 8.5 wires the App Group ModelContainer and inserts a LogEntry
        // here. Until then, log so taps are observable.
        print("[LogEventIntent] tapped event \(eventName) (\(eventIDString)) — Phase 8.5 will persist")
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
