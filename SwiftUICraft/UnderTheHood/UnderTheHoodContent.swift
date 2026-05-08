//
//  UnderTheHoodContent.swift
//  SwiftUICraft (display name: Routines)
//
//  Hand-authored map of every Swift file in the project, with one-line
//  descriptions. Mirrors LockBox's UnderTheHood pattern.
//

import Foundation

struct DeveloperFile: Identifiable, Hashable {
    let id = UUID()
    let path: String
    let description: String
}

enum UnderTheHoodContent {
    static let mainAppFiles: [DeveloperFile] = [
        .init(path: "SwiftUICraftApp.swift",
              description: "@main entry. Builds the SwiftData ModelContainer for Subject + ScheduledEvent + LogEntry and hands ContentView to the WindowGroup."),
        .init(path: "ContentView.swift",
              description: "TabView root with four tabs: Today, History, Subjects, Under the Hood. Seeds the default 'Me' subject on first launch and reconciles AlarmKit + UNNotifications on every scenePhase → .active."),

        .init(path: "Models/Subject.swift",
              description: "@Model — name, iconName, colorHex, sortOrder, plus cascade-delete relationships to ScheduledEvent and LogEntry."),
        .init(path: "Models/ScheduledEvent.swift",
              description: "@Model — a recurring or one-off planned event for a Subject. Discrete recurrence fields (kind, weekday bitmask, monthDay, oneOffDate) plus per-event alarm + notification opt-ins."),
        .init(path: "Models/LogEntry.swift",
              description: "@Model — a recorded event. Either tied to a ScheduledEvent (sourceScheduleID) or ad-hoc (nil). Photo bytes use @Attribute(.externalStorage) so SwiftData stores them on disk, not in the SQLite blob."),
        .init(path: "Models/Recurrence.swift",
              description: "RecurrenceKind enum plus Weekday enum and bitmask helpers for the days-of-week selection."),
        .init(path: "Models/RecurrenceMatching.swift",
              description: "Extension on ScheduledEvent — applies(on:) decides whether an event applies to a given calendar day across all six recurrence kinds."),

        .init(path: "Modifiers/ColorHelpers.swift",
              description: "Color(hex:) initializer for #RRGGBB / #RRGGBBAA strings."),
        .init(path: "Modifiers/EventStyleModifier.swift",
              description: "Custom ViewModifier driven by user-chosen color + icon — the marquee teaching surface for a dynamic design system, not enum-based variants."),
        .init(path: "Modifiers/SubjectBadgeModifier.swift",
              description: "Subject.badge(size:) — circular avatar with icon + tint."),
        .init(path: "Modifiers/DoneBadgeModifier.swift",
              description: "doneBadge(isDone:) — green check / dim outline state for toggle visuals."),
        .init(path: "Modifiers/EventRowModifier.swift",
              description: "eventRow() — consistent row container chrome."),

        .init(path: "Today/TodayView.swift",
              description: "Today's overview. All subjects' applicable scheduled events + ad-hoc logs, sorted by time. + Log button opens QuickLogSheet. Top-left info button opens About."),
        .init(path: "Today/SubjectMealsSheet.swift",
              description: "Per-subject sheet with variable-N rows, one per scheduled event for today."),
        .init(path: "Today/EventLogRow.swift",
              description: "Single row inside SubjectMealsSheet. Toggle-to-log, photo (Library / Camera), inline notes, thumbnail with tap-to-view-fullscreen."),
        .init(path: "Today/QuickLogSheet.swift",
              description: "Ad-hoc + Log path. Subject picker, freeform event name, when timestamp, notes, photo. Saves a LogEntry with sourceScheduleID = nil."),

        .init(path: "Subjects/SubjectsView.swift",
              description: "Manage subjects — list, add via EditSubjectSheet, swipe to delete. Each row navigates into SubjectScheduleView."),
        .init(path: "Subjects/EditSubjectSheet.swift",
              description: "Create/edit a Subject. Name field; icon + color pickers come in v2."),
        .init(path: "Subjects/SubjectScheduleView.swift",
              description: "Per-subject scheduled-events list — sorted by time, tap to edit, swipe to delete, + button to create."),
        .init(path: "Schedule/EditScheduledEventSheet.swift",
              description: "Create/edit a ScheduledEvent. Name, 20-icon SF Symbol grid, 12-color palette, time picker, recurrence picker (daily/weekdays/weekends/custom days/monthly/one-off), AlarmKit + UNNotif opt-ins."),

        .init(path: "History/HistoryView.swift",
              description: "All-time log sorted by doneAt descending. Subject filter + event-name search. Photo thumbnails with tap-to-view. List virtualization handles thousands of rows."),

        .init(path: "Photos/CameraCaptureView.swift",
              description: "UIKit bridge — system camera. UIViewControllerRepresentable wrapping UIImagePickerController. iOS-only."),
        .init(path: "Photos/ImageViewerView.swift",
              description: "Pinch-zoom + drag-pan full-screen image viewer for a Data blob."),

        .init(path: "Alarms/NotificationCoordinator.swift",
              description: "@MainActor singleton. Recurrence-aware UNCalendarNotificationTrigger generation (one ScheduledEvent → multiple requests for weekday kinds). Identifiers use 'eventID-suffix' so an event's requests can be removed in bulk."),
        .init(path: "Alarms/AlarmCoordinator.swift",
              description: "@MainActor singleton wrapped in #if canImport(AlarmKit). Auth flow + reconcile on foreground (per book Appendix C pitfall #1: alarms deleted on fire). Phase 8.5 fills in the full AlarmConfiguration with StopIntent."),

        .init(path: "About/AboutView.swift",
              description: "About sheet — icon, attribution, portfolio + privacy + feedback + repo links. GPL v3 footer."),
        .init(path: "UnderTheHood/UnderTheHoodView.swift",
              description: "Tab content — file list with descriptions; tap a file to view source code (later)."),
        .init(path: "UnderTheHood/UnderTheHoodContent.swift",
              description: "This file — the hand-authored map of every Swift file in the project."),
    ]

    static let widgetExtensionFiles: [DeveloperFile] = [
        .init(path: "SwiftUICraftWidgets/SwiftUICraftWidgetsBundle.swift",
              description: "@main WidgetBundle entry. Registers TodayEventsWidget + Control widget + RoutinesLiveActivity."),
        .init(path: "SwiftUICraftWidgets/SwiftUICraftWidgets.swift",
              description: "TodayEventsWidget. AppIntentTimelineProvider builds a timeline of today's upcoming events. Each event in the widget is a Button(intent: LogEventIntent(...)) that runs without opening the app."),
        .init(path: "SwiftUICraftWidgets/AppIntent.swift",
              description: "ConfigurationAppIntent (widget config) + LogEventIntent (interactive tap-to-log). LogEventIntent currently logs and reloads timelines; Phase 8.5 wires the App Group SwiftData write."),
        .init(path: "SwiftUICraftWidgets/SwiftUICraftWidgetsControl.swift",
              description: "Control Widget (Xcode template). Kept as a working ControlWidget shape for future use; no Routines wiring yet."),
        .init(path: "SwiftUICraftWidgets/SwiftUICraftWidgetsLiveActivity.swift",
              description: "RoutinesLiveActivity. ActivityKit Lock Screen + Dynamic Island UI for AlarmKit countdowns (per book Appendix C pitfall #2)."),
    ]
}
