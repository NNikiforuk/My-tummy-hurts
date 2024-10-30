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
                .frame(width: 45, height: 45)
                .foregroundColor(.yellow)
        }
    }
}

#Preview {
    CustomButtonIcon(iconName: "swift", clicked: {})
}
