//
//  SubjectBadgeModifier.swift
//  SwiftUICraft (display name: Routines)
//

import SwiftUI

struct SubjectBadgeView: View {
    let iconName: String
    let colorHex: String
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: colorHex).opacity(0.18))
            Image(systemName: iconName)
                .font(.system(size: size * 0.5, weight: .semibold))
                .foregroundStyle(Color(hex: colorHex))
        }
        .frame(width: size, height: size)
    }
}

extension Subject {
    /// Visual badge for use in lists and headers.
    func badge(size: CGFloat = 36) -> some View {
        SubjectBadgeView(iconName: iconName, colorHex: colorHex, size: size)
    }
}
