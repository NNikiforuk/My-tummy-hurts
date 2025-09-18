//
//  AdvantagesIntroductionView.swift
//  Tummy hurts
//
//  Created by Natalia Nikiforuk on 14/03/2025.
//

import SwiftUI

struct AdvantagesIntroductionView: View {
    @Binding var isOnboarding: Bool
    
    var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                Text(LocalizedStringKey("Why this app?"))
                    .font(.title.bold())
                    .padding(.vertical, 20)
                
                VStack(alignment: .leading, spacing: 20) {
                    createHStack(text: "Simple interface")
                    createHStack(text: "No annoying or unnecessary features you'll never use")
                    createHStack(text: "No registration")
                    createHStack(text: "You can use it offline")
                }
                Spacer()
            }
            .padding(.top, 50)
            .customBgModifier()
            .toolbar {
                ToolbarItem {
                    ToolbarSkipButton(isOnboarding: $isOnboarding)
                }
            }
    }
    
    func createHStack(text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark")
                .frame(width: 20)
            Text(LocalizedStringKey(text))
                .padding(.top, -3)
        }
    }
}


#Preview {
    AdvantagesIntroductionView(isOnboarding: .constant(false))
}
