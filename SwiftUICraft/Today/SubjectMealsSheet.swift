//
//  SubjectMealsSheet.swift
//  SwiftUICraft (display name: Routines)
//
//  Per-subject sheet — variable N rows, one per scheduled event for today.
//  Each row toggles fed/done with auto-stamped doneAt.
//

import SwiftUI
import SwiftData

struct SubjectMealsSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let subject: Subject

    @Query private var allSchedules: [ScheduledEvent]
    @Query private var allLogs: [LogEntry]

    private let today = Date()
    private let calendar = Calendar.current

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    let todays = todaysSchedules
                    if todays.isEmpty {
                        Text("No scheduled events today. Add events on the Subjects tab.")
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(todays) { schedule in
                            EventLogRow(
                                schedule: schedule,
                                subject: subject,
                                existingLog: logFor(schedule: schedule)
                            )
                        }
                    }
                } header: {
                    HStack(spacing: 10) {
                        subject.badge(size: 36)
                        Text(subject.name).font(.system(size: 20, weight: .semibold))
                    }
                    .padding(.bottom, 4)
                }
            }
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }.font(.system(size: 18, weight: .semibold))
                }
            }
        }
    }

    private var todaysSchedules: [ScheduledEvent] {
        allSchedules
            .filter { $0.subject == subject && $0.applies(on: today, calendar: calendar) }
            .sorted { ($0.hour, $0.minute) < ($1.hour, $1.minute) }
    }

    private func logFor(schedule: ScheduledEvent) -> LogEntry? {
        allLogs.first { log in
            log.subject == subject
            && log.sourceScheduleID == schedule.id
            && calendar.isDate(log.doneAt, inSameDayAs: today)
        }
    }
}
