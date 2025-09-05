//
//  ViewModel.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 03/09/2025.
//

import SwiftUI
import CoreData

class ViewModel: ObservableObject {
    @Published var mealNotes: [MealNote] = []
    @Published var symptomNotes: [SymptomNote] = []
    
    let dataService = PersistenceController.shared
    var ctx: NSManagedObjectContext { dataService.container.viewContext }
    var changeObserver: NSObjectProtocol?
    
    @Published var showAddingMeal: Bool = false
    @Published var showAddingSymptom: Bool = false
    @Published var showDeleteAllAlert: Bool = false
    @Published var showDeleteMealAlert: Bool = false
    @Published var showDeleteSymptomAlert: Bool = false
    @Published var ingredients: String = ""
    @Published var symptoms: String = ""
    @Published var createdAtMeals: Date = Date()
    @Published var createdAtSymptoms: Date = Date()
    
    init() {
        reload()
        changeObserver = NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextObjectsDidChange,
            object: ctx,
            queue: .main
        ) { [weak self] _ in
            self?.reload()
        }
    }
    
    deinit {
        if let token = changeObserver {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    func updateMealNote(entity: MealNote, createdAt: Date? = nil, ingredients: String? = nil) {
        dataService.updateMealNote(entity: entity, createdAt: createdAt, ingredients: ingredients)
        ctx.reset()
        reload()
    }
    
    func updateSymptomNote(entity: SymptomNote, createdAt: Date? = nil, symptoms: String? = nil, critical: Bool? = nil) {
        dataService.updateSymptomNote(entity: entity, createdAt: createdAt, symptoms: symptoms, critical: critical)
        ctx.reset()
        reload()
    }
    
    func createMealNote() {
        dataService.createMealNote(ingredients: ingredients, createdAt: createdAtMeals)
    }
    
    func createMealNote(ingredients: String, createdAt: Date) {
            dataService.createMealNote(ingredients: ingredients, createdAt: createdAt)
        }
    
    func createSymptomNote() {
        dataService.createSymptomNote(symptoms: symptoms, createdAt: createdAtSymptoms)
    }
    
    func createSymptomNote(symptoms: String, createdAt: Date) {
            dataService.createSymptomNote(symptoms: symptoms, createdAt: createdAt)
        }
    
    func toggleCritical(symptomNote: SymptomNote) {
        dataService.updateSymptomNote(entity: symptomNote, critical: !symptomNote.critical)
    }
    
    func deleteMealNote(mealNote: MealNote) {
        dataService.deleteMealNote(mealNote)
    }
    
    func deleteSymptomNote(symptomNote: SymptomNote) {
        dataService.deleteSymptomNote(symptomNote)
    }
    
    func clearMealStates() {
        showAddingMeal = false
        showDeleteMealAlert = false
        ingredients = ""
        createdAtMeals = Date()
    }
    
    func clearSymptomStates() {
        showAddingSymptom = false
        showDeleteSymptomAlert = false
        symptoms = ""
        createdAtSymptoms = Date()
    }
    
    func resetDB() {
        dataService.deleteAll()
        ctx.reset()
        mealNotes.removeAll()
        symptomNotes.removeAll()
        reload()
    }
    
    func reload() {
        ctx.perform { [weak self] in
            guard let self else { return }
            let meals = self.dataService.readMealNotes()
            let symptoms = self.dataService.readSymptomNotes()
            DispatchQueue.main.async {
                self.mealNotes = meals
                self.symptomNotes = symptoms
            }
        }
    }
}
