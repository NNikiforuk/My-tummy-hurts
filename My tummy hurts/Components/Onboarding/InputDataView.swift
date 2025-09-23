//
//  InputDataView.swift
//  Tummy hurts
//
//  Created by Natalia Nikiforuk on 11/03/2025.
//

import SwiftUI

struct InputDataView: View {
    @Binding var isOnboarding: Bool
    @State private var ingredient1: String = ""
    @State private var ingredient2: String = ""
    @State private var symptom1: String = ""
    @State private var symptom2: String = ""
    @State private var showSecondIngredient = false
    @State private var showSecondSymptom = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 50) {
            createItem(text: "Enter what you ate and drank", icon: "fork.knife", bindingText: $ingredient1, secondBindingText: $ingredient2, ifShow: showSecondIngredient)
            createItem(text: "Note any discomfort", icon: "toilet", bindingText: $symptom1, secondBindingText: $symptom2, ifShow: showSecondSymptom)
            
            HStack {
                Spacer()
                Image(systemName: "info.circle")
                Text("Be as specific as possible")
                Spacer()
            }
            .font(.callout).bold()
            .foregroundStyle(.accent)
            Spacer()
        }
        .padding()
        .padding(.top, 20)
        .onAppear {
            typeText("cow milk", into: $ingredient1) {
                withAnimation { showSecondIngredient = true }
                typeText("rye bread", into: $ingredient2, completion: nil)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                typeText("bloating", into: $symptom1) {
                    withAnimation { showSecondSymptom = true }
                    typeText("diarrhea", into: $symptom2, completion: nil)
                }
            }
        }
    }
    
    func createHStack(text: String, icon: String) -> some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: icon)
                .font(.callout)
            Text(LocalizedStringKey(text))
                .font(.body)
        }
    }
    
    func createItem(text: String, icon: String, bindingText: Binding<String>,     secondBindingText: Binding<String>, ifShow: Bool) -> some View {
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15 * Double(i)) {
                binding.wrappedValue.append(char)
                if i == text.count - 1 { completion?() }
            }
        }
    }
}

#Preview {
    InputDataView(isOnboarding: .constant(false))
}
