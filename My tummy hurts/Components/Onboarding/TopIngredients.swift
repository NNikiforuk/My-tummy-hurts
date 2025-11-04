//
//  TopIngredients.swift
//  Tummy hurts
//
//  Created by Natalia Nikiforuk on 11/03/2025.
//

import SwiftUI
import Charts

struct TopIngredients: View {
    @Environment(\.dynamicTypeSize) var sizeCategory
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 40) {
                VStack(spacing: 40) {
                    header(icon: "fork.knife", title: "Top ingredients", subtitle: "Check which of the ingredients you have eaten may be problematic")
                    upperChartPart(ingredient: "cow milk", suspicionRate: 1.0, calc: "3 of 3 meals", barText: "Very high risk")
                    upperChartPart(ingredient: "chocolate", suspicionRate: 0.4, calc: "2 of 5 meals", barText: "Medium risk")
                }
                Spacer()
            }
            .padding()
            .minimumScaleFactor(sizeCategory.customMinScaleFactor)
        }
    }
}

@ViewBuilder
func header(icon: String, title: LocalizedStringKey, subtitle: LocalizedStringKey) -> some View {
    VStack(alignment: .leading, spacing: 10) {
        HStack(alignment: .top) {
            Image(systemName: icon)
            Text(title)
                .font(.headline)
        }
        Text(subtitle)
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
}

@ViewBuilder
func upperChartPart(ingredient: LocalizedStringKey, suspicionRate: Double, calc: LocalizedStringKey, barText: LocalizedStringKey) -> some View {
    VStack(alignment: .leading, spacing: 8) {
        HStack {
            Text(ingredient)
                .bold()
            Spacer()
            
            Text("\(min(Int(suspicionRate * 100), 100))%")
                .font(.title3)
                .bold()
                .foregroundColor(.accent)
        }
        
        Text(calc)
            .font(.caption)
            .foregroundColor(.secondary)
        
        VStack(alignment: .leading, spacing: 4) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 32)
                    
                    if suspicionRate > 0 {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .accent,
                                        .accent.opacity(0.7)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geometry.size.width * min(suspicionRate, 1.0),
                                height: 32
                            )
                    }
                    
                    if suspicionRate > 0.3 {
                        HStack {
                            Text(barText)
                                .font(.caption)
                                .bold()
                                .foregroundColor(.white)
                                .padding(.leading, 8)
                            Spacer()
                        }
                    }
                }
            }
            .frame(height: 32)
        }
    }
}
