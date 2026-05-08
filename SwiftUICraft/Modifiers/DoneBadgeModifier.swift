//
//  DoneBadgeModifier.swift
//  SwiftUICraft (display name: Routines)
//

import SwiftUI

struct DoneBadgeModifier: ViewModifier {
    let isDone: Bool

    func body(content: Content) -> some View {
        HStack(spacing: 8) {
            content
            Spacer()
            Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 24))
                .foregroundStyle(isDone ? Color.green : Color.secondary)
        }
    }
}

extension View {
    func doneBadge(isDone: Bool) -> some View {
        modifier(DoneBadgeModifier(isDone: isDone))
    }
}
