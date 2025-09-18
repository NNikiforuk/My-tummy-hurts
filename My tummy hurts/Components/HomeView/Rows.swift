//
//  Rows.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 03/09/2025.
//

import Foundation
import SwiftUI

struct AddNewNote: View {
    @EnvironmentObject private var vm: CoreDataViewModel
    
    @Binding var newItems: String
    @Binding var rows: [Row]
    
    let meal: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionTitle(title: meal ? "Meal ingredients" : "Negative symptoms", textColor: Color("PrimaryText"))
                .padding(.bottom, 20)
            NewRows(newNote: $newItems, rows: $rows, meal: meal)
            AppendingRowBtn(rows: $rows)
        }
    }
}

struct NewRows: View {
    @EnvironmentObject private var vm: CoreDataViewModel
    
    @Binding var newNote: String
    @Binding var rows: [Row]
    
    @FocusState private var focusedRowID: UUID?
    
    let meal: Bool
    
    var suggestions: [String] {
        if meal {
            guard !vm.savedMealNotes.isEmpty else { return [] }
            
            var ingredientsArray: [String] = []
            
            for mealNote in vm.savedMealNotes {
                if let ingredients = mealNote.ingredients {
                    let el = ingredients.components(separatedBy: ", ")
                    ingredientsArray.append(contentsOf: el)
                }
            }
            
            return Array(Set(ingredientsArray))
        } else {
            guard !vm.savedSymptomNotes.isEmpty else { return [] }
            
            var symptomsArray: [String] = []
            for symptomNote in vm.savedSymptomNotes {
                if let symptoms = symptomNote.symptoms {
                    let el = symptoms.components(separatedBy: ", ")
                    symptomsArray.append(contentsOf: el)
                }
            }
            return Array(Set(symptomsArray))
        }
    }
    
    func filteredSuggestions(text: String) -> [String] {
        guard !text.isEmpty else { return [] }
        return suggestions.filter { $0.lowercased().hasPrefix(text.lowercased()) }
    }
    
    var body: some View {
        VStack {
            ForEach(rows, id: \.id) { row in
                let binding = Binding(
                    get: { row.text },
                    set: { newValue in
                        if let index = rows.firstIndex(where: { $0.id == row.id }) {
                            rows[index].text = newValue
                            syncNewNote()
                        }
                    }
                )
                
                VStack {
                    HStack(spacing: 8) {
                        TextField(meal ? "cow milk" : "diarrhea", text: binding)
                            .focused($focusedRowID, equals: row.id)
                            .disableAutocorrection(true)
                            .padding(5)
                            .padding(.horizontal, 10)
                            .overlay {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(Color("SecondaryText"), lineWidth: 1)
                            }
                            .foregroundStyle(Color("PrimaryText"))
                            .lineLimit(1)
                            .textInputAutocapitalization(.never)
                            .onChange(of: rows.map(\.text)) { _ in syncNewNote() }
                            .onAppear { syncNewNote() }
                        
                        XMarkBtn(rows: $rows, id: row.id) {
                            if focusedRowID == row.id {
                                focusedRowID = nil
                            }
                        }
                    }
                    
                    if focusedRowID == row.id {
                        let matches = filteredSuggestions(text: row.text)
                        
                        if !matches.isEmpty {
                            Suggestion(newNote: binding, suggestions: matches) {
                                focusedRowID = nil
                            }
                        }
                    }
                }
                .id(row.id)
                .padding(.bottom, 10)
                .onChange(of: rows) { newRows in
                    if !newRows.contains(where: { $0.id == focusedRowID }) {
                        focusedRowID = nil
                    }
                }
            }
        }
    }
    
    private func syncNewNote() {
        let items = rows
            .map(\.text)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        var seen = Set<String>()
        let unique = items.filter { item in
            let key = item.lowercased()
            return seen.insert(key).inserted
        }
        newNote = unique.joined(separator: ", ")
    }
}

struct XMarkBtn: View {
    @Binding var rows: [Row]
    
    var id: UUID
    var onDelete: (() -> Void)?
    
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
                onDelete?()
            }
        } label: {
            Image(systemName: "xmark")
        }
        .foregroundStyle(Color("SecondaryText"))
    }
}

struct Suggestion: View {
    @Binding var newNote: String
    
    var suggestions: [String]
    var onSelect: (() -> Void)? = nil
    
    var sortedSuggestions: [String] {
        suggestions.sorted(by: { $0 < $1 })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(sortedSuggestions, id: \.self) { suggestion in
                Button {
                    newNote = suggestion
                    onSelect?()
                } label: {
                    Text(suggestion)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(Color("SecondaryText"))
                }
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(radius: 4)
        .offset(y: 5)
    }
}
