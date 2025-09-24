//
//  StartIntroductionView.swift
//  Tummy hurts
//
//  Created by Natalia Nikiforuk on 11/03/2025.
//

import SwiftUI

struct StartIntroductionView: View {
    @Binding var isOnboarding: Bool
    
    var body: some View {
        VStack {
            LogoView()
            NavigationLink(destination: HomeView()) {
                Button(action: {
                    isOnboarding = false
                }) {
                    Text(LocalizedStringKey("Start"))
                        .font(.title2)
                }
                .buttonStyle(.borderedProminent)
                .padding(.vertical, 20)
            }
        }
    }
}

#Preview {
    StartIntroductionView(isOnboarding: .constant(false))
}
