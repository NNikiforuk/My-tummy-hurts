//
//  Rows.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 03/09/2025.
//

import Foundation
import SwiftUI

struct AddNewNote: View {
    @EnvironmentObject var model: ViewModel
    
    @Binding var newItems: String
    @Binding var rows: [Row]
    
    let meal: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionTitle(title: meal ? "Meal ingredients" : "Negative symptoms")
            NewRows(newNote: $newItems, rows: $rows, meal: meal)
                .environmentObject(model)
            AppendingRowBtn(rows: $rows)
        }
    }
}

struct NewRows: View {
    @EnvironmentObject var model: ViewModel
    
    @Binding var newNote: String
    @Binding var rows: [Row]
    
    @FocusState private var focusedRowID: UUID?
    
    let meal: Bool
    
    var suggestions: [String] {
        if meal {
            guard !model.mealNotes.isEmpty else { return [] }
            
            var ingredientsArray: [String] = []
            
            for mealNote in model.mealNotes {
                if let ingredients = mealNote.ingredients {
                    let el = ingredients.components(separatedBy: ", ")
                    
                    if !ingredientsArray.contains(el) {
                        ingredientsArray.append(contentsOf: el)
                    }
                }
            }
            
            return ingredientsArray
        } else {
            guard !model.symptomNotes.isEmpty else { return [] }
            
            var symptomsArray: [String] = []
            for symptomNote in model.symptomNotes {
                if let symptoms = symptomNote.symptoms {
                    let el = symptoms.components(separatedBy: ", ")
                    if !symptomsArray.contains(el) {
                        symptomsArray.append(contentsOf: el)
                    }
                }
            }
            return symptomsArray
        }
    }
    
    var body: some View {
        ForEach($rows) { $row in
            let id = row.id
            VStack {
                HStack(spacing: 8) {
                    TextField(
                        meal ? "cow milk" : "diarrhea",
                        text: $row.text)
                    .focused($focusedRowID, equals: row.id)
                    .disableAutocorrection(true)
                    .padding(5)
                    .padding(.horizontal, 10)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color(UIColor.gray), lineWidth: 1)
                    }
                    .foregroundStyle(Color("PrimaryText"))
                    .lineLimit(1)
                    .textInputAutocapitalization(.never)
                    .onChange(of: rows.map(\.text)) { _ in syncNewNote() }
                    .onAppear {
                        syncNewNote()
                    }
                    XMarkBtn(rows: $rows, id: id)
                }
                
                if focusedRowID == row.id && !suggestions.isEmpty {
                    Suggestion(newNote: $row.text, suggestions: suggestions, onSelect: {
                        focusedRowID = nil
                    })
                }
            }
            .padding(.bottom, 10)
        }
    }
    
    private func syncNewNote() {
        newNote = rows.map(\.text)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }
}

struct XMarkBtn: View {
    @Binding var rows: [Row]
    
    var id: UUID
    
    var body: some View {
        Button {
            withAnimation {
                if rows.count == 1 {
                    if let index = rows.firstIndex(where: { $0.id == id }) {
                        rows[index].text = ""
                    }
                } else {
                    rows.removeAll { $0.id == id }
                }
            }
        } label: {
            Image(systemName: "xmark")
        }
        .foregroundStyle(.secondary)
    }
}

struct Suggestion: View {
    @Binding var newNote: String
    
    var suggestions: [String]
    var onSelect: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(suggestions, id: \.self) { suggestion in
                Button {
                        newNote = suggestion
                        onSelect?()
                } label: {
                    Text(suggestion)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(radius: 4)
        .offset(y: 5)
    }
}
