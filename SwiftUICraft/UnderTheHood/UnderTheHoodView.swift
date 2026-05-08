//
//  UnderTheHoodView.swift
//  SwiftUICraft (display name: Routines)
//

import SwiftUI

struct UnderTheHoodView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Routines is a household routine tracker built as Build-Along 03 of Claudes X26 Swift6 Bible. The marquee teaching surface is custom ViewModifiers driven by user data — see the Modifiers/ folder.")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                } header: {
                    Text("About this code").font(.system(size: 16))
                }

                Section {
                    ForEach(UnderTheHoodContent.mainAppFiles) { file in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(file.path)
                                .font(.system(size: 16, weight: .semibold))
                            Text(file.description)
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                } header: {
                    Text("Main app target").font(.system(size: 16))
                }

                Section {
                    ForEach(UnderTheHoodContent.widgetExtensionFiles) { file in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(file.path)
                                .font(.system(size: 16, weight: .semibold))
                            Text(file.description)
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                } header: {
                    Text("Widget Extension target").font(.system(size: 16))
                }
            }
            .navigationTitle("Under the Hood")
        }
    }
}
