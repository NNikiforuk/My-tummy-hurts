//
//  Info.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 24/09/2025.
//

import SwiftUI

struct Info: View {
    @Binding var isOnboarding: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(spacing: 20) {
                header(icon: "info.circle", title: "Additional info", subtitle: "")
                VStack(alignment: .leading) {
                    listItem(text: "List all the ingredients of your meals")
                    listItem(text: "Be as detailed as possible")
                    listItem(text: "More data = better graphs")
                }
                
                VStack {
                    HStack(alignment: .top) {
                        Image(systemName: "stethoscope")
                            .font(.title2)
                        Text("This app is for guidance only and shows simple stats. For serious or ongoing symptoms, please seek medical advice")
                    }
                    .padding(.top, 30)
                    .foregroundStyle(.accent)
                    .bold()
                }
                
                NavigationLink(destination: HomeView()) {
                    Button(action: {
                        isOnboarding = false
                    }) {
                        Text(LocalizedStringKey("Start"))
                            .font(.title3)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.vertical, 20)
                }
                
                Spacer()
            }
        }
        .padding()
    }
}

func listItem(text: String) -> some View {
    HStack(alignment: .center) {
        Circle()
            .frame(width: 5, height: 5)
        Text(text)
        Spacer()
    }
}

