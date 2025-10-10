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
    @Environment(\.dynamicTypeSize) var sizeCategory
    
    @State private var selectedDate: Date = Date()
    @State private var newIngredients = ""
    @State private var rows: [Row] = [Row()]
    @State private var isSaveDisabled = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                SiteTitle(title: "Add meal")
                if sizeCategory.isAccessibilitySize {
                    BiggerFontView(title: "Meal time", bindingData: $selectedDate)
                } else {
                    DefaultFontView(title: "Meal time", bindingData: $selectedDate)
                }
                AddNewIngredient(newIngredients: $newIngredients, rows: $rows)
                Spacer()
            }
        }
        .customBgModifier()
        .toolbar {
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

struct AddNewIngredient: View {
    @EnvironmentObject private var vm: CoreDataViewModel
    @Binding var newIngredients: String
    @Binding var rows: [Row]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionTitle(title: "Meal ingredients", textColor: Color("PrimaryText"))
                .padding(.bottom, 20)
            
            NewRows(newNote: $newIngredients, rows: $rows)
            AppendingRowBtn(rows: $rows)
        }
    }
}

struct NewRows: View {
    @EnvironmentObject private var vm: CoreDataViewModel
    
    @Binding var newNote: String
    @Binding var rows: [Row]
    
    @FocusState private var focusedRowID: UUID?
    @State private var syncWorkItem: DispatchWorkItem?
    @State private var hasOpenDropdown = false
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach($rows) { $row in
                IngredientRowField(
                    text: $row.text,
                    rowID: row.id,
                    focusedRowID: $focusedRowID,
                    onDropdownVisibilityChanged: { visible in
                        hasOpenDropdown = visible
                    },
                    onPick: { picked in
                        row.text = picked
                        scheduleSync()
                    },
                    onClear: { row.text = ""
                        scheduleSync()
                    },
                    onDelete: { id in
                        deleteRow(id)
                    }
                )
            }
        }
        .background(
            Group {
                if hasOpenDropdown {
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            focusedRowID = nil
                            hasOpenDropdown = false
                        }
                }
            }
        )
        .onChange(of: rows) { _ in scheduleSync() }
    }
    
    private func deleteRow(_ id: UUID) {
        focusedRowID = nil
        guard let i = rows.firstIndex(where: { $0.id == id }) else { return }
        
        DispatchQueue.main.async {
            if self.rows.count == 1 {
                self.rows[i].text = ""
            } else {
                self.rows.remove(at: i)
            }
            self.scheduleSync()
        }
    }
    
    private func scheduleSync() {
        syncWorkItem?.cancel()
        let snapshot = rows
        let item = DispatchWorkItem { [snapshot] in
            let joined = buildJoined(from: snapshot)
            if joined != newNote { newNote = joined }
        }
        syncWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(30), execute: item)
    }
    
    private func buildJoined(from rows: [Row]) -> String {
        let cleaned = rows.map(\.text)
            .map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
                    .trimmingCharacters(in: CharacterSet(charactersIn: ".,"))
            }
            .filter { !$0.isEmpty }
        var seen = Set<String>()
        let unique = cleaned.filter { seen.insert($0.lowercased()).inserted }
        return unique.joined(separator: ", ")
    }
}

struct AppendingRowBtn: View {
    @Binding var rows: [Row]
    
    var body: some View {
        Button {
            withAnimation {
                if rows.last?.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
                    rows.append(Row())
                }
            }
        } label: {
            PlusIcon()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 20)
    }
}

struct IngredientRowField: View {
    @EnvironmentObject private var vm: CoreDataViewModel
    @Binding var text: String
    let rowID: UUID
    var focusedRowID: FocusState<UUID?>.Binding
    
    var onDropdownVisibilityChanged: (Bool) -> Void = { _ in }
    var onPick: (String) -> Void
    var onClear: () -> Void
    var onDelete: (UUID) -> Void
    
    @State private var showDropdown = false
    @State private var fieldHeight: CGFloat = 0
    
    private var isFocused: Bool { focusedRowID.wrappedValue == rowID }
    private var filteredSuggestions: [String] {
        vm.ingredientSuggestions(prefix: text, includeAllWhenEmpty: false)
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    TextField("cow milk", text: $text)
                        .noteTextFieldModifier()
                        .background(
                            GeometryReader { g in Color.clear
                                    .onAppear { fieldHeight = g.size.height }
                                    .onChange(of: g.size.height) { fieldHeight = $0 }
                            }
                        )
                        .focused(focusedRowID, equals: rowID)
                        .onChange(of: focusedRowID.wrappedValue) { _ in
                            let visible = isFocused && !filteredSuggestions.isEmpty
                            if visible != showDropdown {
                                showDropdown = visible
                                onDropdownVisibilityChanged(visible)
                            }
                        }
                        .onChange(of: text) { _ in
                            let visible = isFocused && !filteredSuggestions.isEmpty
                            if visible != showDropdown {
                                showDropdown = visible
                                onDropdownVisibilityChanged(visible)
                            }
                        }
                    
                    Button {
                        focusedRowID.wrappedValue = nil
                        onDelete(rowID)
                        
                        if showDropdown {
                            showDropdown = false
                            onDropdownVisibilityChanged(false)
                        }
                    } label: {
                        Image(systemName: "xmark.circle").foregroundStyle(.secondary)
                    }
                }
                
                if showDropdown {
                    SuggestionDropdown(
                        suggestions: filteredSuggestions,
                        query: text
                    ) { picked in
                        onPick(picked)
                        focusedRowID.wrappedValue = nil
                        showDropdown = false
                        onDropdownVisibilityChanged(false)
                    }
                    .suggestionsModifier()
                }
            }
            .zIndex(1)
        }
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
