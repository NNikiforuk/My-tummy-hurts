//
//  InputDataView.swift
//  Tummy hurts
//
//  Created by Natalia Nikiforuk on 11/03/2025.
//

import SwiftUI

struct InputDataView: View {
    @State private var ingredient1: String = ""
    @State private var ingredient2: String = ""
    @State private var symptom1: String = ""
    @State private var symptom2: String = ""
    @State private var showSecondIngredient = false
    @State private var showSecondSymptom = false
    @State private var hasTypedIngredients = false
    @State private var hasTypedSymptoms = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 50) {
                createItem(text: "Enter what you ate and drank", icon: "fork.knife", bindingText: $ingredient1, secondBindingText: $ingredient2, ifShow: showSecondIngredient)
                createItem(text: "Note any discomfort", icon: "toilet", bindingText: $symptom1, secondBindingText: $symptom2, ifShow: showSecondSymptom)
                
                VStack(alignment: .leading) {
                    createInfo(text: "More data = better graphs")
                    createInfo(text: "Be as specific as possible")
                    createInfo(text: "Be consistent")
                    createInfo(text: "For example, always use „rye bread” instead of „bread rye”")
                }
                .padding(.top, 30)
                Spacer()
            }
        }
        .padding()
        .onAppear {
            if !hasTypedIngredients {
                hasTypedIngredients = true
                typeText(
                    NSLocalizedString("cow milk", comment: ""),
                    into: $ingredient1
                ) {
                    withAnimation { showSecondIngredient = true }
                    typeText(
                        NSLocalizedString("rye bread", comment: ""),
                        into: $ingredient2
                    ) {
                        if !hasTypedSymptoms {
                            hasTypedSymptoms = true
                            typeText(
                                NSLocalizedString("bloating", comment: ""),
                                into: $symptom1
                            ) {
                                withAnimation { showSecondSymptom = true }
                                typeText(
                                    NSLocalizedString("diarrhea", comment: ""),
                                    into: $symptom2,
                                    completion: nil
                                )
                            }
                        }
                    }
                }
            }
        }
    }
    
    func createInfo(text: LocalizedStringKey) -> some View {
        HStack(alignment: .top) {
            Image(systemName: "checkmark")
                .font(.body)
                .foregroundStyle(.accent)
            Text(text)
                .font(.body)
        }
        .font(.callout)
        .padding(.bottom, 10)
        .padding(.horizontal, 20)
    }
    
    func createHStack(text: LocalizedStringKey, icon: String) -> some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: icon)
                .font(.callout)
            Text(text)
                .font(.body)
        }
    }
    
    func createItem(text: LocalizedStringKey, icon: String, bindingText: Binding<String>,     secondBindingText: Binding<String>, ifShow: Bool) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            createHStack(text: text, icon: icon)
            TextField("", text: bindingText)
                .textFieldModifier()
                .font(.body)
                .padding(.top, 10)
            if ifShow {
                TextField("", text: secondBindingText)
                    .textFieldModifier()
                    .font(.body)
            }
        }
    }
    
    func typeText(_ text: String, into binding: Binding<String>, completion: (() -> Void)?) {
        for (i, char) in text.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.30 * Double(i)) {
                binding.wrappedValue.append(char)
                if i == text.count - 1 { completion?() }
            }
        }
    }
}
