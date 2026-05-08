//
//  EventStyleModifier.swift
//  SwiftUICraft (display name: Routines)
//
//  Custom ViewModifier driven by user-chosen color + icon.
//  This is the marquee teaching surface — a dynamic design system, not enum-based variants.
//

import SwiftUI

struct EventStyleModifier: ViewModifier {
    let colorHex: String
    let iconName: String

    func body(content: Content) -> some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color(hex: colorHex))
                .frame(width: 32)
            content
        }
    }
}

extension View {
    /// Applies the event's chosen color + icon as a leading badge.
    func eventStyle(colorHex: String, icon: String) -> some View {
        modifier(EventStyleModifier(colorHex: colorHex, iconName: icon))
    }
}
