//
//  CustomModifiers.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 03/09/2025.
//

import Foundation
import SwiftUI

struct NoteModifier: ViewModifier {
    func body(content: Content) -> some View {
            content
            .frame(maxWidth: .infinity)
            .padding()
            .background(.yellow.opacity(0.08))
            .cornerRadius(15)
        }
}

extension View {
    func noteModifier() -> some View {
        modifier(NoteModifier())
    }
}

struct CustomPickerModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .environment(\.timeZone, .current)
            .datePickerStyle(.compact)
            .cornerRadius(8)
            .bold()
    }
}

extension View {
    func customPickerModifier() -> some View {
        modifier(CustomPickerModifier())
    }
}

struct CustomBgModifier: ViewModifier {
    func body(content: Content) -> some View {
            content
            .navigationBarTitleDisplayMode(.inline)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
}

extension View {
    func customBgModifier() -> some View {
        modifier(CustomBgModifier())
    }
}

struct GrayOverlayModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
//                    .fill(.bgc)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.gray.opacity(0.2), lineWidth: 1)
                    )
            )
    }
}

extension View {
    func grayOverlayModifier() -> some View {
        modifier(GrayOverlayModifier())
    }
}
