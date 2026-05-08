//
//  ContentView.swift
//  SwiftUICraft (display name: Routines)
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query private var trackers: [Tracker]
    @Query private var allSchedules: [Routine]

    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "tray.full.fill")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }

            TrackersView()
                .tabItem {
                    Label("Trackers", systemImage: "person.2.fill")
                }

            UnderTheHoodView()
                .tabItem {
                    Label("Under the Hood", systemImage: "wrench.and.screwdriver")
                }
        }
        .onAppear {
            seedDefaultTracker()
            Task {
                await NotificationCoordinator.shared.reconcile(routines: allSchedules)
                await AlarmCoordinator.shared.reconcile(routines: allSchedules)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task {
                    await NotificationCoordinator.shared.reconcile(routines: allSchedules)
                    await AlarmCoordinator.shared.reconcile(routines: allSchedules)
                }
            }
        }
    }

    private func seedDefaultTracker() {
        guard trackers.isEmpty else { return }
        let me = Tracker(name: "Me", iconName: "person.crop.circle.fill", colorHex: "#3B82F6", sortOrder: 0)
        modelContext.insert(me)
    }
}
