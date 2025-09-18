//
//  WelcomeView.swift
//  Tummy hurts
//
//  Created by Natalia Nikiforuk on 26/02/2025.
//

import SwiftUI

struct WelcomeView: View {
    @Binding var isOnboarding: Bool
    
    var body: some View {
        TabView {
            LogoIntroductionView(isOnboarding: $isOnboarding)
            HowItWorksIntroductionView(isOnboarding: $isOnboarding)
            MethodsIntroductionView(isOnboarding: $isOnboarding)
            AdvantagesIntroductionView(isOnboarding: $isOnboarding)
            StartIntroductionView(isOnboarding: $isOnboarding)
        }
        .tabViewStyle(PageTabViewStyle())
        .customBgModifier()
    }
}

#Preview {
    WelcomeView(isOnboarding: .constant(false))
}
