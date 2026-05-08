//
//  SubjectsView.swift
//  SwiftUICraft (display name: Routines)
//
//  Phase 1 surface: list subjects + add new (basic). Phase 3 adds drill-into-schedule view.
//

import SwiftUI
import SwiftData

struct SubjectsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Subject.sortOrder) private var subjects: [Subject]
    @State private var showAddSubject = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(subjects) { subject in
                    NavigationLink {
                        SubjectScheduleView(subject: subject)
                    } label: {
                        HStack(spacing: 12) {
                            subject.badge(size: 36)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(subject.name)
                                    .font(.system(size: 18))
                                Text("\(subject.schedules.count) scheduled")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: deleteSubjects)
            }
            .navigationTitle("Subjects")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddSubject = true
                    } label: {
                        Label("Add Subject", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSubject) {
                EditSubjectSheet()
            }
            .overlay {
                if subjects.isEmpty {
                    ContentUnavailableView(
                        "No Subjects",
                        systemImage: "person.2",
                        description: Text("Add a subject to start logging.")
                    )
                }
            }
        }
    }

    private func deleteSubjects(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(subjects[index])
        }
    }
}
