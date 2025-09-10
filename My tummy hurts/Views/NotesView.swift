//
//  NotesView.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 03/09/2025.
//

import SwiftUI

struct NotesView: View {
    @Binding var selection: NoteTab
    @Binding var selectedDate: Date
    @EnvironmentObject var model: ViewModel
    
    let calendar = Calendar.current
    
    var filteredMeals: [MealNote] {
        onSameDay(
            model.mealNotes,
            as: selectedDate,
            calendar: calendar,
            getTime: { $0.createdAt }
        )
    }
    
    var filteredSymptoms: [SymptomNote] {
        onSameDay(
            model.symptomNotes,
            as: selectedDate,
            calendar: calendar,
            getTime: { $0.createdAt }
        )
    }
    
    var body: some View {
        switch selection {
        case .meals:
            if filteredMeals.isEmpty {
                noListData(text: "There are no meals yet")
            } else {
                ForEach(filteredMeals) { note in
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
            if filteredSymptoms.isEmpty {
                noListData(text: "There are no symptoms yet")
            } else {
                ForEach(filteredSymptoms) { note in
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
            .foregroundStyle(.gray)
    }
}

struct NoteMeal: View {
    var note: MealNote
    let meals: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            TopNoteRow(time: note.createdAt ?? Date(), meals: meals)
            BottomNoteRow(text: note.ingredients ?? "", meals: meals)
        }
    }
}

struct NoteSymptom: View {
    var note: SymptomNote
    let meals: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            TopNoteRow(time: note.createdAt ?? Date(), critical: note.critical, meals: meals)
            BottomNoteRow(text: note.symptoms ?? "", meals: meals)
        }
    }
}

struct TopNoteRow: View {
    let time: Date
    let critical: Bool?
    let meals: Bool
    
    
    init(time: Date, critical: Bool? = nil, meals: Bool) {
        self.time = time
        self.critical = critical
        self.meals = meals
    }
    
    var body: some View {
            HStack(spacing: 10) {
                NoteIcon(icon: "clock")
                Text(time, style: .time)
                if let critical {
                    Spacer()
                    Circle()
                        .fill(critical ? SymptomTagsEnum.red.color : SymptomTagsEnum.blue.color)
                        .frame(width: 15, height: 15)
                }
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
    NotesView(selection: .constant(.meals), selectedDate: .constant(Date()))
}
