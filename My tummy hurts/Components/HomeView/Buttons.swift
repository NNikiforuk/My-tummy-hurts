//
//  Buttons.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 03/09/2025.
//

import Foundation
import SwiftUI

struct DeleteBtn: View {
    let action: () -> Void
    
    var body: some View {
        Button(LocalizedStringKey("Delete"), role: .destructive, action: action)
            .foregroundStyle(.red)
    }
}

struct DeleteBtnTextIcon: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(LocalizedStringKey(title), systemImage: icon, role: .destructive, action: action)
            .foregroundStyle(.red)
    }
}

struct SaveBtn: View {
    let action: () -> Void
    
    var body: some View {
        Button(LocalizedStringKey("Save"), action: action)
    }
}

struct CancelBtn: View {
    let action: () -> Void
    
    var body: some View {
        Button(LocalizedStringKey("Cancel"), role: .cancel, action: action)
    }
}
