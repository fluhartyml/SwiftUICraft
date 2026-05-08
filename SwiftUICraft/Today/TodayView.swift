//
//  TodayView.swift
//  SwiftUICraft (display name: Routines)
//
//  Phase 1 stub. Phase 2 fills it with all subjects' today + ad-hoc log path.
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @Query private var subjects: [Subject]

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "tray.full.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.tint)
                Text("Today")
                    .font(.system(size: 28, weight: .bold))
                Text("Phase 2 builds out the per-subject sheet and the ad-hoc + Log button. For now, \(subjects.count) subject(s) seeded.")
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 30)
            }
            .navigationTitle("Today")
        }
    }
}
