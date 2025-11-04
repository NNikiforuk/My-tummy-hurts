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
            VStack(alignment: .leading, spacing: 40) {
                header(icon: "clock", title: "Check time windows", subtitle: "See what you ate x hours before each occurrence of the selected symptom. What could have caused the discomfort?")
                    .minimumScaleFactor(sizeCategory.customMinScaleFactor)
                upperChartPart(ingredient: "cow milk", suspicionRate: 0.45, calc: "2 of 2 meals in history", barText: "Medium suspicion")
                Spacer()
            }
            .padding()
        }
    }
}

