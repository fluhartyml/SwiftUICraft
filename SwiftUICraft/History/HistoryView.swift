//
//  HistoryView.swift
//  SwiftUICraft (display name: Routines)
//
//  Phase 1 stub. Phase 5 fills it with the all-time list and filters.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \LogEntry.doneAt, order: .reverse) private var logs: [LogEntry]

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.tint)
                Text("History")
                    .font(.system(size: 28, weight: .bold))
                Text("Phase 5 brings filters and List virtualization. \(logs.count) log entries so far.")
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 30)
            }
            .navigationTitle("History")
        }
    }
}
