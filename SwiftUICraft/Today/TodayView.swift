//
//  TodayView.swift
//  SwiftUICraft (display name: Routines)
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tracker.sortOrder) private var trackers: [Tracker]
    @Query private var allSchedules: [Routine]
    @Query private var allLogs: [LogEntry]

    @State private var selectedTracker: Tracker?
    @State private var showQuickLog = false
    @State private var showAbout = false

    private let today = Date()
    private let calendar = Calendar.current

    var body: some View {
        NavigationStack {
            Group {
                if trackers.isEmpty {
                    ContentUnavailableView(
                        "No Trackers",
                        systemImage: "person.2",
                        description: Text("Add a tracker on the Trackers tab to start logging events.")
                    )
                } else {
                    List {
                        ForEach(trackers) { tracker in
                            Section {
                                let todays = todaysSchedules(for: tracker)
                                if todays.isEmpty {
                                    Text("Nothing scheduled for today.")
                                        .font(.system(size: 16))
                                        .foregroundStyle(.secondary)
                                } else {
                                    ForEach(todays) { schedule in
                                        rowSummary(for: schedule, tracker: tracker)
                                    }
                                }
                                let adHoc = todaysAdHocLogs(for: tracker)
                                if !adHoc.isEmpty {
                                    ForEach(adHoc) { log in
                                        adHocSummary(for: log)
                                    }
                                }
                            } header: {
                                Button {
                                    selectedTracker = tracker
                                } label: {
                                    HStack(spacing: 12) {
                                        tracker.badge(size: 32)
                                        Text(tracker.name)
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundStyle(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(.vertical, 4)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showAbout = true
                    } label: {
                        Image(systemName: "info.circle")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showQuickLog = true
                    } label: {
                        Label("Log", systemImage: "plus")
                    }
                }
            }
            .sheet(item: $selectedTracker) { tracker in
                TrackerMealsSheet(tracker: tracker)
            }
            .sheet(isPresented: $showQuickLog) {
                QuickLogSheet()
            }
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
        }
    }

    // MARK: - Lookup

    private func todaysSchedules(for tracker: Tracker) -> [Routine] {
        allSchedules
            .filter { $0.tracker == tracker && $0.applies(on: today, calendar: calendar) }
            .sorted { ($0.hour, $0.minute) < ($1.hour, $1.minute) }
    }

    private func logFor(schedule: Routine, tracker: Tracker) -> LogEntry? {
        allLogs.first { log in
            log.tracker == tracker
            && log.sourceRoutineID == schedule.id
            && calendar.isDate(log.doneAt, inSameDayAs: today)
        }
    }

    private func todaysAdHocLogs(for tracker: Tracker) -> [LogEntry] {
        allLogs
            .filter { log in
                log.tracker == tracker
                && log.sourceRoutineID == nil
                && calendar.isDate(log.doneAt, inSameDayAs: today)
            }
            .sorted { $0.doneAt < $1.doneAt }
    }

    // MARK: - Row builders

    private func rowSummary(for schedule: Routine, tracker: Tracker) -> some View {
        let log = logFor(schedule: schedule, tracker: tracker)
        return HStack(spacing: 12) {
            Image(systemName: schedule.iconName)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color(hex: schedule.colorHex))
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(schedule.name)
                    .font(.system(size: 18))
                Text(schedule.formattedTime)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: log != nil ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 22))
                .foregroundStyle(log != nil ? .green : .secondary)
        }
        .padding(.vertical, 4)
    }

    private func adHocSummary(for log: LogEntry) -> some View {
        HStack(spacing: 12) {
            Image(systemName: log.iconName)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color(hex: log.colorHex))
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(log.name)
                    .font(.system(size: 18))
                Text("Logged \(log.doneAt.formatted(date: .omitted, time: .shortened))")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 22))
                .foregroundStyle(.green)
        }
        .padding(.vertical, 4)
    }
}
