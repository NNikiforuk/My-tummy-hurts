//
//  HowItWorksIntroductionView.swift
//  Tummy hurts
//
//  Created by Natalia Nikiforuk on 11/03/2025.
//

import SwiftUI

struct HowItWorksIntroductionView: View {
    @Binding var isOnboarding: Bool
    
    var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                Text(LocalizedStringKey("How it works?"))
                    .font(.title.bold())
                    .padding(.vertical, 20)
                
                VStack(alignment: .leading, spacing: 30) {
                    createHStack(text: "Enter what you ate and drank", icon: "fork.knife")
                    createHStack(text: "Note any discomfort like bloating, diarrhea etc", icon: "toilet")
                    createHStack(text: "See on the chart which food might be causing issues", icon: "chart.bar")
                    createHStack(text: "The more data you add, the more accurate the analysis will be", icon: "info.square")
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
    
    func createHStack(text: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .frame(width: 20)
            Text(LocalizedStringKey(text))
                .padding(.top, -4)
        }
    }
}

#Preview {
    HowItWorksIntroductionView(isOnboarding: .constant(false))
}
