//
//  SubjectMealsSheet.swift
//  SwiftUICraft (display name: Routines)
//
//  Per-subject sheet — variable N rows, one per scheduled event for today.
//  Empty state surfaces an "Add scheduled event" CTA so the user has a
//  clear next step from inside the sheet.
//

import SwiftUI
import SwiftData

struct SubjectMealsSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let subject: Subject

    @Query private var allSchedules: [Routine]
    @Query private var allLogs: [LogEntry]

    @State private var showAddSchedule = false

    private let today = Date()
    private let calendar = Calendar.current

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    let todays = todaysSchedules
                    if todays.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 50))
                                .foregroundStyle(.tint)
                            Text("Nothing scheduled for \(subject.name) today.")
                                .font(.system(size: 18))
                                .multilineTextAlignment(.center)
                            Button {
                                showAddSchedule = true
                            } label: {
                                Label("Schedule a routine", systemImage: "plus.circle.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                            }
                            .buttonStyle(.borderedProminent)
                            Text("Set a recurring time (breakfast, meds, walk, BM, anything) or a one-off. Each event becomes a togglable row here.")
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                    } else {
                        ForEach(todays) { schedule in
                            RoutineLogRow(
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
            .navigationTitle(subject.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddSchedule = true
                    } label: {
                        Label("Add Routine", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }.font(.system(size: 18))
                }
            }
            .sheet(isPresented: $showAddSchedule) {
                EditRoutineSheet(subject: subject, editing: nil)
            }
        }
    }

    private var todaysSchedules: [Routine] {
        allSchedules
            .filter { $0.subject == subject && $0.applies(on: today, calendar: calendar) }
            .sorted { ($0.hour, $0.minute) < ($1.hour, $1.minute) }
    }

    private func logFor(schedule: Routine) -> LogEntry? {
        allLogs.first { log in
            log.subject == subject
            && log.sourceRoutineID == schedule.id
            && calendar.isDate(log.doneAt, inSameDayAs: today)
        }
    }
}
