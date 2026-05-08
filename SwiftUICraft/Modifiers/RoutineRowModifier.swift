//
//  RoutineRowModifier.swift
//  SwiftUICraft (display name: Routines)
//

import SwiftUI

struct RoutineRowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.background.tertiary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

extension View {
    func routineRow() -> some View {
        modifier(RoutineRowModifier())
    }
}
