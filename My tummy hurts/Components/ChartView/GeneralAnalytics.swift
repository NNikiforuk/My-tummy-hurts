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
    @Binding var selectedSymptomID: UUID?
    
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
    
    var selectedSymptom: SymptomNote? {
        if selectedSymptomID != nil {
            return model.symptomNotes.first { symptom in
                selectedSymptomID == symptom.id
            }
        }
        return nil
    }
    
    var backedTime: Date? {
        guard let time = selectedSymptom?.createdAt else { return nil }
        return Calendar.current.date(byAdding: .hour, value: -hoursBack, to: time)
    }
    
    var mealsFromTimeline: [MealNote]? {
        guard let timeBack = backedTime, let selectedSymptomTime = selectedSymptom?.createdAt else { return nil }
        
        return model.mealNotes.filter { meal in
            if let mealTime = meal.createdAt {
                return mealTime >= timeBack && mealTime <= selectedSymptomTime
            }
            return false
        }
    }
    
    var firstChartData: [(String, Int)] {
        sortTopIngredients(data: catchProblematicIngredients())
    }
    
    var secondChartData: [(String, Int)] {
        sortTopIngredients(data: substractIngredients())
    }
    
    var body: some View {
        //JEZELI ISTNIEJA MEALS, SYMPTOMS
        if !noMealNotes && !noSymptomNotes {
            SelectChartType(chartType: $chartType)
            HowManyIngredients(ingredientsToShow: $ingredientsToShow)
            
            //SECOND TOGGLE SETTINGS
            if chartType == .limitByHours {
                VStack(alignment: .leading) {
                    HowManyHoursBack(value: $hoursBack, range: 1...24)
                    SelectSymptom(selectedSymptomID: $selectedSymptomID, noSymptomNotes: noSymptomNotes)
                        .environmentObject(model)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            //CHARTS
            VStack(alignment: .leading) {
                switch chartType {
                case .defaultChart:
                    SectionTitle(title: chartTitle)
                    BarChart(data: firstChartData)
                        .frame(height: 250)
                        .padding()
                        .overlay {
                            RoundedRectangle(cornerRadius: 15).stroke(.gray.opacity(0.2))
                        }
                case .limitByHours:
                    if selectedSymptomID != nil {
                        SectionTitle(title: chartTitle)
                        BarChart(data: secondChartData)
                            .frame(height: 250)
                            .padding()
                            .overlay {
                                RoundedRectangle(cornerRadius: 15).stroke(.gray.opacity(0.2))
                            }
                    } else {
                        VStack(alignment: .center) {
                            NoDataAlert(text: "Choose data volume, how many hours and symptom")
                        }
                    }
                }
            }
        }
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
    
    func substractIngredients() -> [String] {
        guard let meals = mealsFromTimeline else { return [] }
        let data =  meals.compactMap { $0.ingredients }
        var result: [String] = []
        
        for el in data {
            if el.contains(",") {
                let splitted = el.components(separatedBy: ", ")
                
                for el in splitted {
                    result.append(el)
                }
            } else {
                result.append(el)
            }
        }
        return result
    }
}

//#Preview {
//    GeneralAnalytics()
//}
