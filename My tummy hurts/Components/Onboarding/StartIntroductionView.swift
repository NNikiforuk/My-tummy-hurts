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
                            .padding()
                            .foregroundStyle(.accent)
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.accent, lineWidth: 0.5)
                            )
                            .padding(.top, 70)
                    }
                }
            }
    }
}

#Preview {
    StartIntroductionView(isOnboarding: .constant(false))
}
