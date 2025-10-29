//
//  GeneralAnalytics.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 07/09/2025.
//

import SwiftUI

struct GeneralAnalytics: View {
    @EnvironmentObject private var vm: CoreDataViewModel
    @Environment(\.dynamicTypeSize) var sizeCategory
    
    @Binding var chartType: ChartMode
    @Binding var hoursBack: Int
    @Binding var selectedSymptom: String?
    
    let chartTitle: String
    let noMealNotes: Bool
    let noSymptomNotes: Bool
    let ingredientsToShow: Int
    var firstChartData: [(String, Int)]
    var secondChartData: [(String, Int)]
    
    var body: some View {
        VStack(spacing: 40) {
            SelectChartType(chartType: $chartType)
            
            if firstChartData.isEmpty && secondChartData.isEmpty {
                NoDataAlert(text: "Add more meals and symptoms")
            } else {
                //SECOND TOGGLE SETTINGS
                if chartType == .checkSpecificSymptom {
                    VStack(alignment: .leading) {
                        HowManyHoursBack(value: $hoursBack)
                            .padding(.bottom, 40)
                        
                        if sizeCategory.isAccessibilitySize {
                            VStack {
                                HStack {
                                    SectionTitle(title: "Select symptom", textColor: Color("SecondaryText"))
                                        .textCase(.uppercase)
                                    Spacer()
                                }
                                Spacer()
                                SelectElementPicker(pickerData: vm.dataForPicker(mealsMode: false, model: vm), pickerSelection: $selectedSymptom)
                            }
                        } else {
                            HStack {
                                SectionTitle(title: "Select symptom", textColor: Color("SecondaryText"))
                                    .textCase(.uppercase)
                                Spacer()
                                SelectElementPicker(pickerData: vm.dataForPicker(mealsMode: false, model: vm), pickerSelection: $selectedSymptom)
                            }
                        }
                        
                        
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
                
                //CHARTS
                VStack(alignment: .leading) {
                    switch chartType {
                    case .defaultChart:
                        HStack {
                            Spacer()
                            titleOfChart(title: chartTitle)
                            Spacer()
                        }
                        BarChart(data: firstChartData)
                            .frame(height: 200)
                        
                    case .checkSpecificSymptom:
                        if selectedSymptom == nil {
                            VStack(alignment: .center) {
                                NoDataAlert(text: "Select symptom above")
                            }
                        } else if secondChartData.isEmpty {
                            NoDataAlert(text: "No data to show")
                        } else if selectedSymptom != nil {
                            HStack {
                                Spacer()
                                titleOfChart(title: chartTitle)
                                Spacer()
                            }
                            BarChart(data: secondChartData)
                                .frame(height: 200)
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    func titleOfChart(title: String) -> some View {
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

#Preview("ChartView") {
    NavigationStack {
        NavigationStack {
            ScrollView {
                GeneralAnalytics(
                    chartType: .constant(.checkSpecificSymptom),
                    hoursBack: .constant(1),
                    selectedSymptom: .constant("biegunka"),
                    chartTitle: "title",
                    noMealNotes: false,
                    noSymptomNotes: false,
                    ingredientsToShow: 5,
                    firstChartData: [("kuba", 8)],
                    secondChartData: [("niki", 3)]
                )
                .environmentObject(CoreDataViewModel.preview)
            }
        }
    }
}

