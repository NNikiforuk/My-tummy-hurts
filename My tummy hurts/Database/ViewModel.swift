//
//  ViewModel.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 03/09/2025.
//

import SwiftUI
import CoreData

class CoreDataViewModel: ObservableObject {
    let container: NSPersistentContainer
    @Published var savedMealNotes: [MealNote] = [] { didSet { invalidateCache() } }
    @Published var savedSymptomNotes: [SymptomNote] = [] { didSet { invalidateCache() } }
    
    var firstChartDataCache: [IngredientAnalysis]?
    var secondChartDataCache: [IngredientAnalysis]?
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "My_tummy_hurts")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Error loading core data: \(error)")
            }
        }
        fetchMeals()
        fetchSymptoms()
    }
    
    func fetchMeals() {
        let request = NSFetchRequest<MealNote>(entityName: "MealNote")
        
        do {
            savedMealNotes = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching meals: \(error)")
        }
    }
    
    func fetchSymptoms() {
        let request = NSFetchRequest<SymptomNote>(entityName: "SymptomNote")
        
        do {
            savedSymptomNotes = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching symptoms: \(error)")
        }
    }
    
    func addMeal(createdAt: Date, ingredients: String) {
        let newMeal = MealNote(context: container.viewContext)
        
        newMeal.id = UUID()
        newMeal.createdAt = createdAt
        newMeal.ingredients = ingredients
        
        saveData(typeMeal: true)
    }
    
    func addSymptom(createdAt: Date, symptom: String, critical: Bool) {
        let newSymptom = SymptomNote(context: container.viewContext)
        
        newSymptom.id = UUID()
        newSymptom.createdAt = createdAt
        newSymptom.symptom = symptom
        newSymptom.critical = critical
        
        saveData(typeMeal: false)
    }
    
    func deleteAll() {
        let fetchRequestMeals = NSFetchRequest<NSFetchRequestResult>(entityName: "MealNote")
        let fetchRequestSymptoms = NSFetchRequest<NSFetchRequestResult>(entityName: "SymptomNote")
        let batchDeleteRequestMeals = NSBatchDeleteRequest(fetchRequest: fetchRequestMeals)
        let batchDeleteRequestSymptoms = NSBatchDeleteRequest(fetchRequest: fetchRequestSymptoms)
        
        do {
            try container.viewContext.execute(batchDeleteRequestMeals)
            saveData(typeMeal: true)
        } catch {
            print("Error deleting meals: \(error)")
        }
        
        do {
            try container.viewContext.execute(batchDeleteRequestSymptoms)
            saveData(typeMeal: false)
        } catch {
            print("Error deleting symptoms: \(error)")
        }
    }
    
    func deleteMeal(entity: MealNote) {
        container.viewContext.delete(entity)
        saveData(typeMeal: true)
    }
    
    func deleteSymptom(entity: SymptomNote) {
        container.viewContext.delete(entity)
        saveData(typeMeal: false)
    }
    
    func updateMeal(entity: MealNote, createdAt: Date, ingredients: String) {
        entity.createdAt = createdAt
        entity.ingredients = ingredients
        saveData(typeMeal: true)
    }
    
    func updateSymptom(entity: SymptomNote, createdAt: Date, symptom: String, critical: Bool) {
        entity.createdAt = createdAt
        entity.symptom = symptom
        entity.critical = critical
        saveData(typeMeal: false)
    }
    
    func saveData(typeMeal: Bool) {
        do {
            try container.viewContext.save()
            container.viewContext.refreshAllObjects()
            typeMeal ? fetchMeals() : fetchSymptoms()
        } catch let error {
            print("Error saving: \(error)")
        }
    }
    
    func invalidateCache() {
        firstChartDataCache = nil
        secondChartDataCache = nil
    }
}

extension CoreDataViewModel {
    @MainActor
    func ingredientSuggestions(prefix: String,
                               includeAllWhenEmpty: Bool = false,
                               limit: Int? = nil) -> [String] {
        let rows = savedMealNotes.compactMap(\.ingredients)
        return suggestions(from: rows,
                           splitOnSeparators: true,
                           prefix: prefix,
                           includeAllWhenEmpty: includeAllWhenEmpty,
                           limit: limit)
    }
    
    @MainActor
    func symptomSuggestions(prefix: String,
                            includeAllWhenEmpty: Bool = false,
                            limit: Int? = nil) -> [String] {
        let rows = savedSymptomNotes.compactMap(\.symptom)
        return suggestions(from: rows,
                           splitOnSeparators: false,
                           prefix: prefix,
                           includeAllWhenEmpty: includeAllWhenEmpty,
                           limit: limit)
    }
}

