//
//  EditScheduledEventSheet.swift
//  SwiftUICraft (display name: Routines)
//
//  Create or edit a ScheduledEvent.
//

import SwiftUI
import SwiftData

struct EditScheduledEventSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let subject: Subject
    let editing: ScheduledEvent?

    @State private var name = ""
    @State private var iconName = "circle.fill"
    @State private var colorHex = "#3B82F6"
    @State private var time = Date()
    @State private var kind: RecurrenceKind = .daily
    @State private var weekdaysBitmask: Int = 0
    @State private var monthDay: Int = 1
    @State private var oneOffDate: Date = .now
    @State private var alarmEnabled = false
    @State private var notificationEnabled = false
    @State private var hasLoaded = false

    private static let iconChoices: [String] = [
        "fork.knife", "carrot.fill", "pawprint.fill", "pills.fill",
        "cross.case.fill", "drop.fill", "bed.double.fill", "figure.walk",
        "shower.fill", "toilet.fill", "mouth.fill", "heart.fill",
        "book.fill", "pencil.and.outline", "paintbrush.fill",
        "leaf.fill", "sun.max.fill", "moon.stars.fill", "bell.fill", "circle.fill"
    ]

    private static let colorChoices: [String] = [
        "#3B82F6", "#10B981", "#F59E0B", "#EF4444",
        "#8B5CF6", "#EC4899", "#06B6D4", "#84CC16",
        "#F97316", "#6366F1", "#14B8A6", "#A855F7"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Event name (e.g. Breakfast, Morning meds)", text: $name)
                        .font(.system(size: 18))
                } header: { Text("Name").font(.system(size: 16)) }

                Section {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
                        ForEach(Self.iconChoices, id: \.self) { name in
                            Button {
                                iconName = name
                            } label: {
                                Image(systemName: name)
                                    .font(.system(size: 22))
                                    .foregroundStyle(iconName == name ? Color(hex: colorHex) : Color.secondary)
                                    .frame(width: 36, height: 36)
                                    .background(iconName == name ? Color(hex: colorHex).opacity(0.15) : Color.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } header: { Text("Icon").font(.system(size: 16)) }

                Section {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
                        ForEach(Self.colorChoices, id: \.self) { hex in
                            Button {
                                colorHex = hex
                            } label: {
                                Circle()
                                    .fill(Color(hex: hex))
                                    .frame(width: 32, height: 32)
                                    .overlay {
                                        if colorHex == hex {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundStyle(.white)
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } header: { Text("Color").font(.system(size: 16)) }

                Section {
                    DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                        .font(.system(size: 18))
                } header: { Text("Time").font(.system(size: 16)) }

                Section {
                    Picker("Recurrence", selection: $kind) {
                        Text("Daily").tag(RecurrenceKind.daily)
                        Text("Weekdays").tag(RecurrenceKind.weekdays)
                        Text("Weekends").tag(RecurrenceKind.weekends)
                        Text("Custom days").tag(RecurrenceKind.custom)
                        Text("Monthly").tag(RecurrenceKind.monthly)
                        Text("One-off").tag(RecurrenceKind.oneOff)
                    }
                    .font(.system(size: 18))
                    .pickerStyle(.menu)

                    if kind == .custom {
                        HStack {
                            ForEach(Weekday.allCases, id: \.self) { day in
                                Button {
                                    weekdaysBitmask.toggle(day)
                                } label: {
                                    Text(day.shortLabel)
                                        .font(.system(size: 14, weight: .semibold))
                                        .frame(width: 36, height: 32)
                                        .background(weekdaysBitmask.contains(day) ? Color(hex: colorHex) : Color.clear)
                                        .foregroundStyle(weekdaysBitmask.contains(day) ? Color.white : .primary)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(Color.secondary.opacity(0.4), lineWidth: 1)
                                        }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    if kind == .monthly {
                        Stepper("Day of month: \(monthDay)", value: $monthDay, in: 1...31)
                            .font(.system(size: 18))
                    }

                    if kind == .oneOff {
                        DatePicker("Date", selection: $oneOffDate, displayedComponents: .date)
                            .font(.system(size: 18))
                    }
                } header: { Text("Recurrence").font(.system(size: 16)) }

                Section {
                    Toggle("Prominent alarm (rings through silent)", isOn: $alarmEnabled)
                        .font(.system(size: 16))
                    Toggle("Gentle notification", isOn: $notificationEnabled)
                        .font(.system(size: 16))
                } header: { Text("Reminders").font(.system(size: 16)) }
            }
            .navigationTitle(editing == nil ? "New Event" : "Edit Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.font(.system(size: 18))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .font(.system(size: 18, weight: .semibold))
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                guard !hasLoaded else { return }
                hasLoaded = true
                if let event = editing {
                    name = event.name
                    iconName = event.iconName
                    colorHex = event.colorHex
                    time = Calendar.current.date(bySettingHour: event.hour, minute: event.minute, second: 0, of: Date()) ?? Date()
                    kind = RecurrenceKind(rawValue: event.recurrenceKindRaw) ?? .daily
                    weekdaysBitmask = event.recurrenceWeekdaysBitmask
                    monthDay = event.recurrenceMonthDay
                    oneOffDate = event.recurrenceOneOffDate ?? .now
                    alarmEnabled = event.alarmEnabled
                    notificationEnabled = event.notificationEnabled
                }
            }
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let comps = Calendar.current.dateComponents([.hour, .minute], from: time)
        let hour = comps.hour ?? 0
        let minute = comps.minute ?? 0

        let savedEvent: ScheduledEvent
        if let event = editing {
            event.name = trimmed
            event.iconName = iconName
            event.colorHex = colorHex
            event.hour = hour
            event.minute = minute
            event.recurrenceKindRaw = kind.rawValue
            event.recurrenceWeekdaysBitmask = weekdaysBitmask
            event.recurrenceMonthDay = monthDay
            event.recurrenceOneOffDate = (kind == .oneOff) ? oneOffDate : nil
            event.alarmEnabled = alarmEnabled
            event.notificationEnabled = notificationEnabled
            savedEvent = event
        } else {
            let event = ScheduledEvent(
                subject: subject,
                name: trimmed,
                iconName: iconName,
                colorHex: colorHex,
                hour: hour,
                minute: minute,
                recurrenceKindRaw: kind.rawValue,
                recurrenceWeekdaysBitmask: weekdaysBitmask,
                recurrenceMonthDay: monthDay,
                recurrenceOneOffDate: (kind == .oneOff) ? oneOffDate : nil,
                alarmEnabled: alarmEnabled,
                notificationEnabled: notificationEnabled
            )
            modelContext.insert(event)
            savedEvent = event
        }
        Task {
            if savedEvent.notificationEnabled {
                await NotificationCoordinator.shared.schedule(event: savedEvent)
            } else {
                await NotificationCoordinator.shared.remove(event: savedEvent)
            }
            if savedEvent.alarmEnabled {
                await AlarmCoordinator.shared.schedule(event: savedEvent)
            } else {
                await AlarmCoordinator.shared.remove(event: savedEvent)
            }
        }
        dismiss()
    }
}
