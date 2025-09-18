//
//  SelectElementPicker.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 07/09/2025.
//

import SwiftUI

func dataForPicker(mealsMode: Bool, model: CoreDataViewModel, excluded: String? = nil) -> [String] {
    var array: [String] = []
    
    if mealsMode {
        for mealNote in model.savedMealNotes {
            if let ingredients = mealNote.ingredients {
                let el = ingredients.components(separatedBy: ", ")
                array.append(contentsOf: el)
            }
        }
        
    } else {
        for symptomNote in model.savedSymptomNotes {
            if let symptoms = symptomNote.symptoms {
                let el = symptoms.components(separatedBy: ", ")
                array.append(contentsOf: el)
            }
        }
    }
    
    if excluded != nil {
        return array.filter { $0 != excluded }
    }
    
    return Array(Set(array)).sorted(by: <)
}

struct SelectElementPicker: View {
    let pickerData: [String]
    
    @Binding var pickerSelection: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Picker("Select", selection: $pickerSelection) {
                Text("None").tag(nil as String?)
                    .font(.subheadline)
                    .foregroundStyle(.accent)
                ForEach(pickerData, id: \.self) { el in
                    Text(el)
                        .font(.subheadline)
                        .foregroundStyle(.accent)
                        .tag(el as String?)
                        .textCase(.lowercase)
                        .fontWeight(.regular)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity)
            .font(.subheadline)
            .pickerStyle(.menu)
            .padding(5)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("BackgroundColor"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color("SecondaryText").opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
}
