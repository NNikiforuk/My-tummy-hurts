//
//  ViewModel.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 03/09/2025.
//

import SwiftUI

class ViewModel: ObservableObject {
    @Published var mealNotes: [MealNote] = []
    @Published var symptomNotes: [SymptomNote] = []
    
    let dataService = PersistenceController.shared
    
    @Published var showAddingMeal: Bool = false
    @Published var showAddingSymptom: Bool = false
    @Published var showDeleteAlert: Bool = false
    @Published var ingredients: String = ""
    @Published var symptoms: String = ""
    
    init() {
        getAllMealNotes()
        getAllSymptomNotes()
    }
    
    func getAllMealNotes() {
        mealNotes = dataService.readMealNotes()
    }
    
    func getAllSymptomNotes() {
        symptomNotes = dataService.readSymptomNotes()
    }
    
    func createMealNote() {
        dataService.createMealNote(ingredients: ingredients)
        getAllMealNotes()
    }
    
    func createSymptomNote() {
        dataService.createSymptomNote(symptoms: symptoms)
        getAllSymptomNotes()
    }
    
    func toggleCritical(symptomNote: SymptomNote) {
        dataService.updateSymptomNote(entity: symptomNote, critical: !symptomNote.critical)
        getAllSymptomNotes()
    }
    
    func deleteMealNote(mealNote: MealNote) {
        dataService.deleteMealNote(mealNote)
        getAllMealNotes()
    }
    
    func deleteSymptomNote(symptomNote: SymptomNote) {
        dataService.deleteSymptomNote(symptomNote)
        getAllSymptomNotes()
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
}
