//
//  DismissKeyboardModifier.swift
//  EspaOil
//
//  Created by Jose E on 17/8/25.
//

import SwiftUI

struct DismissKeyboardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                TapGesture()
                    .onEnded { _ in
                        hideKeyboard()
                    }
            )
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

extension View {
    /// Añade la funcionalidad de ocultar el teclado al tocar fuera de cualquier campo de texto
    func dismissKeyboardOnTap() -> some View {
        modifier(DismissKeyboardModifier())
    }
}
