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
    //    @EnvironmentObject var model: ViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: CoreDataViewModel
    
    @State private var newIngredients = ""
    @State private var mealCreatedAt: Date = Date()
    @State private var rows: [Row] = []
    @State private var showDeleteMealAlert: Bool = false
    
        @ObservedObject var note: MealNote
//    let note: MealNote
    
    var noteToRows: [Row] {
        let text = note.ingredients ?? ""
        return text.split(separator: ",").map{ Row(text: String($0).trimmingCharacters(in: .whitespacesAndNewlines) ) }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            SiteTitle(title: "Edit meal")
            DatePicker(
                LocalizedStringKey("Meal time"),
                selection: $mealCreatedAt,
                displayedComponents: [.date, .hourAndMinute]
            )
            .customPickerModifier()
            
            VStack(alignment: .leading, spacing: 8) {
                SectionTitle(title: "Meal ingredients", textColor: Color("PrimaryText"))
                    .padding(.bottom, 20)
                NewRows(newNote: $newIngredients, rows: $rows, meal: true)
                AppendingRowBtn(rows: $rows)
            }
            Spacer()
        }
        .onAppear {
            mealCreatedAt = note.createdAt ?? Date()
            newIngredients = note.ingredients ?? ""
            rows = noteToRows
        }
        .customBgModifier()
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                //                Button("Delete") {
                ////                    model.showDeleteMealAlert = true
                //                    showDeleteMealAlert.toggle()
                //                }
                DeleteBtn(action: { showDeleteMealAlert = true })
                Button("Save") {
                    //                    model.updateMealNote(entity: note, createdAt: mealCreatedAt, ingredients: newIngredients)
                    //                    model.clearMealStates()
                    //                    dismiss()
                    vm.updateMeal(entity: note, createdAt: mealCreatedAt, ingredients: newIngredients)
                    dismiss()
                }
                .disabled(newIngredients.isEmpty)
            }
        }
        .alert(LocalizedStringKey("Do you want to delete this meal?"), isPresented: $showDeleteMealAlert) {
            //            Button("Cancel", role: .cancel) {
            ////                model.clearMealStates()
            //                dismiss()
            //            }
            CancelBtn(action: {  })
            //            Button("Delete", role: .destructive) {
            ////                model.deleteMealNote(mealNote: note)
            ////                dismiss()
            //                vm.deleteMeal(entity: note)
            //                dismiss()
            //            }
            DeleteBtn(action: {
                vm.deleteMeal(entity: note)
                dismiss()
            })
        }
    }
}

struct EditSymptom: View {
    //    @EnvironmentObject var model: ViewModel
    @EnvironmentObject private var vm: CoreDataViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var newSymptoms = ""
    @State private var symptomCreatedAt: Date = Date()
    @State private var rows: [Row] = []
    @State private var critical: Bool = false
    @State private var showDeleteSymptomAlert: Bool = false
    
    //    var note: SymptomNote
    let note: SymptomNote
    
    var noteToRows: [Row] {
        let text = note.symptoms ?? ""
        return text.split(separator: ",").map{ Row(text: String($0) ) }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            SiteTitle(title: "Edit symptom")
            DatePicker(
                LocalizedStringKey("Symptom time"),
                selection: $symptomCreatedAt,
                //                selection: Binding(
                //                    get: { note.createdAt ?? Date() },
                //                    set: { note.createdAt = $0 }
                //                ),
                displayedComponents: [.date, .hourAndMinute]
            )
            .customPickerModifier()
            
            SymptomTags(critical: $critical)
            
            VStack(alignment: .leading, spacing: 8) {
                SectionTitle(title: "Negative symptoms", textColor: Color("PrimaryText"))
                    .padding(.bottom, 20)
                NewRows(newNote: $newSymptoms, rows: $rows, meal: false)
                AppendingRowBtn(rows: $rows)
            }
            Spacer()
        }
        .customBgModifier()
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                //                DeleteBtn(action: { model.showDeleteSymptomAlert = true })
                DeleteBtn(action: { showDeleteSymptomAlert = true })
                SaveBtn(action: {
                    //                    model.updateSymptomNote(entity: note, createdAt: symptomCreatedAt, symptoms: newSymptoms, critical: chosenColor == .blue ? false : true)
                    //                    model.clearSymptomStates()
                    //                    dismiss()
                    vm.updateSymptom(entity: note, createdAt: symptomCreatedAt, symptoms: newSymptoms, critical: critical)
                    dismiss()
                })
            }
        }
        .alert(LocalizedStringKey("Do you want to delete this symptom?"), isPresented: $showDeleteSymptomAlert) {
            //            CancelBtn(action: {  model.clearSymptomStates() })
            CancelBtn(action: {  })
            DeleteBtn(action: {
                //                model.deleteSymptomNote(symptomNote: note)
                vm.deleteSymptom(entity: note)
                dismiss()
            })
        }
        .onAppear {
            rows = noteToRows
            symptomCreatedAt = note.createdAt ?? Date()
            
            //            if note.critical {
            //                chosenColor = SymptomTagsEnum.red
            //            } else {
            //                chosenColor = SymptomTagsEnum.blue
            //            }
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
