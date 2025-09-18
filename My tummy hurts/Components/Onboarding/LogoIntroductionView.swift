//
//  WeekIntroductionView.swift
//  Tummy hurts
//
//  Created by Natalia Nikiforuk on 10/03/2025.
//

import SwiftUI

struct LogoIntroductionView: View {
    @Binding var isOnboarding: Bool
    
    var body: some View {
            VStack {
//                LogoView()
                
                Text(LocalizedStringKey("Eat. Track.\nUncover what’s hurting your gut"))
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 20)
            }
            .padding(.top, 50)
            .customBgModifier()
            .toolbar {
                ToolbarItem {
                    ToolbarSkipButton(isOnboarding: $isOnboarding)
                }
            }
    }
}

struct LogoView: View {
    var body: some View {
        Image("Logo")
            .resizable()
            .frame(width: 100, height: 100)
        Text("Tummy hurts")
            .font(.title.bold())
    }
}

#Preview {
    LogoIntroductionView(isOnboarding: .constant(false))
}
