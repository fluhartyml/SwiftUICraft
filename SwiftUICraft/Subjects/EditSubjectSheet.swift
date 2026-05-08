//
//  EditSubjectSheet.swift
//  SwiftUICraft (display name: Routines)
//
//  Phase 1: minimal create-subject sheet. Phase 3 expands with icon + color pickers.
//

import SwiftUI
import SwiftData

struct EditSubjectSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Subject.sortOrder) private var existing: [Subject]

    @State private var name = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name (e.g. Buddy, Mom, Bathroom)", text: $name)
                        .font(.system(size: 18))
                } header: {
                    Text("Name").font(.system(size: 16))
                }
            }
            .navigationTitle("New Subject")
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
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let subject = Subject(
            name: trimmed,
            iconName: "person.fill",
            colorHex: "#3B82F6",
            sortOrder: (existing.last?.sortOrder ?? -1) + 1
        )
        modelContext.insert(subject)
        dismiss()
    }
}
