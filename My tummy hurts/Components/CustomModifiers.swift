//
//  CustomModifiers.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 03/09/2025.
//

import Foundation
import SwiftUI

struct CustomBgModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("BackgroundColor"))
    }
}

extension View {
    func customBgModifier() -> some View {
        modifier(CustomBgModifier())
    }
}

struct NoteModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundStyle(Color("PrimaryText"))
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color("NeutralColor"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color("SecondaryText").opacity(0.2), lineWidth: 1)
                    )
            )
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
            .foregroundStyle(Color("PrimaryText"))
    }
}

extension View {
    func customPickerModifier() -> some View {
        modifier(CustomPickerModifier())
    }
}

struct GrayOverlayModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("BackgroundColor"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color("SecondaryText").opacity(0.2), lineWidth: 1)
                    )
            )
    }
}

extension View {
    func grayOverlayModifier() -> some View {
        modifier(GrayOverlayModifier())
    }
}

struct TextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(5)
            .padding(.horizontal, 10)
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color("SecondaryText"), lineWidth: 1)
            }
            .foregroundStyle(Color("PrimaryText"))
            .lineLimit(1)
            .textInputAutocapitalization(.never)
    }
}

extension View {
    func textFieldModifier() -> some View {
        modifier(TextFieldModifier())
    }
}

struct NoteTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 14).padding(.vertical, 10)
            .disableAutocorrection(true)
            .lineLimit(1)
            .textInputAutocapitalization(.never)
            .foregroundStyle(.primary)
            .background(Color(uiColor: .systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.secondary.opacity(0.45), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

extension View {
    func noteTextFieldModifier() -> some View {
        modifier(NoteTextFieldModifier())
    }
}

struct SuggestionsModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .padding(.top, 6)
            .zIndex(2)
            .transition(.move(edge: .top).combined(with: .opacity))
    }
}

extension View {
    func suggestionsModifier() -> some View {
        modifier(SuggestionsModifier())
    }
}
