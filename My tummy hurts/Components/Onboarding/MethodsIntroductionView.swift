//
//  MethodsIntroductionView.swift
//  Tummy hurts
//
//  Created by Natalia Nikiforuk on 11/03/2025.
//

import SwiftUI

struct MethodsIntroductionView: View {
    @Binding var isOnboarding: Bool
    
    var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                Text(LocalizedStringKey("There are two ways"))
                    .font(.title.bold())
                    .padding(.vertical, 20)
                
                VStack(alignment: .leading, spacing: 30) {
                    createMethod(title: "First method", text1: "Looks at all meals before each symptom.", text2: "Finds ingredients that appear most often before problems.")
                    createMethod(title: "Second method", text1: "Pick a symptom and how many hours back to look.", text2: "See what you ate in that time, even if no symptoms followed.")
                }
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "info.circle")
                        Text(LocalizedStringKey("Smart sorting"))
                    }
                    Text(LocalizedStringKey("Ingredients are counted and sorted by frequency and alphabetically."))
                    Text(LocalizedStringKey("This helps spot patterns you might not notice"))
                }
                .padding(.top, 40)
                Spacer()
            }
            .padding(.top, 50)
    }
    
    func createMethod(title: String, text1: String, text2: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
                Text(LocalizedStringKey(title))
                .underline()
                .font(.title2)
                .bold()
                .padding(.bottom, 15)
            HStack(alignment: .top) {
                Image(systemName: "1.circle")
                Text(LocalizedStringKey(text1))
                    .padding(.top, -2)
            }
            .padding(.bottom, 5)
            HStack(alignment: .top) {
                Image(systemName: "2.circle")
                Text(LocalizedStringKey(text2))
                    .padding(.top, -2)
            }
        }
    }
}

#Preview {
    MethodsIntroductionView(isOnboarding: .constant(false))
}
