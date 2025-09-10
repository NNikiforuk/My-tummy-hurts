//
//  SelectSymptoms.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 07/09/2025.
//

import SwiftUI

struct SelectSymptom: View {
    @EnvironmentObject var model: ViewModel
    
    @Binding var selectedSymptomID: UUID?
    
    let noSymptomNotes: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionTitle(title: "SELECT SYMPTOM")
            
            if noSymptomNotes {
                NoDataAlert(text: "Add symptoms to use this mode")
            } else {
                Picker(LocalizedStringKey("Select"), selection: $selectedSymptomID) {
                    Text(LocalizedStringKey("None")).tag(nil as UUID?)
                        .font(.subheadline)
                    listedSymptoms
                }
                .frame(maxWidth: .infinity)
                .font(.subheadline)
                .pickerStyle(.menu)
                .grayOverlayModifier()
            }
        }
        .padding(.top, 20)
    }
    
    var listedSymptoms: some View {
        ForEach(model.symptomNotes, id: \.id) { note in
            HStack {
                if let desc = note.symptoms, let time = note.createdAt {
                    let dateFormatter: DateFormatter = {
                        let formatter = DateFormatter()
                        formatter.dateStyle = .short
                        formatter.timeStyle = .short
                        return formatter
                    }()
                    Text("\(dateFormatter.string(from: time)): \(desc)")
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                }
            }
            .tag(note.id)
            .textCase(.lowercase)
            .fontWeight(.regular)
            .lineLimit(1)
            .font(.subheadline)
        }
    }
}


//#Preview {
//    SelectSymptoms()
//}
