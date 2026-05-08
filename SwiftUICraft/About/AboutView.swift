//
//  AboutView.swift
//  SwiftUICraft (display name: Routines)
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    Image("AppIconImage")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)

                    Text("Routines")
                        .font(.system(size: 32, weight: .bold))

                    Text("Track whether you fed the dog, took the kids to the pool, or any other routine that matters in your household.")
                        .font(.system(size: 18))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 24)

                    Text("Build-Along 03 of Claudes X26 Swift6 Bible. Engineered with Claude by Anthropic.")
                        .font(.system(size: 14))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 24)

                    Divider().padding(.horizontal, 24)

                    VStack(spacing: 12) {
                        link("Portfolio", url: "https://fluharty.me")
                        link("Privacy", url: "https://fluharty.me/privacy")
                        link("Send Feedback", url: "mailto:michaelfluharty.developer@gmail.com")
                        link("Repo", url: "https://github.com/fluhartyml/SwiftUICraft")
                    }

                    Spacer(minLength: 24)

                    Text("v1.0  •  GPL v3 — share and share alike, attribution required")
                        .font(.system(size: 12))
                        .foregroundStyle(.tertiary)
                        .padding(.bottom, 16)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 24)
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }.font(.system(size: 18, weight: .semibold))
                }
            }
        }
    }

    private func link(_ label: String, url: String) -> some View {
        Group {
            if let target = URL(string: url) {
                Link(destination: target) {
                    HStack {
                        Text(label).font(.system(size: 18))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 18)
                    .background(.background.tertiary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
            }
        }
    }
}
