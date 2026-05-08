//
//  UnderTheHoodView.swift
//  SwiftUICraft (display name: Routines)
//
//  Phase 1 stub. Phase 9 fills it with the LockBox-pattern in-app source viewer
//  driven by hand-authored UnderTheHoodContent.swift.
//

import SwiftUI

struct UnderTheHoodView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "wrench.and.screwdriver")
                    .font(.system(size: 60))
                    .foregroundStyle(.tint)
                Text("Under the Hood")
                    .font(.system(size: 28, weight: .bold))
                Text("Phase 9 brings the in-app source viewer with the full file map and per-file callouts.")
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 30)
            }
            .navigationTitle("Under the Hood")
        }
    }
}
