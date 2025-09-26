//
//  AddSymptomView.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 03/09/2025.
//

import SwiftUI

struct AddSymptomView: View {
    @EnvironmentObject private var model: CoreDataViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedDate: Date = Date()
    @State private var newSymptoms = ""
    @State private var rows: [Row] = []
    @State private var isSaveDisabled = true
    @State private var isEditorFocused = false
    @State private var critical: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            SiteTitle(title: "Add symptom")
            DatePicker(
               "Symptom time",
                selection: $selectedDate,
                displayedComponents: [.date, .hourAndMinute]
            )
            .customPickerModifier()
            SymptomTags(critical: $critical)
            AddNewNote(newItems: $newSymptoms, rows: $rows, meal: false)
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
                    model.addSymptom(createdAt: selectedDate, symptoms: newSymptoms, critical: critical)
                    clearForm()
                })
                .fontWeight(.bold)
                .disabled(isSaveDisabled)
                .foregroundStyle(isSaveDisabled ? .gray : .accent)
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
    
    func clearForm() {
        selectedDate = Date()
        newSymptoms = ""
        rows = []
        critical = false
        dismiss()
    }
}

struct SymptomTags: View {
    @Binding var critical: Bool
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Text("Symptom tag")
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
            critical = (el == .red)
        } label: {
            HStack {
                Text(el.localized)
                    .foregroundStyle(Color("PrimaryText"))
            }
        }
        .padding(8)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(
                    (el == .blue && !critical) || (el == .red && critical)
                    ? el.color.opacity(0.2)
                    : .clear
                )
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(el.color.opacity(0.2), lineWidth: 2)
        )
    }
}


#Preview {
    AddSymptomView()
        .environmentObject(CoreDataViewModel())
}
