//
//  TopIngredients.swift
//  Tummy hurts
//
//  Created by Natalia Nikiforuk on 11/03/2025.
//

import SwiftUI
import Charts

struct TopIngredients: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(spacing: 40) {
                header(icon: "fork.knife", title: "Top ingredients", subtitle: "Find out which ingredients show up most often before discomfort")
                OnboardingColumnChart()
            }
            Spacer()
        }
        .padding()
    }
}

struct OnboardingColumnChart: View {
    var body: some View {
        Chart {
            BarMark(x: .value("Ingredient", NSLocalizedString("cow milk", comment: "")), y: .value("Count", 4))
                .foregroundStyle(.accent)
            BarMark(x: .value("Ingredient", NSLocalizedString("rye bread", comment: "")), y: .value("Count", 3))
                .foregroundStyle(.accent)
            BarMark(x: .value("Ingredient", NSLocalizedString("onion chips", comment: "")), y: .value("Count", 2))
                .foregroundStyle(.accent)
        }
        .frame(height: 200)
        .padding()
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
