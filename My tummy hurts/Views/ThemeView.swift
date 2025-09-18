//
//  ThemeView.swift
//  Tummy hurts
//
//  Created by Natalia Nikiforuk on 22/07/2025.
//

import SwiftUI

struct ThemeView: View {
    @AppStorage("appearance") private var selectedAppearance: Appearance = .system
    
    var body: some View {
            VStack(spacing: 20) {
                Text("Change theme")
                    .font(.title2.bold())
                    .padding(.vertical, 10)
                    .foregroundStyle(Color("PrimaryText"))
                Picker("", selection: $selectedAppearance) {
                    ForEach(Appearance.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                            .foregroundStyle(Color("PrimaryText"))
                    }
                }
                .pickerStyle(.segmented)
                .clipShape(.rect(cornerRadius: 8))
                .labelsHidden()
                Spacer()
            }
            .customBgModifier()
    }
}

#Preview {
    ThemeView()
}
