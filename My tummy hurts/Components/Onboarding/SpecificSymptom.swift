//
//  SpecificSymptom.swift
//  Tummy hurts
//
//  Created by Natalia Nikiforuk on 11/03/2025.
//

import SwiftUI
import Charts

struct SpecificSymptom: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            TimeWindowOnboardingView()
            OnboardingColumnChart()
            Spacer()
        }
        .padding()
    }
}

struct TimeWindowOnboardingView: View {
    var body: some View {
        VStack(spacing: 40) {
            header(icon: "clock", title: "Check time windows", subtitle: "See what you ate x hours before each occurrence of the selected symptom. Which one occurred most often?")
            
            Chart {
                RuleMark(x: .value("Symptom", 0))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [4]))
                    .annotation(position: .top, alignment: .center) {
                        Text("diarrhea")
                            .font(.caption)
                            .foregroundStyle(.accent)
                    }
            }
            .chartXScale(domain: -15...1)
            .frame(height: 100)
            .padding()
        }
    }
}
