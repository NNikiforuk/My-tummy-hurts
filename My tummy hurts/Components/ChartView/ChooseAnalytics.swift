//
//  ChooseAnalytics.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 07/09/2025.
//

import SwiftUI
import Foundation

enum AnalyticsMode: String, CaseIterable, Identifiable {
    case barChart = "Bar chart"
    case calendarView = "Calendar view"
    var id: Self { self }
}

struct ChooseAnalytics: View {
    @Binding var analyticsType: AnalyticsMode
    
    var body: some View {
        VStack {
            Picker("Choose analytics", selection: $analyticsType) {
                ForEach(AnalyticsMode.allCases) { el in
                    Text(el.rawValue)
                        .foregroundStyle(Color("PrimaryText"))
                }
            }
        }
        .pickerStyle(.segmented)
    }
}
