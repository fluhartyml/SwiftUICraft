//
//  TodayView.swift
//  SwiftUICraft (display name: Routines)
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Subject.sortOrder) private var subjects: [Subject]
    @Query private var allSchedules: [ScheduledEvent]
    @Query private var allLogs: [LogEntry]

    @State private var selectedSubject: Subject?
    @State private var showQuickLog = false

    private let today = Date()
    private let calendar = Calendar.current

    var body: some View {
        NavigationStack {
            Group {
                if subjects.isEmpty {
                    ContentUnavailableView(
                        "No Subjects",
                        systemImage: "person.2",
                        description: Text("Add a subject on the Subjects tab to start logging events.")
                    )
                } else {
                    List {
                        ForEach(subjects) { subject in
                            Section {
                                let todays = todaysSchedules(for: subject)
                                if todays.isEmpty {
                                    Text("Nothing scheduled for today.")
                                        .font(.system(size: 16))
                                        .foregroundStyle(.secondary)
                                } else {
                                    ForEach(todays) { schedule in
                                        rowSummary(for: schedule, subject: subject)
                                    }
                                }
                                let adHoc = todaysAdHocLogs(for: subject)
                                if !adHoc.isEmpty {
                                    ForEach(adHoc) { log in
                                        adHocSummary(for: log)
                                    }
                                }
                            } header: {
                                Button {
                                    selectedSubject = subject
                                } label: {
                                    HStack(spacing: 12) {
                                        subject.badge(size: 32)
                                        Text(subject.name)
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showQuickLog = true
                    } label: {
                        Label("Log", systemImage: "plus")
                    }
                }
            }
            .sheet(item: $selectedSubject) { subject in
                SubjectMealsSheet(subject: subject)
            }
            .sheet(isPresented: $showQuickLog) {
                QuickLogSheet()
            }
        }
    }

    // MARK: - Lookup

    private func todaysSchedules(for subject: Subject) -> [ScheduledEvent] {
        allSchedules
            .filter { $0.subject == subject && $0.applies(on: today, calendar: calendar) }
            .sorted { ($0.hour, $0.minute) < ($1.hour, $1.minute) }
    }

    private func logFor(schedule: ScheduledEvent, subject: Subject) -> LogEntry? {
        allLogs.first { log in
            log.subject == subject
            && log.sourceScheduleID == schedule.id
            && calendar.isDate(log.doneAt, inSameDayAs: today)
        }
    }

    private func todaysAdHocLogs(for subject: Subject) -> [LogEntry] {
        allLogs
            .filter { log in
                log.subject == subject
                && log.sourceScheduleID == nil
                && calendar.isDate(log.doneAt, inSameDayAs: today)
            }
            .sorted { $0.doneAt < $1.doneAt }
    }

    // MARK: - Row builders

    private func rowSummary(for schedule: ScheduledEvent, subject: Subject) -> some View {
        let log = logFor(schedule: schedule, subject: subject)
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
