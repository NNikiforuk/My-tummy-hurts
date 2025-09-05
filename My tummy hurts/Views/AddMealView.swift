//
//  AddMealView.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 03/09/2025.
//

import SwiftUI

struct AddMealView: View {
    @EnvironmentObject var model: ViewModel
    @Environment(\.dismiss) var dismiss
    
    @Binding var selectedDate: Date
    
    @State private var newIngredients = ""
    @State private var rows: [Row] = []
    @State private var isSaveDisabled = true
    @State private var isEditorFocused = false
    
    var body: some View {
        VStack(spacing: 20) {
            SiteTitle(title: "Add meal")
            DatePicker(
                LocalizedStringKey("Meal time"),
                selection: $selectedDate,
                displayedComponents: [.hourAndMinute]
            )
            .customPickerModifier()
            AddEditRows(newItems: $newIngredients, rows: $rows, meal: true)
            Spacer()
        }
        .customBgModifier()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                CancelBtn(action: {
                    model.clearMealStates()
                    dismiss()
                })
            }
            ToolbarItem(placement: .topBarTrailing) {
                SaveBtn(action: {
                    model.createMealNote(ingredients: newIngredients, createdAt: selectedDate)
                    model.clearMealStates()
                })
                .fontWeight(.bold)
                .disabled(isSaveDisabled)
                .foregroundStyle(isSaveDisabled ? .gray : .green)
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
}

//#Preview {
//    AddMealView(selectedDate: .constant(Date()))
//}

struct AddMealView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AddMealView(selectedDate: .constant((Date())))
        }
    }
}
