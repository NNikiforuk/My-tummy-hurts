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
    var secondChartDataCache: [IngredientAnalysis2]?
    var cachedSymptomId: UUID?
    var cachedHourQty: Int?
    
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
        cachedSymptomId = nil
        cachedHourQty = nil
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
    func analyzeIngredientsWeighted() -> [IngredientAnalysis] {
        var ingredientStats: [String: (total: Int, symptomsCount: Int, weightedSymptoms: Double)] = [:]
        
        // "egg, milk, coffee"
        for meal in savedMealNotes {
            guard let mealTime = meal.createdAt,
                  let ingredients = meal.ingredients else { continue } // pętla przechodzi do nastepnego meal
            
            // ["egg", "milk", "coffee"]
            let ingredientsArray = ingredients.components(separatedBy: ", ")
            
            // zwraca array z wagami symptomów, które wystąpiły między 0 a 8h po posiłku z Double? bez nil-ów
            let symptomsAfter = savedSymptomNotes.compactMap { symptom -> Double? in
                guard let symptomTime = symptom.createdAt else { return nil } // przechodzimy do następnego symptomu
                let hoursAfter = symptomTime.timeIntervalSince(mealTime) / 3600 // ile h minęło od meal do symptomu?
                guard hoursAfter > 0 && hoursAfter <= 8.0 else { return nil }
                
                let weight = max(0.1, 1.0 - (hoursAfter / 10.0))
                return weight
            }
            
            let totalWeight = symptomsAfter.reduce(0, +)
            let hadSymptom = !symptomsAfter.isEmpty
            
            // "egg"
            for ingredient in ingredientsArray {
                // ingredientStats["egg"]
                let current = ingredientStats[ingredient] ?? (total: 0, symptomsCount: 0, weightedSymptoms: 0.0)
                
                ingredientStats[ingredient] = (
                    total: current.total + 1,
                    symptomsCount: current.symptomsCount + (hadSymptom ? 1 : 0),
                    weightedSymptoms: current.weightedSymptoms + totalWeight
                )
            }
        }
        
        // iterujemy po [:]
        let analyses = ingredientStats.map { (name, stats) in
            IngredientAnalysis(
                name: name,
                totalOccurrences: stats.total,
                symptomsOccurrences: stats.symptomsCount,
                weightedSymptoms: stats.weightedSymptoms
            )
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
        
        let result = analyzeIngredientsWeighted()
        firstChartDataCache = result
        return result
    }
    
    var firstChartDataTop10: [IngredientAnalysis] {
        Array(firstChartData.prefix(10))
    }
    
    //SECOND CHART
    func specificSyptomChart(selectedSymptomId: UUID?, selectedHourQty: Int) -> [IngredientAnalysis2]? {
        guard let selectedSymptom = findSpecificSymptom(selectedSymptomId: selectedSymptomId) else { return nil }
        guard let selectedSymptomTime = selectedSymptom.createdAt else { return nil }
        let mealsFromTimeline = catchMeals(selectedSymptomId: selectedSymptomId, selectedHourQty: selectedHourQty)
        let historicalData = firstChartData
        
        var summary: [IngredientAnalysis2] = []
        
        for meal in mealsFromTimeline {
            guard let mealTime = meal.createdAt else { continue }
            let hoursBefore = selectedSymptomTime.timeIntervalSince(mealTime) / 3600
            let timeProximity = max(0, 1.0 - (hoursBefore / Double(selectedHourQty)))
            
            guard let mealIngredients = meal.ingredients else { continue }
            let ingredientsArray = mealIngredients.components(separatedBy: ", ")
            
            for ingredient in ingredientsArray {
                let data = historicalData.first(where: { $0.name == ingredient })
                let historicalRisk: Double
                
                if let data = data, data.totalOccurrences >= 2 {
                    historicalRisk = data.suspicionRate
                } else {
                    historicalRisk = 0.5
                }
                
                let suspicionScore = timeProximity * historicalRisk
                
                if let existingIndex = summary.firstIndex(where: { $0.name == ingredient }) {
                    var existing = summary[existingIndex]
                    
                    existing.firstChartData = historicalData
                    
                    if suspicionScore > existing.suspicionScore {
                        existing.suspicionScore = suspicionScore
                        existing.timeProximity = timeProximity
                        existing.howLongAgo = hoursBefore
                    }
                    
                    if !existing.mealsList.contains(where: { $0.id == meal.id }) {
                        existing.mealsList.append(meal)
                    }
                    
                    summary[existingIndex] = existing
                } else {
                    let newIngredientAnalysis2 = IngredientAnalysis2(
                        name: ingredient,
                        suspicionScore: suspicionScore,
                        timeProximity: timeProximity,
                        howLongAgo: hoursBefore,
                        mealsList: [meal],
                        firstChartData: historicalData
                    )
                    summary.append(newIngredientAnalysis2)
                }
            }
        }
        
        summary.sort { $0.suspicionScore > $1.suspicionScore }
        return Array(summary.prefix(10))
    }
    
    func getSecondChartData(symptomId: UUID?, hours: Int) -> [IngredientAnalysis2] {
        specificSyptomChart(selectedSymptomId: symptomId,
                            selectedHourQty: hours) ?? []
    }
    
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

protocol ScoredIngredient: Identifiable {
    var name: String { get }
    var scoreValue: Double { get }
    var colorIntensity: Color { get }
    var riskLevel: String { get }
    var hasEnoughData: Bool { get }
    var totalOccurrences: Int { get }
    var symptomsOccurrences: Int? { get }
    var safeOccurrences: Int? { get }
    var legend: String { get }
}

extension ScoredIngredient {
    var colorIntensity: Color {
        switch scoreValue {
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
    var symptomsOccurrences: Int? { nil }
    var safeOccurrences: Int? { nil }
}

extension IngredientAnalysis: ScoredIngredient {
    var scoreValue: Double {
        suspicionRate
    }
}

extension IngredientAnalysis2: ScoredIngredient {
    var scoreValue: Double {
        suspicionScore
    }
}

struct IngredientAnalysis2: Identifiable {
    let id = UUID()
    let name: String
    var suspicionScore: Double
    var timeProximity: Double
    var howLongAgo: Double
    var mealsList: [MealNote]
    
    var legend: String {
        "\(Int(suspicionScore * 100))%"
    }
    
    var firstChartData: [IngredientAnalysis] = []
    
    var historicalData: IngredientAnalysis? {
        firstChartData.first(where: { $0.name == name })
    }
    
    var globalTotalOccurrences: Int {
        historicalData?.totalOccurrences ?? 0
    }
    
    var globalSymptomsOccurrences: Int {
        historicalData?.symptomsOccurrences ?? 0
    }
    
    var usedHistoricalData: Bool {
        (historicalData?.totalOccurrences ?? 0) >= 2
    }
    
    var riskLevel: String {
        if !usedHistoricalData {
            return "Insufficient data"
        }
        
        switch suspicionScore {
        case 0.6...: return "High suspicion"
        case 0.3..<0.6: return "Medium suspicion"
        case 0.1..<0.3: return "Low suspicion"
        default: return "Very low suspicion"
        }
    }
    
    var hasEnoughData: Bool {
        usedHistoricalData && globalTotalOccurrences >= 3
    }
    
    var totalOccurrences: Int {
        mealsList.count
    }
    
    var isSafe: Bool {
        usedHistoricalData && globalSymptomsOccurrences == 0 && suspicionScore == 0
    }
}

struct IngredientAnalysis: Identifiable {
    let id = UUID()
    let name: String
    let totalOccurrences: Int //Ile razy jadłam kiedykolwiek?
    let symptomsOccurrences: Int //Ile razy wystąpił symptom po zjedzeniu?
    let weightedSymptoms: Double
    
    var suspicionRate: Double {
        guard totalOccurrences > 0 else { return 0 }
        return weightedSymptoms / Double(totalOccurrences)
    }
    
    var displayScore: Double {
        suspicionRate * log(Double(totalOccurrences) + 1)
    }
    
    var legend: String {
        "\(Int(suspicionRate * 100))%"
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

extension CoreDataViewModel {
    static var previewWithData: CoreDataViewModel {
        let vm = CoreDataViewModel(inMemory: true)
        let context = vm.container.viewContext
        
        func createDate(daysAgo: Int, hour: Int, minute: Int = 0) -> Date {
            let now = Date()
            var components = Calendar.current.dateComponents([.year, .month, .day], from: now)
            components.hour = hour
            components.minute = minute
            
            let today = Calendar.current.date(from: components)!
            return today.addingTimeInterval(-Double(daysAgo) * 86400)
        }
        
        // 3 DNI TEMU
        let meal1 = MealNote(context: context)
        meal1.id = UUID()
        meal1.createdAt = createDate(daysAgo: 3, hour: 8, minute: 0)
        meal1.ingredients = "milk, cereal, banana"
        
        let symptom1 = SymptomNote(context: context)
        symptom1.id = UUID()
        symptom1.createdAt = createDate(daysAgo: 3, hour: 10, minute: 0)
        symptom1.symptom = "Diarrhea"
        
        let meal2 = MealNote(context: context)
        meal2.id = UUID()
        meal2.createdAt = createDate(daysAgo: 3, hour: 14, minute: 0)
        meal2.ingredients = "chicken, rice, vegetables"
        
        let meal3 = MealNote(context: context)
        meal3.id = UUID()
        meal3.createdAt = createDate(daysAgo: 3, hour: 19, minute: 0)
        meal3.ingredients = "cheese, pasta, tomato"
        
        let symptom2 = SymptomNote(context: context)
        symptom2.id = UUID()
        symptom2.createdAt = createDate(daysAgo: 3, hour: 21, minute: 0)
        symptom2.symptom = "Diarrhea"
        
        // 2 DNI TEMU
        let meal4 = MealNote(context: context)
        meal4.id = UUID()
        meal4.createdAt = createDate(daysAgo: 2, hour: 9, minute: 0)
        meal4.ingredients = "eggs, bread, coffee"
        
        let meal5 = MealNote(context: context)
        meal5.id = UUID()
        meal5.createdAt = createDate(daysAgo: 2, hour: 13, minute: 0)
        meal5.ingredients = "chicken, quinoa"
        
        let meal6 = MealNote(context: context)
        meal6.id = UUID()
        meal6.createdAt = createDate(daysAgo: 2, hour: 17, minute: 0)
        meal6.ingredients = "cheese, crackers"
        
        let symptom3 = SymptomNote(context: context)
        symptom3.id = UUID()
        symptom3.createdAt = createDate(daysAgo: 2, hour: 19, minute: 0)
        symptom3.symptom = "Diarrhea"
        
        // WCZORAJ
        let meal7 = MealNote(context: context)
        meal7.id = UUID()
        meal7.createdAt = createDate(daysAgo: 1, hour: 8, minute: 30)
        meal7.ingredients = "milk, oatmeal"
        
        let symptom4 = SymptomNote(context: context)
        symptom4.id = UUID()
        symptom4.createdAt = createDate(daysAgo: 1, hour: 10, minute: 30)
        symptom4.symptom = "Diarrhea"
        
        let meal8 = MealNote(context: context)
        meal8.id = UUID()
        meal8.createdAt = createDate(daysAgo: 1, hour: 12, minute: 0)
        meal8.ingredients = "chicken, salad"
        
        let meal9 = MealNote(context: context)
        meal9.id = UUID()
        meal9.createdAt = createDate(daysAgo: 1, hour: 16, minute: 0)
        meal9.ingredients = "bread, peanut butter"
        
        let symptom5 = SymptomNote(context: context)
        symptom5.id = UUID()
        symptom5.createdAt = createDate(daysAgo: 1, hour: 18, minute: 0)
        symptom5.symptom = "Diarrhea"
        
        // DZISIAJ
        let meal10 = MealNote(context: context)
        meal10.id = UUID()
        meal10.createdAt = createDate(daysAgo: 0, hour: 8, minute: 0)
        meal10.ingredients = "milk, eggs"
        
        let meal11 = MealNote(context: context)
        meal11.id = UUID()
        meal11.createdAt = createDate(daysAgo: 0, hour: 12, minute: 30)
        meal11.ingredients = "cheese, bread"
        
        let meal12 = MealNote(context: context)
        meal12.id = UUID()
        meal12.createdAt = createDate(daysAgo: 0, hour: 15, minute: 0)
        meal12.ingredients = "apple, almonds"
        
        let meal13 = MealNote(context: context)
        meal13.id = UUID()
        meal13.createdAt = createDate(daysAgo: 0, hour: 18, minute: 0)
        meal13.ingredients = "chicken, rice"
        
        let symptom6 = SymptomNote(context: context)
        symptom6.id = UUID()
        symptom6.createdAt = createDate(daysAgo: 0, hour: 19, minute: 30)
        symptom6.symptom = "Diarrhea"
        
        try? context.save()
        vm.fetchMeals()
        vm.fetchSymptoms()
        return vm
    }
}
