//
//  SpecificSymptom.swift
//  Tummy hurts
//
//  Created by Natalia Nikiforuk on 11/03/2025.
//

import SwiftUI
import Charts

struct SpecificSymptom: View {
    @Environment(\.dynamicTypeSize) var sizeCategory
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                TimeWindowOnboardingView()
                OnboardingColumnChart()
                if sizeCategory.isAccessibilitySize {
                    LargeSizeLegend()
                        .frame(maxWidth: .infinity)
                }
                Spacer()
            }
            .padding()
        }
    }
}

struct TimeWindowOnboardingView: View {
    @Environment(\.dynamicTypeSize) var sizeCategory
    
    var body: some View {
        VStack(spacing: 40) {
            header(icon: "clock", title: "Check time windows", subtitle: "See what you ate x hours before each occurrence of the selected symptom. Which one occurred most often?")
                .minimumScaleFactor(sizeCategory.customMinScaleFactor)
            Chart {
                RuleMark(x: .value("Symptom", 0))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [4]))
                    .annotation(position: .top, alignment: .center) {
                        Text("diarrhea")
                            .font(.caption)
                            .foregroundStyle(.accent)
                    }
            }
            .chartXScale(domain: sizeCategory.isAccessibilitySize ? -5...1 : -15...0)
            .frame(height: 100)
            .padding()
        }
        .minimumScaleFactor(sizeCategory.customMinScaleFactor)
    }
}
