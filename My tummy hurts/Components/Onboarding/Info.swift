//
//  Info.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 24/09/2025.
//

import SwiftUI

struct Info: View {
    @Binding var isOnboarding: Bool
    @Environment(\.dynamicTypeSize) var sizeCategory
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(spacing: 20) {
                    
                    if sizeCategory >= .accessibility4 {
                        VStack {
                            stetoscopeIcon
                            .padding(.bottom, 10)
                            text
                        }
                        .padding(.top, 10)
                    } else {
                        HStack(alignment: .top) {
                           stetoscopeIcon
                            text
                        }
                        .padding(.top, 30)
                    }
                    NavigationLink(destination: HomeView(isOnboarding: $isOnboarding)) {
                        Button(action: {
                            isOnboarding = false
                            dismiss()
                        }) {
                            Text("Start")
                                .font(.title3).bold()
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .foregroundStyle(.neutral)
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
    
    var stetoscopeIcon: some View {
        Image(systemName: "stethoscope")
            .font(.title2)
            .foregroundStyle(.accent)
    }
    
    var text: some View {
        Text("This app is for guidance only and shows simple stats. For serious or ongoing symptoms, please seek medical advice")
            .minimumScaleFactor(sizeCategory.customMinScaleFactor)
            .foregroundStyle(.accent)
            .bold()
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