extension CoreDataViewModel {
    func suggestions(from rows: [String],
                     splitOnSeparators: Bool,
                     prefix: String,
                     includeAllWhenEmpty: Bool,
                     limit: Int?) -> [String] {
        guard !rows.isEmpty else { return [] }
        
        let rawPrefix = prefix.trimmingCharacters(in: .whitespacesAndNewlines)
        let q = normalize(rawPrefix)
        if q.isEmpty, !includeAllWhenEmpty { return [] }
        
        let separators = CharacterSet(charactersIn: ",，;；|/•\n\t")
        
        var freq: [String: Int] = [:]
        var canonical: [String: String] = [:]
        
        for row in rows {
            let parts = splitOnSeparators ? row.components(separatedBy: separators) : [row]
            var seenInThisRow = Set<String>()
            for raw in parts {
                let label = raw
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .trimmingCharacters(in: CharacterSet(charactersIn: "."))
                
                guard !label.isEmpty else { continue }
                let key = normalize(label)
                
                if !q.isEmpty, !key.hasPrefix(q) { continue }
                
                if seenInThisRow.insert(key).inserted {
                    freq[key, default: 0] += 1
                }
                if canonical[key] == nil { canonical[key] = label }
            }
        }
        
        var items: [(label: String, count: Int)] = []
        items.reserveCapacity(freq.count)
        for (key, count) in freq {
            if let label = canonical[key] {
                items.append((label, count))
            }
        }
        items.sort {
            if $0.count != $1.count { return $0.count > $1.count }
            return $0.label.localizedCaseInsensitiveCompare($1.label) == .orderedAscending
        }
        
        if let limit, limit > 0 { return Array(items.prefix(limit).map(\.label)) }
        return items.map(\.label)
    }
    
    func normalize(_ s: String) -> String {
        s.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
}

extension CoreDataViewModel {
    //PICKER DATA
    func dataForPicker(mealsMode: Bool, model: CoreDataViewModel, excluded: String? = nil) -> [String] {
        var array: [String] = []
        
        if mealsMode {
            for note in model.savedMealNotes {
                guard let s = note.ingredients else { continue }
                array.append(contentsOf:
                                s.split(separator: ",").map { String($0).normalizedToken }.filter { !$0.isEmpty }
                )
            }
        } else {
            for note in model.savedSymptomNotes {
                guard let s = note.symptom else { continue }
                array.append(contentsOf:
                                s.split(separator: ",").map { String($0).normalizedToken }.filter { !$0.isEmpty }
                )
            }
        }
        
        if let ex = excluded?.normalizedToken, !ex.isEmpty {
            array.removeAll { $0.caseInsensitiveCompare(ex) == .orderedSame }
        }
        
        var seen = Set<String>()
        let unique = array.compactMap { item -> String? in
            let key = item.lowercased()
            return seen.insert(key).inserted ? item : nil
        }
        
        return unique.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }
    
    
    
