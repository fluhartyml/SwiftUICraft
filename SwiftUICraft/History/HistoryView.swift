//
//  HistoryView.swift
//  SwiftUICraft (display name: Routines)
//
//  All-time log with filter and search. Demonstrates List virtualization
//  on a dataset that scales with daily logs over months / years.
//

import SwiftUI
import SwiftData
#if canImport(UIKit)
import UIKit
#endif

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LogEntry.doneAt, order: .reverse) private var allLogs: [LogEntry]
    @Query(sort: \Subject.sortOrder) private var subjects: [Subject]

    @State private var subjectFilterID: UUID? = nil
    @State private var nameSearch: String = ""
    @State private var viewingPhoto: IdentifiablePhoto?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterBar
                Divider()
                if filtered.isEmpty {
                    Spacer()
                    ContentUnavailableView(
                        "No History",
                        systemImage: "clock",
                        description: Text(allLogs.isEmpty
                            ? "Log an event from the Today tab to populate history."
                            : "No logs match the current filter.")
                    )
                    Spacer()
                } else {
                    List {
                        ForEach(filtered) { log in
                            row(for: log)
                        }
                        .onDelete(perform: deleteLogs)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("History")
            .sheet(item: $viewingPhoto) { photo in
                ImageViewerView(imageData: photo.data)
            }
        }
    }

    // MARK: - Filter bar

    private var filterBar: some View {
        VStack(spacing: 8) {
            Picker("Subject", selection: $subjectFilterID) {
                Text("All Subjects").tag(UUID?.none)
                ForEach(subjects) { subject in
                    Text(subject.name).tag(Optional(subject.id))
                }
            }
            .pickerStyle(.menu)
            .font(.system(size: 16))

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search event name", text: $nameSearch)
                    .font(.system(size: 16))
                    .textFieldStyle(.plain)
                if !nameSearch.isEmpty {
                    Button {
                        nameSearch = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.background.tertiary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Row

    private func row(for log: LogEntry) -> some View {
        HStack(spacing: 12) {
            #if canImport(UIKit)
            if let data = log.photoData, let uiImage = UIImage(data: data) {
                Button {
                    viewingPhoto = IdentifiablePhoto(data: data)
                } label: {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            } else {
                Image(systemName: log.iconName)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color(hex: log.colorHex))
                    .frame(width: 56, height: 56)
                    .background(Color(hex: log.colorHex).opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            #else
            Image(systemName: log.iconName)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color(hex: log.colorHex))
                .frame(width: 56, height: 56)
                .background(Color(hex: log.colorHex).opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            #endif

            VStack(alignment: .leading, spacing: 2) {
                Text(log.name)
                    .font(.system(size: 17, weight: .medium))
                HStack(spacing: 6) {
                    if let subject = log.subject {
                        Text(subject.name)
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                        Text("•").foregroundStyle(.tertiary)
                    }
                    Text(log.doneAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                if !log.notes.isEmpty {
                    Text(log.notes)
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }

    // MARK: - Filtering

    private var filtered: [LogEntry] {
        let trimmed = nameSearch.trimmingCharacters(in: .whitespaces).lowercased()
        return allLogs.filter { log in
            if let subjectID = subjectFilterID, log.subject?.id != subjectID { return false }
            if !trimmed.isEmpty && !log.name.lowercased().contains(trimmed) { return false }
            return true
        }
    }

    private func deleteLogs(at offsets: IndexSet) {
        let toDelete = offsets.map { filtered[$0] }
        for log in toDelete {
            modelContext.delete(log)
        }
    }
}
