//
//  GeneralAnalytics.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 07/09/2025.
//

import SwiftUI

struct GeneralAnalytics: View {
    @EnvironmentObject var model: ViewModel
    
    @Binding var chartType: ChartMode
    @Binding var ingredientsToShow: Int
    @Binding var hoursBack: Int
    @Binding var selectedSymptom: String?
    
    let chartTitle: LocalizedStringKey
    let noMealNotes: Bool
    let noSymptomNotes: Bool
    var firstChartData: [(String, Int)]
    var secondChartData: [(String, Int)]
    var howManyElFirstChartData: Int
    var howManyElSecondChartData: Int
    
    var body: some View {
        //JEZELI ISTNIEJA MEALS, SYMPTOMS
        if !noMealNotes && !noSymptomNotes {
            VStack(spacing: 40) {
                SelectChartType(chartType: $chartType)
                
                //SECOND TOGGLE SETTINGS
                if chartType == .checkSpecificSymptom {
                    VStack(alignment: .leading) {
                        HowManyHoursBack(value: $hoursBack)
                            .padding(.bottom, 40)
                        SectionTitle(title: "SELECT SYMPTOM", textColor: Color("SecondaryText"))
                        SelectElementPicker(pickerData: dataForPicker(mealsMode: false, model: model), pickerSelection: $selectedSymptom)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
                
                HowManyIngredients(ingredientsToShow: $ingredientsToShow, chartType: $chartType, howManyElFirstChartData: howManyElFirstChartData, howManyElSecondChartData: howManyElSecondChartData)
                
                //CHARTS
                VStack(alignment: .leading) {
                    SectionTitle(title: "POTENTIAL CAUSES FOR UPSET TUMMY", textColor: Color("SecondaryText"))
                    VStack {
                        switch chartType {
                        case .defaultChart:
                            titleOfChart(title: chartTitle)
                            BarChart(data: firstChartData)
                                .frame(height: 200)
                            
                        case .checkSpecificSymptom:
                            if selectedSymptom == nil {
                                VStack(alignment: .center) {
                                    NoDataAlert(text: "Select symptom above")
                                }
                            } else if secondChartData.isEmpty {
                                NoDataAlert(text: "Add more data to see the chart")
                            } else if selectedSymptom != nil {
                                titleOfChart(title: chartTitle)
                                BarChart(data: secondChartData)
                                    .frame(height: 200)
                            }
                        }
                    }
                    .padding()
                    .overlay {
                        RoundedRectangle(cornerRadius: 15).stroke(Color("SecondaryText").opacity(0.2))
                    }
                }
            }
        }
    }
    
    func titleOfChart(title: LocalizedStringKey) -> some View {
        Text(title)
            .bold()
            .padding()
            .padding(.bottom, 20)
            .foregroundStyle(Color("PrimaryText"))
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.center)
    }
}
