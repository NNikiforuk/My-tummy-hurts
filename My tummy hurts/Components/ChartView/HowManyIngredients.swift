//
//  HowManyIngredients.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 07/09/2025.
//

import SwiftUI

struct HowManyIngredients: View {
    @Binding var ingredientsToShow: Int
    @Binding var chartType: ChartMode
    
    @Environment(\.dynamicTypeSize) var sizeCategory
    
    let options = [1, 2, 3, 4, 5]
    
    var body: some View {
        VStack(alignment: .leading) {
            SectionTitle(title: "Top ingredients on chart", textColor: Color("SecondaryText"))
                .textCase(.uppercase)
            HStack(spacing: 8) {
                ForEach(options, id: \.self) { value in
                    Button {
                        withAnimation { ingredientsToShow = value }
                    } label: {
                        Text("\(value)")
                            .font(sizeCategory.isAccessibilitySize ? .caption2 : .body)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(Color("PrimaryText"))
                    }
                    .buttonStyle(.bordered)
                    .tint(ingredientsToShow == value ? .accent : .accent.opacity(0.3))
                }
            }
            .grayOverlayModifier()
        }
    }
}

#Preview("") {
    NavigationStack {
        HowManyIngredients(ingredientsToShow: .constant(3), chartType: .constant(.defaultChart))
    }
}
