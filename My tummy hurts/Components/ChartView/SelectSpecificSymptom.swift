//
//  SelectSpecificSymptom.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 07/09/2025.
//

import SwiftUI

struct SelectSpecificSymptom: View {
    @EnvironmentObject var model: ViewModel
    
    @Binding var selectedSpecificSymptom: String?
    
    let noSymptomNotes: Bool
    
    var symptomsForPicker: [String] {
        guard !model.symptomNotes.isEmpty else { return [] }
        
        var symptomsArray: [String] = []
        
        for symptomNote in model.symptomNotes {
            if let symptoms = symptomNote.symptoms {
                let el = symptoms.components(separatedBy: ", ")
                symptomsArray.append(contentsOf: el)
            }
        }
        return Array(Set(symptomsArray))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionTitle(title: "SELECT SYMPTOM")
            if noSymptomNotes {
                NoDataAlert(text: "Add symptoms to use this mode")
            } else {
                Picker(LocalizedStringKey("Select"), selection: $selectedSpecificSymptom) {
                    Text(LocalizedStringKey("None")).tag(nil as String?)
                        .font(.subheadline)
                    ForEach(symptomsForPicker, id: \.self) { note in
                        Text(note)
                            .font(.subheadline)
                            .foregroundStyle(.blue)
                            .tag(note as String?)
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
        .padding(.top, 20)
    }
}

struct SelectSpecificSymptom_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SelectSpecificSymptom(selectedSpecificSymptom: .constant("biegunka"), noSymptomNotes: false)
                .environmentObject(ViewModel())
        }
    }
}
