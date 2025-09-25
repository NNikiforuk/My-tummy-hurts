//
//  ChartView.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 05/09/2025.
//

import SwiftUI

struct ChartView: View {
    @EnvironmentObject private var vm: CoreDataViewModel
    
    @State private var analyticsType: AnalyticsMode = .barChart
    @State private var chartType: ChartMode = .defaultChart
    @State private var ingredientsToShow = 3
    @State private var hoursBack = 1
    @State private var selectedSymptom: String? = "biegunka"
    @State private var selectedFirstIngredient: String? = nil
    @State private var selectedSecondIngredient: String? = nil
    @State private var selectedDate: Date = Date()
    
    var noMealNotes: Bool {
        vm.savedMealNotes.isEmpty
    }
    var noSymptomNotes: Bool {
        vm.savedSymptomNotes.isEmpty
    }
    
    var chartTitle: String {
        switch chartType {
        case .defaultChart:
            switch ingredientsToShow {
            case 1:
                return "Top ingredient followed by any symptom"
            default:
                if howManyElFirstChartData < ingredientsToShow {
                    return "Top \(ingredientsToShow) ingredients followed by any symptom (\(howManyElFirstChartData) found)"
                } else {
                    return "Top \(ingredientsToShow) ingredients followed by any symptom"
                }
            }
            
        case .checkSpecificSymptom:
            switch ingredientsToShow {
            case 1:
                return "Top ingredient in the \(hoursBack)-hour window before: \(selectedSymptom ?? "")"
            default:
                if howManyElSecondChartData < ingredientsToShow {
                    return "Top \(ingredientsToShow) ingredients in the \(hoursBack)-hour window before: \(selectedSymptom ?? "") (\(howManyElSecondChartData) found)"
                } else {
                    return "Top \(ingredientsToShow) ingredients in the \(hoursBack)-hour window before: \(selectedSymptom ?? "")"
                }
            }
        }
    }
    
    var groupedNotesByDay: [(Date, [NoteEnum])] {
        let allNotes =  vm.savedMealNotes.map(NoteEnum.meal) + vm.savedSymptomNotes.map(NoteEnum.symptom)
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
    
    var howManyElFirstChartData: Int {
        firstChartData.count
    }
    
    var howManyElSecondChartData: Int {
        secondChartData.count
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SiteTitle(title: "Analytics")
                    .frame(maxWidth: .infinity, alignment: .center)
                ChooseAnalytics(analyticsType: $analyticsType)
                
                if vm.savedMealNotes.count < 5 || vm.savedSymptomNotes.count < 5 {
                    NoDataAlert(text: "Add minimum 5 meals and 5 negative symptoms to see the charts. Detail matters: add more to unlock better insights")
                } else {
                    switch analyticsType {
                    case .barChart: GeneralAnalytics(chartType: $chartType, ingredientsToShow: $ingredientsToShow, hoursBack: $hoursBack, selectedSymptom: $selectedSymptom, chartTitle: chartTitle, noMealNotes: noMealNotes, noSymptomNotes: noSymptomNotes, firstChartData: firstChartData, secondChartData: secondChartData)
                        
                    case .calendarView:
                        if !noSymptomNotes {
                            CalendarChart(selectedFirstIngredient: $selectedFirstIngredient, selectedSecondIngredient: $selectedSecondIngredient, selectedDate: $selectedDate)
                        }
                    }
                }
            }
            .animation(.easeInOut, value: chartType)
        }
        .customBgModifier()
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
    
    func filterBySelectedSymptom() -> [SymptomNote] {
        guard let selectedSpecificSymptom = selectedSymptom else { return [] }
        
        return vm.savedSymptomNotes.filter { symptom in
            symptom.symptoms?.contains(selectedSpecificSymptom) == true
        }
    }
    
    func hoursBack(selectedSymptom: SymptomNote) -> Date {
        let symptomTime = selectedSymptom.createdAt!
        
        return Calendar.current.date(byAdding: .hour, value: -hoursBack, to: symptomTime)!
    }
    
    func collectMealsFromTimeline(selectedSymptom: SymptomNote, timeBack: Date) -> [MealNote] {
        let selectedSymptomTime = selectedSymptom.createdAt!
        
        return vm.savedMealNotes.filter { meal in
            if let mealTime = meal.createdAt {
                return mealTime >= timeBack && mealTime <= selectedSymptomTime
            }
            return false
        }
    }
}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ChartView()
                .environmentObject(CoreDataViewModel())
        }
    }
}
