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
                Text(LocalizedStringKey("Change theme"))
                    .font(.title2.bold())
                    .padding(.vertical, 10)
                Picker("", selection: $selectedAppearance) {
                    ForEach(Appearance.allCases) { mode in
                        Text(LocalizedStringKey(mode.rawValue)).tag(mode)
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
