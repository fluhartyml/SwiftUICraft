//
//  SwiftUICraftWidgets.swift  →  TodayEventsWidget
//  SwiftUICraftWidgets (display name: Routines)
//
//  Lock Screen + Home Screen widget showing today's upcoming scheduled events
//  with one tap-to-log button per event.
//
//  Phase 8 ships the rendering shape with a placeholder timeline. Phase 8.5
//  swaps in real data from a shared App Group SwiftData container.
//

import WidgetKit
import SwiftUI
import AppIntents

struct TodayEntry: TimelineEntry {
    let date: Date
    let upcoming: [UpcomingEvent]

    struct UpcomingEvent: Hashable {
        let id: String
        let subjectName: String
        let eventName: String
        let iconName: String
        let colorHex: String
        let scheduledAt: Date
    }
}

struct TodayEventsProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> TodayEntry {
        TodayEntry(date: .now, upcoming: Self.samplePlaceholder)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> TodayEntry {
        TodayEntry(date: .now, upcoming: Self.samplePlaceholder)
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<TodayEntry> {
        // Phase 8.5: read upcoming events from the shared App Group container.
        // For Phase 8, render the placeholder so the widget compiles and shows
        // its real shape on the Lock Screen.
        let entry = TodayEntry(date: .now, upcoming: Self.samplePlaceholder)
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now
        return Timeline(entries: [entry], policy: .after(nextRefresh))
    }

    static let samplePlaceholder: [TodayEntry.UpcomingEvent] = [
        .init(id: UUID().uuidString,
              subjectName: "Buddy",
              eventName: "Breakfast",
              iconName: "fork.knife",
              colorHex: "#F59E0B",
              scheduledAt: Date(timeIntervalSinceNow: 1800)),
        .init(id: UUID().uuidString,
              subjectName: "Me",
              eventName: "Morning meds",
              iconName: "pills.fill",
              colorHex: "#3B82F6",
              scheduledAt: Date(timeIntervalSinceNow: 3600)),
    ]
}

struct TodayEventsEntryView: View {
    var entry: TodayEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryRectangular:
            rectangular
        case .accessoryInline:
            inline
        case .accessoryCircular:
            circular
        default:
            stacked
        }
    }

    private var stacked: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Today")
                .font(.caption)
                .foregroundStyle(.secondary)
            ForEach(entry.upcoming.prefix(2), id: \.id) { event in
                Button(intent: LogEventIntent(eventIDString: event.id, eventName: event.eventName)) {
                    HStack(spacing: 8) {
                        Image(systemName: event.iconName)
                            .foregroundStyle(Color(hex: event.colorHex))
                        VStack(alignment: .leading, spacing: 0) {
                            Text(event.eventName)
                                .font(.system(size: 13, weight: .semibold))
                                .lineLimit(1)
                            Text("\(event.subjectName) • \(event.scheduledAt.formatted(date: .omitted, time: .shortened))")
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        Spacer(minLength: 0)
                    }
                }
                .buttonStyle(.plain)
            }
            if entry.upcoming.isEmpty {
                Text("Nothing scheduled.")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var rectangular: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let next = entry.upcoming.first {
                Text(next.eventName).font(.headline)
                Text("\(next.subjectName) • \(next.scheduledAt.formatted(date: .omitted, time: .shortened))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Text("Nothing scheduled")
                    .font(.headline)
            }
        }
    }

    private var inline: some View {
        if let next = entry.upcoming.first {
            return Text("\(next.eventName) — \(next.scheduledAt.formatted(date: .omitted, time: .shortened))")
        }
        return Text("Routines: clear")
    }

    private var circular: some View {
        ZStack {
            AccessoryWidgetBackground()
            if let next = entry.upcoming.first {
                Image(systemName: next.iconName)
                    .font(.system(size: 22))
            } else {
                Image(systemName: "checkmark")
            }
        }
    }
}

struct TodayEventsWidget: Widget {
    let kind: String = "TodayEventsWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: TodayEventsProvider()) { entry in
            TodayEventsEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Today's Routines")
        .description("Upcoming scheduled events. Tap one to log it without opening the app.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryRectangular,
            .accessoryInline,
            .accessoryCircular
        ])
    }
}

// Hex helper local to widget target (extension is in main app target).
extension Color {
    init(hex: String) {
        let trimmed = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: trimmed).scanHexInt64(&value)
        let r, g, b, a: Double
        switch trimmed.count {
        case 6:
            r = Double((value & 0xFF0000) >> 16) / 255.0
            g = Double((value & 0x00FF00) >> 8) / 255.0
            b = Double(value & 0x0000FF) / 255.0
            a = 1.0
        case 8:
            r = Double((value & 0xFF000000) >> 24) / 255.0
            g = Double((value & 0x00FF0000) >> 16) / 255.0
            b = Double((value & 0x0000FF00) >> 8) / 255.0
            a = Double(value & 0x000000FF) / 255.0
        default:
            self = .gray
            return
        }
        self = Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
