//
//  EventLogRow.swift
//  SwiftUICraft (display name: Routines)
//
//  Single row inside SubjectMealsSheet: toggle, schedule time, done-at, notes.
//  Photo button is a placeholder until Phase 4 wires PhotosPicker + camera.
//

import SwiftUI
import SwiftData

struct EventLogRow: View {
    @Environment(\.modelContext) private var modelContext

    let schedule: ScheduledEvent
    let subject: Subject
    let existingLog: LogEntry?

    @State private var notes: String = ""
    @State private var hasLoadedNotes = false

    private var isDone: Bool { existingLog != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: schedule.iconName)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color(hex: schedule.colorHex))
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(schedule.name)
                        .font(.system(size: 18, weight: .medium))
                    if let log = existingLog {
                        Text("Done at \(log.doneAt.formatted(date: .omitted, time: .shortened))")
                            .font(.system(size: 14))
                            .foregroundStyle(.green)
                    } else {
                        Text("Scheduled \(schedule.formattedTime)")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Toggle("", isOn: Binding(
                    get: { isDone },
                    set: { newValue in toggleDone(to: newValue) }
                ))
                .labelsHidden()
            }

            if isDone {
                TextField("Notes", text: $notes, axis: .vertical)
                    .font(.system(size: 16))
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: notes) { _, newValue in
                        existingLog?.notes = newValue
                    }
            }
        }
        .padding(.vertical, 4)
        .onAppear {
            if !hasLoadedNotes {
                notes = existingLog?.notes ?? ""
                hasLoadedNotes = true
            }
        }
        .onChange(of: existingLog?.id) { _, _ in
            notes = existingLog?.notes ?? ""
        }
    }

    private func toggleDone(to newValue: Bool) {
        if newValue {
            // Create log entry
            let log = LogEntry(
                subject: subject,
                sourceScheduleID: schedule.id,
                name: schedule.name,
                iconName: schedule.iconName,
                colorHex: schedule.colorHex,
                doneAt: .now,
                notes: notes
            )
            modelContext.insert(log)
        } else {
            // Remove existing log entry
            if let log = existingLog {
                modelContext.delete(log)
            }
            notes = ""
        }
    }
}
