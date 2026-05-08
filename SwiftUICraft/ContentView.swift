//
//  ContentView.swift
//  SwiftUICraft (display name: Routines)
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query private var subjects: [Subject]
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

            SubjectsView()
                .tabItem {
                    Label("Subjects", systemImage: "person.2.fill")
                }

            UnderTheHoodView()
                .tabItem {
                    Label("Under the Hood", systemImage: "wrench.and.screwdriver")
                }
        }
        .onAppear {
            seedDefaultSubject()
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

    private func seedDefaultSubject() {
        guard subjects.isEmpty else { return }
        let me = Subject(name: "Me", iconName: "person.crop.circle.fill", colorHex: "#3B82F6", sortOrder: 0)
        modelContext.insert(me)
    }
}