    //FIRST CHART
    var groupedNotesByDay: [(Date, [NoteEnum])] {
        let allNotes =  savedMealNotes.map(NoteEnum.meal) + savedSymptomNotes.map(NoteEnum.symptom)
        let dictionary = Dictionary(grouping: allNotes, by: { Calendar.current.startOfDay(for: $0.time) })
        let sortedDictionary = dictionary.sorted(by: {$0.key < $1.key})
        
        return sortedDictionary.map { (date, notes) in
            (date, notes.sorted { $0.time < $1.time })
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
    
    func analyzeIngredients() -> [IngredientAnalysis] {
        let connections = catchConnections()
        var mealsWithSymptoms: Set<String> = []
        
        for (meal, symptoms) in connections where !symptoms.isEmpty {
            if case let .meal(MealNote) = meal {
                mealsWithSymptoms.insert(MealNote.id?.uuidString ?? "")
            }
        }
        
        var ingredientStats:[String: (total: Int, withSymptom: Int)] = [:]
        
        for meal in savedMealNotes {
            guard let ingredientsExist = meal.ingredients else { continue }
            let ingredientsArray = ingredientsExist.components(separatedBy: ", ")
            let hadSymptom = mealsWithSymptoms.contains(meal.id?.uuidString ?? "")
            
            for ingredient in ingredientsArray {
                let current = ingredientStats[ingredient] ?? (total: 0, withSymptom: 0)
                
                ingredientStats[ingredient] = (
                    total: current.total + 1,
                    withSymptom: hadSymptom ? current.withSymptom + 1 : current.withSymptom
                )
            }
        }
        
        let analyses = ingredientStats.map { (name, stats) in
            IngredientAnalysis(name: name, totalOccurrences: stats.total, symptomsOccurrences: stats.withSymptom)
        }
        
        return analyses
            .sorted { first, second in
                if first.displayScore != second.displayScore {
                    return first.displayScore > second.displayScore
                }
                
                if first.suspicionRate != second.suspicionRate {
                    return first.suspicionRate > second.suspicionRate
                }
                
                if first.totalOccurrences != second.totalOccurrences {
                    return first.totalOccurrences > second.totalOccurrences
                }
                
                return first.name.localizedCaseInsensitiveCompare(second.name) == .orderedAscending
            }
            .prefix(10)
            .map { $0 }
    }
    
    var firstChartData: [IngredientAnalysis] {
        if let cached = firstChartDataCache {
            return cached
        }
        
        let result = analyzeIngredients()
        firstChartDataCache = result
        return result
    }
    
    //SECOND CHART
    
    
    
    //HORIZONTAL CHART
    func findSpecificSymptom(selectedSymptomId: UUID?) -> SymptomNote? {
        guard let selectedId = selectedSymptomId else { return nil }
        return savedSymptomNotes.first { $0.id == selectedId }
    }
    
    func startTime(selectedSymptomId: UUID?, selectedHourQty: Int) -> Date? {
        guard let symptom = findSpecificSymptom(selectedSymptomId: selectedSymptomId) else { return nil }
        guard let symptomTime = symptom.createdAt else { return nil }
        
        return Calendar.current.date(byAdding: .hour, value: -selectedHourQty, to: symptomTime)
    }
    
    func catchMeals(selectedSymptomId: UUID?, selectedHourQty: Int) -> [MealNote] {
        guard let startDate = startTime(selectedSymptomId: selectedSymptomId, selectedHourQty: selectedHourQty) else { return [] }
        guard let symptom = findSpecificSymptom(selectedSymptomId: selectedSymptomId) else { return [] }
        guard let symptomTime = symptom.createdAt else { return [] }
        
        return savedMealNotes
            .filter { el in
                guard let elTime = el.createdAt else { return false }
                return elTime >= startDate && elTime <= symptomTime
            }
    }
    
    func horizontalChartMeals(selectedSymptomId: UUID?, selectedHourQty: Int) -> [Event] {
        let catchedMeals = catchMeals(selectedSymptomId: selectedSymptomId, selectedHourQty: selectedHourQty)
        
        var events: [Event] = []
        
        for meal in catchedMeals {
            guard let mealTime = meal.createdAt else { return [] }
            guard let mealIngredients = meal.ingredients else { return [] }
            
            events.append(Event(date: mealTime, type: .meals, tag: nil, icon: "fork.knife", desc: mealIngredients))
        }
        return events
    }
    
    func horizontalChartSymptom(selectedSymptomId: UUID?) -> [Event] {
        guard let symptom = findSpecificSymptom(selectedSymptomId: selectedSymptomId) else { return [] }
        guard let symptomTime = symptom.createdAt else { return [] }
        guard let symptomDesc = symptom.symptom else { return [] }
        var events: [Event] = []
        events.append(Event(date: symptomTime, type: .symptoms, tag: nil, icon: "toilet", desc: symptomDesc))
        
        return events
    }
    
    func horizontalData(selectedSymptomId: UUID?, selectedHourQty: Int) -> [Event] {
        let meals = horizontalChartMeals(selectedSymptomId: selectedSymptomId, selectedHourQty: selectedHourQty)
        let symptom = horizontalChartSymptom(selectedSymptomId: selectedSymptomId)
        let allTogether = meals + symptom
        
        return allTogether.sorted(by: { $0.date < $1.date })
    }
}

private extension String {
    var normalizedKey: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()
    }
}

struct IngredientAnalysis: Identifiable {
    let id = UUID()
    let name: String
    let totalOccurrences: Int //Ile razy jadłam kiedykolwiek?
    let symptomsOccurrences: Int //Ile razy wystąpił symptom po zjedzeniu?
    
    var suspicionRate: Double {
        guard totalOccurrences > 0 else { return 0 }
        return Double(symptomsOccurrences) / Double(totalOccurrences)
    }
    
    var displayScore: Double {
        suspicionRate * log(Double(totalOccurrences) + 1)
    }
    
    var legend: String {
        "\(Int(suspicionRate * 100))%"
    }
    
    var colorIntensity: Color {
        switch suspicionRate {
        case 0..<0.3:
            return .accent.opacity(0.1)
        case 0.3..<0.6:
            return .accent.opacity(0.3)
        case 0.6..<0.8:
            return .accent.opacity(0.6)
        default:
            return .accent
        }
    }
    
    var riskLevel: String {
        switch suspicionRate {
        case 0:
            return "Safe"
        case 0..<0.3:
            return "Low risk"
        case 0.3..<0.6:
            return "Medium risk"
        case 0.6..<0.8:
            return "High risk"
        default:
            return "Very high risk"
        }
    }
    
    var hasEnoughData: Bool {
        totalOccurrences >= 3
    }
    
    var safeOccurrences: Int {
        totalOccurrences - symptomsOccurrences
    }
}
