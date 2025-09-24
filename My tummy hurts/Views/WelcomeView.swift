//
//  WelcomeView.swift
//  Tummy hurts
//
//  Created by Natalia Nikiforuk on 26/02/2025.
//

import SwiftUI

struct WelcomeView: View {
    @Binding var isOnboarding: Bool
    @AppStorage("appearance") private var selectedAppearance: Appearance = .system
    
    var colorScheme: ColorScheme? {
        switch selectedAppearance {
        case .system:
            return nil
        case .dark:
            return .dark
        case .light:
            return .light
        }
    }
    
    var body: some View {
        ZStack {
            Color("OnboardingBcg").ignoresSafeArea()
            TabView {
                LogoIntroductionView()
                InputDataView()
                TopIngredients()
                SpecificSymptom()
                MonthlyCalendar()
                Info(isOnboarding: $isOnboarding)
            }
            .tabViewStyle(PageTabViewStyle())
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("OnboardingBcg"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Onboarding") {
    NavigationStack {
        WelcomeView(isOnboarding: .constant(true))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {} label: {
                        Text("Skip")
                            .font(.body)
                            .foregroundColor(.accent)
                    }
                }
            }
            .toolbarBackground(Color("OnboardingBcg"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .background(Color("OnboardingBcg").ignoresSafeArea())
    }
    .environment(\.colorScheme, .light)
}

