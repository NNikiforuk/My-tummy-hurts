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
    @Published var showDeleteAlert: Bool = false
    @Published var ingredients: String = ""
    @Published var symptoms: String = ""
    
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
    
    func createMealNote() {
        dataService.createMealNote(ingredients: ingredients)
    }
    
    func createSymptomNote() {
        dataService.createSymptomNote(symptoms: symptoms)
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
        showDeleteAlert = false
        ingredients = ""
    }
    
    func clearSymptomStates() {
        showAddingSymptom = false
        showDeleteAlert = false
        symptoms = ""
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
