//
//  EditNote.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 03/09/2025.
//

import SwiftUI

struct Row: Identifiable, Equatable {
    var id = UUID()
    var text = ""
}

struct EditMeal: View {
    @EnvironmentObject var model: ViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var newIngredients = ""
    @State private var mealCreatedAt: Date = Date()
    @State private var rows: [Row] = []
    
    var note: MealNote
    
    var noteToRows: [Row] {
        let text = note.ingredients ?? ""
        return text.split(separator: ",").map{ Row(text: String($0) ) }
    }
    
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
            
            VStack(alignment: .leading, spacing: 8) {
                SectionTitle(title: "Meal ingredients")
                NewRows(newNote: $newIngredients, rows: $rows, meal: true)
                AppendingRowBtn(rows: $rows)
            }
            Spacer()
        }
        .onAppear {
            rows = noteToRows
            mealCreatedAt = note.createdAt ?? Date()
        }
        
        .customBgModifier()
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Delete") {
                    model.showDeleteMealAlert = true
                }
                Button("Save") {
                    model.updateMealNote(entity: note, createdAt: mealCreatedAt, ingredients: newIngredients)
                    model.clearMealStates()
                    dismiss()
                }
                .disabled(newIngredients.isEmpty)
            }
        }
        .alert(LocalizedStringKey("Do you want to delete this meal?"), isPresented: $model.showDeleteMealAlert) {
            Button("Cancel", role: .cancel) {
                model.clearMealStates()
            }
            Button("Delete", role: .destructive) {
                model.deleteMealNote(mealNote: note)
                dismiss()
            }
        }
    }
}

struct EditSymptom: View {
    @EnvironmentObject var model: ViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var newSymptoms = ""
    @State private var symptomCreatedAt: Date = Date()
    @State private var rows: [Row] = []
    @State private var chosenColor: SymptomTagsEnum = .blue
    
    var note: SymptomNote
    var noteToRows: [Row] {
        let text = note.symptoms ?? ""
        return text.split(separator: ",").map{ Row(text: String($0) ) }
    }
    
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
            
            SymptomTags(chosenColor: $chosenColor)
            
            VStack(alignment: .leading, spacing: 8) {
                SectionTitle(title: "Negative symptoms")
                NewRows(newNote: $newSymptoms, rows: $rows, meal: false)
                AppendingRowBtn(rows: $rows)
            }
            Spacer()
        }
        .customBgModifier()
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                DeleteBtn(action: { model.showDeleteSymptomAlert = true })
                SaveBtn(action: {
                    model.updateSymptomNote(entity: note, createdAt: symptomCreatedAt, symptoms: newSymptoms, critical: chosenColor == .blue ? false : true)
                    model.clearSymptomStates()
                    dismiss()
                })
            }
        }
        .alert(LocalizedStringKey("Do you want to delete this symptom?"), isPresented: $model.showDeleteSymptomAlert) {
            CancelBtn(action: {  model.clearSymptomStates() })
            DeleteBtn(action: {
                model.deleteSymptomNote(symptomNote: note)
                dismiss()
            })
        }
        .onAppear {
            rows = noteToRows
            
            if note.critical {
                chosenColor = SymptomTagsEnum.red
            } else {
                chosenColor = SymptomTagsEnum.blue
            }
            
        }
    }
}

struct AppendingRowBtn: View {
    @Binding var rows: [Row]
    
    var body: some View {
        Button {
            withAnimation {
                rows.append(Row())
            }
        } label: {
            PlusIcon()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
