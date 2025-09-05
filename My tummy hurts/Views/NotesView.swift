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
            } else {
                ForEach(model.mealNotes) { note in
                    NavigationLink {
                        EditMeal(note: note)
                            .environmentObject(model)
                    } label: {
                        NoteMeal(note: note, meals: true)
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
                        NoteSymptom(note: note, meals: false)
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
            .foregroundStyle(.secondary)
    }
}

struct NoteMeal: View {
    var note: MealNote
    let meals: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            TopNoteRow(time: note.createdAt ?? Date())
            BottomNoteRow(text: note.ingredients ?? "", meals: meals)
        }
    }
}

struct NoteSymptom: View {
    var note: SymptomNote
    let meals: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            TopNoteRow(time: note.createdAt ?? Date(), critical: note.critical)
            BottomNoteRow(text: note.symptoms ?? "", meals: meals)
        }
    }
}

struct TopNoteRow: View {
    let time: Date
    let critical: Bool?
    
    init(time: Date, critical: Bool? = nil) {
        self.time = time
        self.critical = critical
    }
    
    var body: some View {
            HStack(spacing: 10) {
                NoteIcon(icon: "clock")
                Text(time, style: .time)
                if let critical {
                    Circle()
                        .fill(critical ? SymptomTagsEnum.red.color : SymptomTagsEnum.blue.color)
                        .frame(width: 10, height: 10)
                }
                Spacer()
            }
    }
}

struct BottomNoteRow: View {
    let text: String
    let meals: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            NoteIcon(icon: meals ? "carrot" : "toilet")
            Text(text)
                .lineLimit(1)
            Spacer()
        }
    }
}

struct NoteIcon: View {
    let icon: String
    
    var body: some View {
        Image(systemName: icon)
            .frame(width: 28)
    }
}

#Preview {
    NotesView(selection: .constant(.meals))
}
