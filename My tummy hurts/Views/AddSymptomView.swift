//
//  AddSymptomView.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 03/09/2025.
//

import SwiftUI

struct AddSymptomView: View {
    @EnvironmentObject var model: ViewModel
    @Environment(\.dismiss) var dismiss
    
    @Binding var selectedDate: Date
    
    @State private var newSymptoms = ""
    @State private var rows: [Row] = []
    @State private var isSaveDisabled = true
    @State private var isEditorFocused = false
    @State private var chosenColor: SymptomTagsEnum = .blue
    
    var body: some View {
        VStack(spacing: 20) {
            SiteTitle(title: "Add symptom")
            DatePicker(
                LocalizedStringKey("Symptom time"),
                selection: $selectedDate,
                displayedComponents: [.hourAndMinute]
            )
            .customPickerModifier()
            SymptomTags(chosenColor: $chosenColor)
            AddEditRows(newItems: $newSymptoms, rows: $rows, meal: false)
            Spacer()
        }
        .customBgModifier()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                CancelBtn(action: {
                    model.clearSymptomStates()
                    dismiss()
                })
            }
            ToolbarItem(placement: .topBarTrailing) {
                SaveBtn(action: {
                    model.createSymptomNote()
                    model.clearSymptomStates()
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
        .onChange(of: newSymptoms) {
            isSaveDisabled = $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
}

struct SymptomTags: View {
    @Binding var chosenColor: SymptomTagsEnum
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Text(LocalizedStringKey("Symptom tag"))
                    .frame(width: 120, alignment: .leading)
                    .bold()
                Spacer()
                
                ForEach(SymptomTagsEnum.allCases) { el in
                    singleTag(el: el)
                }
            }
        }
    }
    
    private func singleTag(el: SymptomTagsEnum) -> some View {
        Button {
            chosenColor = el
        } label: {
            HStack {
                Text(el.desc)
            }
        }
        .padding(8)
        .background {
            if el == chosenColor {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(el.color.opacity(0.2))
            }
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(el.color.opacity(0.2), lineWidth: 2)
        }
    }
}


#Preview {
    AddSymptomView(selectedDate: .constant(Date()))
}
