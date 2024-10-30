//
//  CustomIcon.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 30/10/2024.
//

import SwiftUI

struct CustomButtonIcon: View {
    var iconName: String
    var clicked: () -> Void
    
    var body: some View {
        Button(action: clicked) {
            Image(systemName: iconName)
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .foregroundColor(.brown.opacity(0.6))
        }
    }
}

#Preview {
    CustomButtonIcon(iconName: "swift", clicked: {})
}
