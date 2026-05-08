//
//  RoutineLogRow.swift
//  SwiftUICraft (display name: Routines)
//
//  Single row inside SubjectMealsSheet: toggle, schedule time, done-at, notes, photo.
//

import SwiftUI
import SwiftData
import PhotosUI
#if canImport(UIKit)
import UIKit
#endif

struct RoutineLogRow: View {
    @Environment(\.modelContext) private var modelContext

    let schedule: Routine
    let subject: Subject
    let existingLog: LogEntry?

    @State private var notes: String = ""
    @State private var hasLoadedNotes = false
    @State private var photoPickerItem: PhotosPickerItem?
    #if canImport(UIKit) && !targetEnvironment(macCatalyst)
    @State private var showCamera = false
    #endif
    @State private var viewingPhoto: IdentifiablePhoto?

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

            if isDone, let log = existingLog {
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
                if let data = log.photoData,
                   let uiImage = UIImage(data: data) {
                    Button {
                        viewingPhoto = IdentifiablePhoto(data: data)
                    } label: {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            log.photoData = nil
                        } label: {
                            Label("Remove photo", systemImage: "trash")
                        }
                    }
                }
                #endif

                TextField("Notes", text: $notes, axis: .vertical)
                    .font(.system(size: 16))
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: notes) { _, newValue in
                        log.notes = newValue
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
        .onChange(of: photoPickerItem) { _, item in
            guard let item, let log = existingLog else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        log.photoData = data
                        photoPickerItem = nil
                    }
                }
            }
        }
        #if canImport(UIKit) && !targetEnvironment(macCatalyst)
        .sheet(isPresented: $showCamera) {
            CameraCaptureView { data in
                existingLog?.photoData = data
            }
        }
        #endif
        .sheet(item: $viewingPhoto) { photo in
            ImageViewerView(imageData: photo.data)
        }
    }

    private func toggleDone(to newValue: Bool) {
        if newValue {
            let log = LogEntry(
                subject: subject,
                sourceRoutineID: schedule.id,
                name: schedule.name,
                iconName: schedule.iconName,
                colorHex: schedule.colorHex,
                doneAt: .now,
                notes: notes
            )
            modelContext.insert(log)
        } else {
            if let log = existingLog {
                modelContext.delete(log)
            }
            notes = ""
        }
    }
}

struct IdentifiablePhoto: Identifiable {
    let id = UUID()
    let data: Data
}
