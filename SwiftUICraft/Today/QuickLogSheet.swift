//
//  QuickLogSheet.swift
//  SwiftUICraft (display name: Routines)
//
//  Ad-hoc "+ Log" path. No schedule needed.
//  Use case: "had BM at 9:42 AM", "brushed teeth", "fed Buddy a treat".
//

import SwiftUI
import SwiftData
import PhotosUI
#if canImport(UIKit)
import UIKit
#endif

struct QuickLogSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Subject.sortOrder) private var subjects: [Subject]

    @State private var selectedSubjectID: UUID?
    @State private var name = ""
    @State private var doneAt: Date = .now
    @State private var notes = ""
    @State private var photoData: Data?
    @State private var photoPickerItem: PhotosPickerItem?
    #if canImport(UIKit) && !targetEnvironment(macCatalyst)
    @State private var showCamera = false
    #endif

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Subject", selection: $selectedSubjectID) {
                        ForEach(subjects) { subject in
                            HStack {
                                subject.badge(size: 24)
                                Text(subject.name)
                            }
                            .tag(Optional(subject.id))
                        }
                    }
                    .font(.system(size: 18))
                } header: {
                    Text("Subject").font(.system(size: 16))
                }

                Section {
                    TextField("Event (e.g. brushed teeth, BM, fed treat)", text: $name)
                        .font(.system(size: 18))
                } header: {
                    Text("What happened").font(.system(size: 16))
                }

                Section {
                    DatePicker("When", selection: $doneAt)
                        .font(.system(size: 18))
                } header: {
                    Text("When").font(.system(size: 16))
                }

                Section {
                    HStack(spacing: 14) {
                        PhotosPicker(selection: $photoPickerItem, matching: .images) {
                            Label("Library", systemImage: "photo.on.rectangle")
                                .font(.system(size: 14))
                        }
                        #if canImport(UIKit) && !targetEnvironment(macCatalyst)
                        Button {
                            showCamera = true
                        } label: {
                            Label("Camera", systemImage: "camera.fill")
                                .font(.system(size: 14))
                        }
                        #endif
                        Spacer()
                    }
                    .buttonStyle(.borderless)

                    #if canImport(UIKit)
                    if let data = photoData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .contextMenu {
                                Button(role: .destructive) {
                                    photoData = nil
                                } label: {
                                    Label("Remove photo", systemImage: "trash")
                                }
                            }
                    }
                    #endif
                } header: {
                    Text("Photo").font(.system(size: 16))
                }

                Section {
                    TextEditor(text: $notes)
                        .font(.system(size: 18))
                        .frame(minHeight: 80)
                } header: {
                    Text("Notes").font(.system(size: 16))
                }
            }
            .onChange(of: photoPickerItem) { _, item in
                guard let item else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        await MainActor.run {
                            photoData = data
                            photoPickerItem = nil
                        }
                    }
                }
            }
            #if canImport(UIKit) && !targetEnvironment(macCatalyst)
            .sheet(isPresented: $showCamera) {
                CameraCaptureView { data in
                    photoData = data
                }
            }
            #endif
            .navigationTitle("Quick Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.font(.system(size: 18))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Log") { save() }
                        .font(.system(size: 18, weight: .semibold))
                        .disabled(saveDisabled)
                }
            }
            .onAppear {
                if selectedSubjectID == nil {
                    selectedSubjectID = subjects.first?.id
                }
            }
        }
    }

    private var saveDisabled: Bool {
        name.trimmingCharacters(in: .whitespaces).isEmpty || selectedSubjectID == nil
    }

    private func save() {
        guard let subjectID = selectedSubjectID,
              let subject = subjects.first(where: { $0.id == subjectID }) else { return }
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let log = LogEntry(
            subject: subject,
            sourceRoutineID: nil,
            name: trimmed,
            iconName: "circle.fill",
            colorHex: subject.colorHex,
            doneAt: doneAt,
            notes: notes,
            photoData: photoData
        )
        modelContext.insert(log)
        dismiss()
    }
}
