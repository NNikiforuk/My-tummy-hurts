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
    
    var groupedNotesByDay: [(Date, [NoteEnum])] {
        let allNotes = model.mealNotes.map(NoteEnum.meal) + model.symptomNotes.map(NoteEnum.symptom)
        let grouped = Dictionary(grouping: allNotes, by: { Calendar.current.startOfDay(for: $0.time) })
        let sorted = grouped.sorted(by: {$0.key < $1.key})
        let mapped = sorted.map { (date, notes) in
            (date, notes.sorted { $0.time < $1.time })
        }
        
        return mapped
    }
    
    var firstChartData: [(String, Int)] {
        sortTopIngredients(data: catchProblematicIngredients())
    }
    
    var secondChartData: [(String, Int)] {
        calcSortIngredients()
    }
    
    var body: some View {
        //JEZELI ISTNIEJA MEALS, SYMPTOMS
        if !noMealNotes && !noSymptomNotes {
            VStack(spacing: 40) {
                SelectChartType(chartType: $chartType)
                HowManyIngredients(ingredientsToShow: $ingredientsToShow)
                
                //SECOND TOGGLE SETTINGS
                if chartType == .checkSpecificSymptom {
                    VStack(alignment: .leading) {
                        HowManyHoursBack(value: $hoursBack, range: 1...24)
                            .padding(.bottom, 40)
                        SectionTitle(title: "SELECT SYMPTOM")
                        SelectElementPicker(pickerData: dataForPicker(mealsMode: false, model: model), pickerSelection: $selectedSymptom)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
                
                //CHARTS
                VStack(alignment: .leading) {
                    SectionTitle(title: "CHART")
                    VStack {
                        switch chartType {
                        case .defaultChart:
                            titleOfChart(title: chartTitle)
                            BarChart(data: firstChartData)
                                .frame(height: 300)
                            
                        case .checkSpecificSymptom:
                            if secondChartData.isEmpty {
                                NoDataAlert(text: "Add more data to see the chart")
                            } else {
                                if selectedSymptom != nil {
                                    titleOfChart(title: chartTitle)
                                    BarChart(data: secondChartData)
                                } else {
                                    VStack(alignment: .center) {
                                        NoDataAlert(text: "Choose data volume, how many hours and symptom")
                                    }
                                }
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
            .padding()
            .padding(.bottom, 20)
            .foregroundStyle(Color("SecondaryText"))
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.center)
    }
    
    func catchConnections() -> [(meal: NoteEnum, symptoms: [NoteEnum])] {
        var summary: [(meal: NoteEnum, symptoms: [NoteEnum])] = []
        
        for (_, notes) in groupedNotesByDay {
            var currentMeal: NoteEnum?
            var resultSymptoms: [NoteEnum] = []
            
            func saveSummary() {
                if let meal = currentMeal, !resultSymptoms.isEmpty {
                    summary.append((meal: meal, symptoms: resultSymptoms))
                }
            }
            
            for event in notes {
                //Jeżeli napotykam meal
                if !event.isSymptom {
                    saveSummary()
                    currentMeal = event
                    resultSymptoms = []
                }
                
                //Jeżeli napotykam symptom
                if event.isSymptom && currentMeal != nil {
                    resultSymptoms.append(event)
                }
            }
            saveSummary()
        }
        return summary
    }
    
    func catchProblematicIngredients() -> [String] {
        let catchedConnections = catchConnections()
        var result: [String] = []
        
        for (meal, _) in catchedConnections {
            if case let .meal(meal) = meal, let desc = meal.ingredients {
                if desc.contains(",") {
                    let splitted = desc.components(separatedBy: ", ")
                    
                    for el in splitted {
                        result.append(el)
                    }
                } else {
                    result.append(desc)
                }
            }
        }
        return result
    }
    
    func sortTopIngredients(data: [String]) -> [(String, Int)] {
        var counts: [String: Int] = [:]
        
        for el in data {
            counts[el] = (counts[el] ?? 0) + 1
        }
        
        let countedIngredients = counts
        
        let sorted = countedIngredients.sorted {
            if $0.value == $1.value {
                return $0.key < $1.key
            } else {
                return $0.value > $1.value
            }
        }
        return Array(sorted.prefix(ingredientsToShow))
    }
    
    func filterBySelectedSymptom() -> [SymptomNote] {
        guard let selectedSpecificSymptom = selectedSymptom else { return [] }
        
        return model.symptomNotes.filter { symptom in
            symptom.symptoms?.contains(selectedSpecificSymptom) == true
        }
    }
    
    func hoursBack(selectedSymptom: SymptomNote) -> Date {
        let symptomTime = selectedSymptom.createdAt!
        
        return Calendar.current.date(byAdding: .hour, value: -hoursBack, to: symptomTime)!
    }
    
    func collectMealsFromTimeline(selectedSymptom: SymptomNote, timeBack: Date) -> [MealNote] {
        let selectedSymptomTime = selectedSymptom.createdAt!
        
        return model.mealNotes.filter { meal in
            if let mealTime = meal.createdAt {
                return mealTime >= timeBack && mealTime <= selectedSymptomTime
            }
            return false
        }
    }
    
    func collectIngredients() -> [String] {
        let filteredSymptoms = filterBySelectedSymptom()
        var ingredients: [String] = []
        
        for symptom in filteredSymptoms {
            let backedTime = hoursBack(selectedSymptom: symptom)
            let collectedMeals = collectMealsFromTimeline(selectedSymptom: symptom, timeBack: backedTime)
            
            for meal in collectedMeals {
                let ings = meal.ingredients?.components(separatedBy: ", ")
                
                ings.map { el in
                    ingredients.append(contentsOf: el)
                }
            }
        }
        return ingredients
    }
    
    func calcSortIngredients() -> [(String, Int)] {
        let data = collectIngredients()
        var counts: [String: Int] = [:]
        
        for el in data {
            counts[el] = (counts[el] ?? 0) + 1
        }
        
        let sorted = counts.sorted {
            if $0.value == $1.value {
                return $0.key < $1.key
            } else {
                return $0.value > $1.value
            }
        }
        return Array(sorted.prefix(ingredientsToShow))
    }
}
