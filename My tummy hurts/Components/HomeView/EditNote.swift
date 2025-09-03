//
//  EditNote.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 03/09/2025.
//

import SwiftUI

struct EditSymptom: View {
    @EnvironmentObject var model: ViewModel
    
    var note: SymptomNote
    
    @State private var newSymptoms = ""
    @State private var rows: [Row] = []
    
    var body: some View {
        VStack(spacing: 20) {
            SiteTitle(title: "Edit symptom")
            DatePicker(
                LocalizedStringKey("Symptom time"),
                selection: Binding(
                    get: { note.createdAt ?? Date() },
                    set: { note.createdAt = $0 }
                ),
                displayedComponents: [.date, .hourAndMinute]
            )
            .customPickerModifier()
            AddEditRows(newItems: $newSymptoms, rows: $rows, meal: false)
            Spacer()
        }
        .customBgModifier()
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                DeleteBtn(action: { model.showDeleteAlert = true })
                SaveBtn(action: {
                    model.createSymptomNote()
                    model.clearSymptomStates()
                })
            }
        }
        .alert(LocalizedStringKey("Do you want to delete this symptom?"), isPresented: $model.showDeleteAlert) {
            CancelBtn(action: {  model.clearSymptomStates() })
            DeleteBtn(action: {  model.deleteSymptomNote(symptomNote: note) })
        }
    }
}

struct EditMeal: View {
    @EnvironmentObject var model: ViewModel
    
    var note: MealNote
    
    @State private var newIngredients = ""
    @State private var rows: [Row] = []
    
    var body: some View {
        VStack(spacing: 20) {
            SiteTitle(title: "Edit meal")
            DatePicker(
                LocalizedStringKey("Meal time"),
                selection: Binding(
                    get: { note.createdAt ?? Date() },
                    set: { note.createdAt = $0 }
                ),
                displayedComponents: [.date, .hourAndMinute]
            )
            .customPickerModifier()
            AddEditRows(newItems: $newIngredients, rows: $rows, meal: true)
            Spacer()
        }
        .customBgModifier()
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Delete") {
                    model.showDeleteAlert = true
                }
                Button("Save") {
                    model.createMealNote()
                    model.clearMealStates()
                }
            }
        }
        .alert(LocalizedStringKey("Do you want to delete this meal?"), isPresented: $model.showDeleteAlert) {
            Button("Cancel", role: .cancel) {
                model.clearMealStates()
            }
            Button("Delete", role: .destructive) {
                model.deleteMealNote(mealNote: note)
            }
        }
    }
}
