//
//  ChartView.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 05/09/2025.
//

import SwiftUI

struct ChartView: View {
    @EnvironmentObject var model: ViewModel
    
    @State private var analyticsType: AnalyticsMode = .general
    @State private var chartType: ChartMode = .defaultChart
    @State private var ingredientsToShow = 3
    @State private var hoursBack = 1
    @State private var selectedSymptomID: UUID?
    
    var noMealNotes: Bool {
        model.mealNotes.isEmpty
    }
    var noSymptomNotes: Bool {
        model.symptomNotes.isEmpty
    }
    
    var chartTitle: LocalizedStringKey {
        switch chartType {
        case .defaultChart:
            switch ingredientsToShow {
            case 1:
                return "Top ingredient followed by symptoms"
            default:
                return "Top \(ingredientsToShow) ingredients followed by symptoms"
            }
            
        default:
            switch ingredientsToShow {
            case 1:
                switch hoursBack {
                case 1:
                    return "Top ingredient in the 1-hour window before selected symptom"
                default:
                    return "Top ingredient in the \(hoursBack)-hour window before selected symptom"
                }
            default:
                switch hoursBack {
                case 1:
                    return "Top \(ingredientsToShow) ingredients in the 1-hour window before selected symptom"
                default:
                    return "Top \(ingredientsToShow) ingredients in the \(hoursBack)-hour window before selected symptom"
                }
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SiteTitle(title: "Analytics")
                    .frame(maxWidth: .infinity, alignment: .center)
                ChooseAnalytics(analyticsType: $analyticsType)
                NoDataTexts(analyticsType: $analyticsType, noMealNotes: noMealNotes, noSymptomNotes: noSymptomNotes)
                
                switch analyticsType {
                case .general: GeneralAnalytics(chartType: $chartType, ingredientsToShow: $ingredientsToShow, hoursBack: $hoursBack, selectedSymptomID: $selectedSymptomID, chartTitle: chartTitle, noMealNotes: noMealNotes, noSymptomNotes: noSymptomNotes)
                        .environmentObject(model)
                    
                case .history:
                    SymptomsHistory()
                        .environmentObject(model)
                }
            }
            .animation(.easeInOut, value: chartType)
        }
        .customBgModifier()
    }
}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ChartView()
                .environmentObject(ViewModel())
        }
    }
}
