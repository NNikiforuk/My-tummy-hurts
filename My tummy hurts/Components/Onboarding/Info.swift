//
//  Info.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 24/09/2025.
//

import SwiftUI

struct Info: View {
    @Binding var isOnboarding: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(spacing: 20) {
                    HStack(alignment: .top) {
                        Image(systemName: "stethoscope")
                            .font(.title2)
                        Text("This app is for guidance only and shows simple stats. For serious or ongoing symptoms, please seek medical advice")
                    }
                    .padding(.top, 30)
                    .foregroundStyle(.accent)
                    .bold()
                
                NavigationLink(destination: HomeView(isOnboarding: $isOnboarding)) {
                    Button(action: {
                        isOnboarding = false
                        dismiss()
                    }) {
                        Text("Start")
                            .font(.title3).bold()
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.vertical, 20)
                }
                Spacer()
            }
            .padding(.top, 50)
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

