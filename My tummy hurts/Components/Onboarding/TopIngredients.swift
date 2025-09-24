//
//  TopIngredients.swift
//  Tummy hurts
//
//  Created by Natalia Nikiforuk on 11/03/2025.
//

import SwiftUI
import Charts

struct TopIngredients: View {
    @Binding var isOnboarding: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            TopIngredientsOnboardingView()
            Spacer()
        }
        .padding()
    }
}

struct TopIngredientsOnboardingView: View {
    var body: some View {
        VStack(spacing: 40) {
            header(icon: "fork.knife", title: "Top ingredients", subtitle: "Find out which ingredients show up most often before discomfort")
            OnboardingColumnChart()
        }
    }
}

struct OnboardingColumnChart: View {
    var body: some View {
        Chart {
            BarMark(x: .value("Ingredient", "cow milk"), y: .value("Count", 4))
                .foregroundStyle(.accent)
            BarMark(x: .value("Ingredient", "rye bread"), y: .value("Count", 3))
                .foregroundStyle(.accent)
            BarMark(x: .value("Ingredient", "onion chips"), y: .value("Count", 2))
                .foregroundStyle(.accent)
        }
        .frame(height: 200)
        .padding()
    }
}

@ViewBuilder
func header(icon: String, title: String, subtitle: String) -> some View {
    VStack(alignment: .leading, spacing: 10) {
        HStack {
            Image(systemName: icon)
            Text(LocalizedStringKey(title))
                .font(.headline)
        }
        Text(LocalizedStringKey(subtitle))
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
}
