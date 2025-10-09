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
    @Published var savedMealNotes: [MealNote] = []
    @Published var savedSymptomNotes: [SymptomNote] = []
    
    init() {
        container = NSPersistentContainer(name: "My_tummy_hurts")
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

private extension CoreDataViewModel {
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

private extension String {
    var normalizedKey: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()
    }
}
