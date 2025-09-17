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
            //            applyMealsFilter()
        } catch let error {
            print("Error fetching meals: \(error)")
        }
    }
    
    func fetchSymptoms() {
        let request = NSFetchRequest<SymptomNote>(entityName: "SymptomNote")
        
        do {
            savedSymptomNotes = try container.viewContext.fetch(request)
            //            applySymptomsFilter()
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
    
    func addSymptom(createdAt: Date, symptoms: String, critical: Bool) {
        let newSymptom = SymptomNote(context: container.viewContext)
        
        newSymptom.id = UUID()
        newSymptom.createdAt = createdAt
        newSymptom.symptoms = symptoms
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
    
    func updateSymptom(entity: SymptomNote, createdAt: Date, symptoms: String, critical: Bool) {
        entity.createdAt = createdAt
        entity.symptoms = symptoms
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

//class ViewModel: ObservableObject {
//    @Published var mealNotes: [MealNote] = []
//    @Published var symptomNotes: [SymptomNote] = []
//
//    let dataService = PersistenceController.shared
//    var ctx: NSManagedObjectContext { dataService.container.viewContext }
//    var changeObserver: NSObjectProtocol?
//
//    @Published var showAddingMeal: Bool = false
//    @Published var showAddingSymptom: Bool = false
//    @Published var showDeleteAllAlert: Bool = false
//    @Published var showDeleteMealAlert: Bool = false
//    @Published var showDeleteSymptomAlert: Bool = false
//    @Published var ingredients: String = ""
//    @Published var symptoms: String = ""
//    @Published var createdAtMeals: Date = Date()
//    @Published var createdAtSymptoms: Date = Date()
//
//    init() {
//        reload()
//        changeObserver = NotificationCenter.default.addObserver(
//            forName: .NSManagedObjectContextObjectsDidChange,
//            object: ctx,
//            queue: .main
//        ) { [weak self] _ in
//            self?.reload()
//        }
//    }
//
//    deinit {
//        if let token = changeObserver {
//            NotificationCenter.default.removeObserver(token)
//        }
//    }
//
//    func updateMealNote(entity: MealNote, createdAt: Date? = nil, ingredients: String? = nil) {
//        dataService.updateMealNote(entity: entity, createdAt: createdAt, ingredients: ingredients)
//        reload()
//    }
//
//    func updateSymptomNote(entity: SymptomNote, createdAt: Date? = nil, symptoms: String? = nil, critical: Bool? = nil) {
//        dataService.updateSymptomNote(entity: entity, createdAt: createdAt, symptoms: symptoms, critical: critical)
//        reload()
//    }
//
//    func createMealNote() {
//        dataService.createMealNote(ingredients: ingredients, createdAt: createdAtMeals)
//    }
//
//    func createMealNote(ingredients: String, createdAt: Date) {
//            dataService.createMealNote(ingredients: ingredients, createdAt: createdAt)
//        }
//
//    func createSymptomNote() {
//        dataService.createSymptomNote(symptoms: symptoms, createdAt: createdAtSymptoms)
//    }
//
//    func createSymptomNote(symptoms: String, createdAt: Date) {
//            dataService.createSymptomNote(symptoms: symptoms, createdAt: createdAt)
//        }
//
//    func toggleCritical(symptomNote: SymptomNote) {
//        dataService.updateSymptomNote(entity: symptomNote, critical: !symptomNote.critical)
//    }
//
//    func deleteMealNote(mealNote: MealNote) {
//        dataService.deleteMealNote(mealNote)
//    }
//
//    func deleteSymptomNote(symptomNote: SymptomNote) {
//        dataService.deleteSymptomNote(symptomNote)
//    }
//
//    func clearMealStates() {
//        showAddingMeal = false
//        showDeleteMealAlert = false
//        ingredients = ""
//        createdAtMeals = Date()
//    }
//
//    func clearSymptomStates() {
//        showAddingSymptom = false
//        showDeleteSymptomAlert = false
//        symptoms = ""
//        createdAtSymptoms = Date()
//    }
//
//    func resetDB() {
//        dataService.deleteAll()
//        ctx.reset()
//        mealNotes.removeAll()
//        symptomNotes.removeAll()
//        reload()
//    }
//
//    func reload() {
//        ctx.perform { [weak self] in
//            guard let self else { return }
//            let meals = self.dataService.readMealNotes()
//            let symptoms = self.dataService.readSymptomNotes()
//            DispatchQueue.main.async {
//                self.mealNotes = meals
//                self.symptomNotes = symptoms
//            }
//        }
//    }
//}
