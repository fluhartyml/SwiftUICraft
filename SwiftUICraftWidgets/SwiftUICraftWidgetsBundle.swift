//
//  SwiftUICraftWidgetsBundle.swift
//  SwiftUICraftWidgets (display name: Routines)
//
//  @main entry for the Widget Extension target. Registers the widgets,
//  the Control Widget (Xcode template, kept for shape), and the Live
//  Activity used by AlarmKit countdowns.
//

import WidgetKit
import SwiftUI

@main
struct SwiftUICraftWidgetsBundle: WidgetBundle {
    var body: some Widget {
        TodayEventsWidget()
        SwiftUICraftWidgetsControl()
        RoutinesLiveActivity()
    }
}
