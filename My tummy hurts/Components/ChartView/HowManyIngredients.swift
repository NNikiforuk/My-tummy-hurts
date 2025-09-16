//
//  HowManyIngredients.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 07/09/2025.
//

import SwiftUI

struct HowManyIngredients: View {
    @Binding var ingredientsToShow: Int
    
    let options = [1, 2, 3, 4, 5]
    
    var body: some View {
        VStack(alignment: .leading) {
            SectionTitle(title: "HOW MANY INGREDIENTS ON CHART")
            HStack(spacing: 8) {
                ForEach(options, id: \.self) { value in
                    Button {
                        withAnimation { ingredientsToShow = value }
                    } label: {
                        Text("\(value)")
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
