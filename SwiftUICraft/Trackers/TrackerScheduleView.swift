//
//  TrackerScheduleView.swift
//  SwiftUICraft (display name: Routines)
//
//  Per-tracker scheduled-events list. Add / edit / delete.
//

import SwiftUI
import SwiftData

struct TrackerScheduleView: View {
    @Environment(\.modelContext) private var modelContext

    let tracker: Tracker

    @State private var showAdd = false
    @State private var editing: Routine?

    var body: some View {
        List {
            Section {
                if tracker.schedules.isEmpty {
                    Text("No scheduled routines. Tap + to add one.")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(sortedSchedules) { schedule in
                        Button {
                            editing = schedule
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: schedule.iconName)
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundStyle(Color(hex: schedule.colorHex))
                                    .frame(width: 32)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(schedule.name)
                                        .font(.system(size: 18))
                                        .foregroundStyle(.primary)
                                    Text("\(schedule.formattedTime) • \(recurrenceLabel(for: schedule))")
                                        .font(.system(size: 14))
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete(perform: deleteSchedules)
                }
            } header: {
                HStack(spacing: 10) {
                    tracker.badge(size: 32)
                    Text(tracker.name).font(.system(size: 20, weight: .semibold))
                }
                .padding(.bottom, 4)
            }
        }
        .navigationTitle("Schedule")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAdd = true
                } label: {
                    Label("Add Routine", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showAdd) {
            EditRoutineSheet(tracker: tracker, editing: nil)
        }
        .sheet(item: $editing) { schedule in
            EditRoutineSheet(tracker: tracker, editing: schedule)
        }
    }

    private var sortedSchedules: [Routine] {
        tracker.schedules.sorted { ($0.hour, $0.minute) < ($1.hour, $1.minute) }
    }

    private func recurrenceLabel(for schedule: Routine) -> String {
        guard let kind = RecurrenceKind(rawValue: schedule.recurrenceKindRaw) else { return "—" }
        switch kind {
        case .daily:    return "Daily"
        case .weekdays: return "Weekdays"
        case .weekends: return "Weekends"
        case .custom:
            let days = Weekday.allCases.filter { schedule.recurrenceWeekdaysBitmask.contains($0) }
            return days.map(\.shortLabel).joined(separator: " ")
        case .monthly:  return "Monthly on day \(schedule.recurrenceMonthDay)"
        case .oneOff:
            if let date = schedule.recurrenceOneOffDate {
                return date.formatted(date: .abbreviated, time: .omitted)
            }
            return "One-off"
        }
    }

    private func deleteSchedules(at offsets: IndexSet) {
        let toDelete = offsets.map { sortedSchedules[$0] }
        for schedule in toDelete {
            Task {
                await NotificationCoordinator.shared.remove(routine: schedule)
                await AlarmCoordinator.shared.remove(routine: schedule)
            }
            modelContext.delete(schedule)
        }
    }
}
