//
//  AddMealView.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 03/09/2025.
//

import SwiftUI

struct AddMealView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var model: CoreDataViewModel
    
    @State private var selectedDate: Date = Date()
    @State private var newIngredients = ""
    @State private var rows: [Row] = []
    @State private var isSaveDisabled = true
    @State private var isEditorFocused = false
    
    var body: some View {
        VStack(spacing: 20) {
            SiteTitle(title: "Add meal")
            DatePicker(
                "Meal time",
                selection: $selectedDate,
                displayedComponents: [.date, .hourAndMinute]
            )
            .customPickerModifier()
            AddNewNote(newItems: $newIngredients, rows: $rows, meal: true)
            Spacer()
        }
        .customBgModifier()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                CancelBtn(action: {
                    clearForm()
                })
            }
            ToolbarItem(placement: .topBarTrailing) {
                SaveBtn(action: {
                    model.addMeal(createdAt: selectedDate, ingredients: newIngredients)
                    clearForm()
                })
                .fontWeight(.bold)
                .disabled(isSaveDisabled)
                .foregroundStyle(isSaveDisabled ? Color("SecondaryText") : .accent)
            }
        }
        .ignoresSafeArea(.keyboard)
        .onTapGesture {
            isEditorFocused = false
        }
        .onChange(of: newIngredients) {
            isSaveDisabled = $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    func clearForm() {
        selectedDate = Date()
        newIngredients = ""
        rows = []
        dismiss()
    }
}

struct AddMealView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AddMealView()
                .environmentObject(CoreDataViewModel())
        }
    }
}
