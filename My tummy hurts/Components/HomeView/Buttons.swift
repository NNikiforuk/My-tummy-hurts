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
        Button("Delete", role: .destructive, action: action)
            .foregroundStyle(.red)
    }
}

struct DeleteBtnTextIcon: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(title, systemImage: icon, role: .destructive, action: action)
            .foregroundStyle(.red)
    }
}

struct SaveBtn: View {
    let action: () -> Void
    
    var body: some View {
        Button("Save", action: action)
            .bold()
    }
}

struct CancelBtn: View {
    let action: () -> Void
    
    var body: some View {
        Button("Cancel", role: .cancel, action: action)
    }
}
