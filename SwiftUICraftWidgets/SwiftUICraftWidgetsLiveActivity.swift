//
//  SwiftUICraftWidgetsLiveActivity.swift  →  RoutinesLiveActivity
//  SwiftUICraftWidgets (display name: Routines)
//
//  ActivityKit Live Activity for AlarmKit countdowns.
//  Per book Appendix C pitfall #2: AlarmKit countdown presentations require a
//  Live Activity in the widget extension to host the Lock Screen / Dynamic
//  Island UI. This file provides that surface.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct RoutinesActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var subjectName: String
        var eventName: String
        var iconName: String
        var colorHex: String
        var fireAt: Date
    }

    var eventIDString: String
}

struct RoutinesLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RoutinesActivityAttributes.self) { context in
            // Lock Screen UI
            HStack(spacing: 12) {
                Image(systemName: context.state.iconName)
                    .font(.title)
                    .foregroundStyle(Color(hex: context.state.colorHex))
                VStack(alignment: .leading, spacing: 2) {
                    Text(context.state.eventName)
                        .font(.headline)
                    Text("\(context.state.subjectName) — fires at \(context.state.fireAt.formatted(date: .omitted, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(context.state.fireAt, style: .timer)
                    .font(.system(.title2, design: .monospaced))
            }
            .padding()
            .activityBackgroundTint(Color(hex: context.state.colorHex).opacity(0.18))
            .activitySystemActionForegroundColor(.primary)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: context.state.iconName)
                        .foregroundStyle(Color(hex: context.state.colorHex))
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.fireAt, style: .timer)
                        .font(.system(.body, design: .monospaced))
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.eventName)
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.subjectName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } compactLeading: {
                Image(systemName: context.state.iconName)
                    .foregroundStyle(Color(hex: context.state.colorHex))
            } compactTrailing: {
                Text(context.state.fireAt, style: .timer)
                    .monospacedDigit()
            } minimal: {
                Image(systemName: context.state.iconName)
                    .foregroundStyle(Color(hex: context.state.colorHex))
            }
        }
    }
}

extension RoutinesActivityAttributes {
    fileprivate static var preview: RoutinesActivityAttributes {
        RoutinesActivityAttributes(eventIDString: UUID().uuidString)
    }
}

extension RoutinesActivityAttributes.ContentState {
    fileprivate static var sample: RoutinesActivityAttributes.ContentState {
        .init(subjectName: "Buddy",
              eventName: "Breakfast",
              iconName: "fork.knife",
              colorHex: "#F59E0B",
              fireAt: Date(timeIntervalSinceNow: 600))
    }
}

#Preview("Live Activity", as: .content, using: RoutinesActivityAttributes.preview) {
    RoutinesLiveActivity()
} contentStates: {
    RoutinesActivityAttributes.ContentState.sample
}
