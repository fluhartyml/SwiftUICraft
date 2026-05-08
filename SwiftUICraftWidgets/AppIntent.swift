//
//  AppIntent.swift
//  SwiftUICraftWidgets (display name: Routines)
//
//  Two intents:
//   1. ConfigurationAppIntent — widget config (which tracker to show, etc.)
//   2. LogRoutineIntent — interactive widget tap-to-log without opening the app.
//
//  Phase 8 ships the intent shapes. The actual SwiftData write from inside the
//  widget process requires the App Group + shared ModelContainer wiring that
//  Phase 8.5 will add (entitlements on both targets, group container for the
//  SwiftData store). Until then, LogRoutineIntent.perform() logs and returns,
//  so taps are observable in console but don't yet persist.
//

import AppIntents
import WidgetKit

/// Configuration for the TodayRoutinesWidget — currently a thin shell; Phase 8.5
/// adds a `Tracker` enum parameter so a household with multiple trackers can
/// show one tracker per widget.
struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Routines Configuration" }
    static var description: IntentDescription { "Pick what the widget shows." }
}

/// Tap-to-log intent. The widget renders a `Button(intent: LogRoutineIntent(...))`
/// for each upcoming event; tapping records the event as done without opening
/// the app.
struct LogRoutineIntent: AppIntent {
    static var title: LocalizedStringResource { "Log Routine" }
    static var description: IntentDescription { IntentDescription("Mark a scheduled event as done.") }
    static var openAppWhenRun: Bool { false }

    @Parameter(title: "Event ID")
    var routineIDString: String

    @Parameter(title: "Event Name")
    var routineName: String

    init() {}

    init(routineIDString: String, routineName: String) {
        self.routineIDString = routineIDString
        self.routineName = routineName
    }

    func perform() async throws -> some IntentResult {
        // Phase 8.5 wires the App Group ModelContainer and inserts a LogEntry
        // here. Until then, log so taps are observable.
        print("[LogRoutineIntent] tapped event \(routineName) (\(routineIDString)) — Phase 8.5 will persist")
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
