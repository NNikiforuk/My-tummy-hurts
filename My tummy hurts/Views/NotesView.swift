//
//  NotesView.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 03/09/2025.
//

import SwiftUI

struct NotesView: View {
    @Binding var selection: NoteTab
    @EnvironmentObject var model: ViewModel
    
    var body: some View {
        switch selection {
        case .meals:
            if model.mealNotes.isEmpty {
                noListData(text: "There are no meals yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(model.mealNotes) { note in
                    NavigationLink {
                        EditMeal(note: note)
                            .environmentObject(model)
                    } label: {
                        NoteMeal(note: note)
                    }
                    .noteModifier()
                }
            }
        case .symptoms:
            if model.symptomNotes.isEmpty {
                noListData(text: "There are no symptoms yet")
            } else {
                ForEach(model.symptomNotes) { note in
                    NavigationLink {
                        EditSymptom(note: note)
                            .environmentObject(model)
                    } label: {
                        NoteSymptom(note: note)
                    }
                    .noteModifier()
                }
            }
        }
    }
    
    func noListData(text: String) -> some View {
        Text(LocalizedStringKey(text))
            .padding(.top, 50)
            .font(.callout)
    }
}

struct NoteMeal: View {
    var note: MealNote
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            TopNoteRow(time: note.createdAt ?? Date())
            BottomNoteRow(text: note.ingredients ?? "")
        }
    }
}

struct NoteSymptom: View {
    var note: SymptomNote
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            TopNoteRow(time: note.createdAt ?? Date(), critical: note.critical)
            BottomNoteRow(text: note.symptoms ?? "")
        }
    }
}

#Preview {
    NotesView(selection: .constant(.meals))
}
