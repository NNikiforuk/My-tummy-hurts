//
//  ChartView.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 05/09/2025.
//

import SwiftUI

struct ChartView: View {
    @EnvironmentObject var model: ViewModel
    
    @State private var analyticsType: AnalyticsMode = .calendarView
    @State private var chartType: ChartMode = .defaultChart
    @State private var ingredientsToShow = 3
    @State private var hoursBack = 1
    @State private var selectedSymptom: String? = nil
    @State private var selectedIngredient: String? = nil
    
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
                return "Top ingredient followed by any symptom"
            default:
                return "Top \(ingredientsToShow) ingredients followed by any symptom"
            }
            
        case .checkSpecificSymptom:
            switch ingredientsToShow {
            case 1:
                switch hoursBack {
                case 1:
                    return "Top ingredient in the 1-hour window before: \(selectedSymptom ?? "")"
                default:
                    return "Top ingredient in the \(hoursBack)-hour window before: \(selectedSymptom ?? "")"
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
                case .barChart: GeneralAnalytics(chartType: $chartType, ingredientsToShow: $ingredientsToShow, hoursBack: $hoursBack, selectedSymptom: $selectedSymptom, chartTitle: chartTitle, noMealNotes: noMealNotes, noSymptomNotes: noSymptomNotes)
                        .environmentObject(model)
                    
                case .calendarView:
                    if !model.symptomNotes.isEmpty {
                        CalendarChart(selectedIngredient: $selectedIngredient)
                            .environmentObject(model)
                    }
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
