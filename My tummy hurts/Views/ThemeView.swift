//
//  ThemeView.swift
//  Tummy hurts
//
//  Created by Natalia Nikiforuk on 22/07/2025.
//

import SwiftUI

struct ThemeView: View {
    @Environment(\.dynamicTypeSize) var sizeCategory
    @AppStorage("appearance") private var selectedAppearance: Appearance = .system
    @ScaledMetric(relativeTo: .footnote) private var fontRefSize = 50.0
    
    var fontScalingFactor: CGFloat {
        max(1, (fontRefSize / 100))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Change theme")
                .font(.title2.bold())
                .padding(.vertical, 10)
                .foregroundStyle(Color("PrimaryText"))
            Picker("", selection: $selectedAppearance) {
                ForEach(Appearance.allCases) { mode in
                    Text(mode.localized)
                        .tag(mode)
                        .foregroundStyle(Color("PrimaryText"))
                }
            }
            .pickerStyle(.segmented)
            .fixedSize()
            .scaleEffect(fontScalingFactor)
            .frame(minHeight: 30 * fontScalingFactor)
            Spacer()
        }
        .customBgModifier()
    }
}

#Preview {
    ThemeView()
}
