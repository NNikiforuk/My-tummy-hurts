//
//  SelectElementPicker.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 07/09/2025.
//

import SwiftUI

func dataForPicker(mealsMode: Bool, model: ViewModel) -> [String] {
    var array: [String] = []
    
    if mealsMode {
        for mealNote in model.mealNotes {
            if let ingredients = mealNote.ingredients {
                let el = ingredients.components(separatedBy: ", ")
                array.append(contentsOf: el)
            }
        }
    } else {
        for symptomNote in model.symptomNotes {
            if let symptoms = symptomNote.symptoms {
                let el = symptoms.components(separatedBy: ", ")
                array.append(contentsOf: el)
            }
        }
    }
    return Array(Set(array)).sorted(by: <)
}

struct SelectElementPicker: View {
    let sectionTitle: LocalizedStringKey
    let pickerData: [String]
    
    @Binding var pickerSelection: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionTitle(title: sectionTitle)
            VStack(alignment: .leading) {
            Picker(LocalizedStringKey("Select"), selection: $pickerSelection) {
                Text(LocalizedStringKey("None")).tag(nil as String?)
                    .font(.subheadline)
                ForEach(pickerData, id: \.self) { el in
                    Text(el)
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                        .tag(el as String?)
                        .textCase(.lowercase)
                        .fontWeight(.regular)
                        .lineLimit(1)
                        .font(.subheadline)
                }
            }
            .frame(maxWidth: .infinity)
            .font(.subheadline)
            .pickerStyle(.menu)
            .grayOverlayModifier()
        }
        }
        .padding(.top, 10)
    }
}
