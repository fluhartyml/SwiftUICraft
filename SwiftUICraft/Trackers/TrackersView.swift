//
//  TrackersView.swift
//  SwiftUICraft (display name: Routines)
//
//  Phase 1 surface: list trackers + add new (basic). Phase 3 adds drill-into-schedule view.
//

import SwiftUI
import SwiftData

struct TrackersView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tracker.sortOrder) private var trackers: [Tracker]
    @State private var showAddTracker = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(trackers) { tracker in
                    NavigationLink {
                        TrackerScheduleView(tracker: tracker)
                    } label: {
                        HStack(spacing: 12) {
                            tracker.badge(size: 36)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(tracker.name)
                                    .font(.system(size: 18))
                                Text("\(tracker.schedules.count) scheduled")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: deleteTrackers)
            }
            .navigationTitle("Trackers")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddTracker = true
                    } label: {
                        Label("Add Tracker", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddTracker) {
                EditTrackerSheet()
            }
            .overlay {
                if trackers.isEmpty {
                    ContentUnavailableView(
                        "No Trackers",
                        systemImage: "person.2",
                        description: Text("Add a tracker to start logging.")
                    )
                }
            }
        }
    }

    private func deleteTrackers(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(trackers[index])
        }
    }
}
