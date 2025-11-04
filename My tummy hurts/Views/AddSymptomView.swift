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
    @Environment(\.dynamicTypeSize) var sizeCategory
    
    @State private var selectedDate: Date = Date()
    @State private var newSymptom = ""
    @State private var isSaveDisabled = true
    @State private var critical: Bool = false
    @State private var hasOpenDropdown = false
    @State private var closeDropdownTick = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                SiteTitle(title: "Add symptom")
                if sizeCategory.isAccessibilitySize {
                    BiggerFontView(title: "Symptom time", bindingData: $selectedDate)
                } else {
                    DefaultFontView(title: "Symptom time", bindingData: $selectedDate)
                }
                SymptomTags(critical: $critical)
                HStack {
                    SectionTitle(title: "Symptom", textColor: Color("PrimaryText"))
                    Spacer()
                }
                FieldWithSuggestions(newSymptom: $newSymptom, onDropdownVisibilityChanged: { visible in hasOpenDropdown = visible },
                                     closeTick: closeDropdownTick)
                Spacer()
            }
        }
        .customBgModifier()
        .background(
            Group {
                if hasOpenDropdown {
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            hasOpenDropdown = false
                            closeDropdownTick &+= 1
                        }
                }
            }
        )
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                SaveBtn(action: {
                    model.addSymptom(createdAt: selectedDate, symptom: newSymptom, critical: critical)
                    clearForm()
                })
                .disabled(isSaveDisabled)
                .foregroundStyle(isSaveDisabled ? .gray : .accent)
            }
        }
        .onChange(of: newSymptom) {
            isSaveDisabled = $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    func clearForm() {
        selectedDate = Date()
        newSymptom = ""
        critical = false
        dismiss()
    }
}

struct FieldWithSuggestions: View {
    @EnvironmentObject private var vm: CoreDataViewModel
    @Binding var newSymptom: String
    
    var onDropdownVisibilityChanged: (Bool) -> Void = { _ in }
    var closeTick: Int = 0
    
    @FocusState private var focused: Bool
    @State private var showDropdown = false
    @State private var fieldHeight: CGFloat = 0
    
    private var filtered: [String] {
        vm.symptomSuggestions(prefix: newSymptom, includeAllWhenEmpty: false)
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 6) {
                TextField("diarrhea", text: $newSymptom)
                    .noteTextFieldModifier()
                    .background(
                        GeometryReader { g in Color.clear
                                .onAppear { fieldHeight = g.size.height }
                                .onChange(of: g.size.height) { fieldHeight = $0 }
                        }
                    )
                    .focused($focused)
                    .onChange(of: focused) { _ in
                        let visible = focused && !filtered.isEmpty
                        if visible != showDropdown {
                            showDropdown = visible
                            onDropdownVisibilityChanged(visible)
                        }
                    }
                    .onChange(of: newSymptom) { _ in
                        let visible = focused && !filtered.isEmpty
                        if visible != showDropdown {
                            showDropdown = visible
                            onDropdownVisibilityChanged(visible)
                        }
                    }
                    .onChange(of: closeTick) { _ in
                        if showDropdown {
                            focused = false
                            showDropdown = false
                            onDropdownVisibilityChanged(false)
                        }
                    }
                
                if showDropdown {
                    SuggestionDropdown(
                        suggestions: filtered,
                        query: newSymptom
                    ) { picked in
                        newSymptom = picked
                        focused = false
                        showDropdown = false
                        onDropdownVisibilityChanged(false)
                    }
                    .suggestionsModifier()
                }
            }
            .zIndex(1)
        }
        .simultaneousGesture(
            TapGesture().onEnded {
                if showDropdown {
                    focused = false
                    showDropdown = false
                }
            }
        )
        .animation(.snappy, value: showDropdown)
    }
}

struct SymptomTags: View {
    @Environment(\.dynamicTypeSize) var sizeCategory
    
    @Binding var critical: Bool
    
    var body: some View {
        VStack {
            if sizeCategory.isAccessibilitySize {
                biggerFontView()
                    .padding(.vertical, 40)
            } else {
                defaultFontView()
            }
        }
    }
    
    func defaultFontView() -> some View {
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
    
    func biggerFontView() -> some View {
        VStack {
            HStack {
                Text("Symptom tag")
                    .bold()
                Spacer()
            }
            HStack {
                ForEach(SymptomTagsEnum.allCases) { el in
                    singleTag(el: el)
                }
            }
        }
    }
    
    func singleTag(el: SymptomTagsEnum) -> some View {
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
