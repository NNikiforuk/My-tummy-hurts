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
//    @EnvironmentObject var model: ViewModel
    @EnvironmentObject private var vm: CoreDataViewModel
    
    let calendar = Calendar.current
    let onlyShow: Bool
    
    var filteredMeals: [MealNote] {
        onSameDay(
            vm.savedMealNotes,
//          model.mealNotes,
            as: selectedDate,
            calendar: calendar,
            getTime: { $0.createdAt }
        )
    }
    
    var filteredSymptoms: [SymptomNote] {
        onSameDay(
            vm.savedSymptomNotes,
//            model.symptomNotes,
            as: selectedDate,
            calendar: calendar,
            getTime: { $0.createdAt }
        )
    }
    
    var body: some View {
        VStack {
            switch selection {
            case .meals:
                if filteredMeals.isEmpty {
                    noListData(text: "There are no meals yet")
                } else {
                    if onlyShow {
                        ForEach(filteredMeals, id: \.objectID) { note in
                            NoteMeal(note: note, meals: true)
                                .noteModifier()
                        }
                    } else {
                        ForEach(filteredMeals, id: \.objectID) { note in
                            NavigationLink {
                                EditMeal(note: note)
                                //                                .environmentObject(model)
                            } label: {
                                NoteMeal(note: note, meals: true)
                            }
                            .noteModifier()
                        }
                    }
                }
            case .symptoms:
                if filteredSymptoms.isEmpty {
                    noListData(text: "There are no symptoms yet")
                } else {
                    if onlyShow {
                        ForEach(filteredSymptoms, id: \.objectID) { note in
                            NoteSymptom(note: note, meals: false)
                                .noteModifier()
                        }
                    } else {
                        ForEach(filteredSymptoms, id: \.objectID) { note in
                            NavigationLink {
                                EditSymptom(note: note)
                                //                                .environmentObject(model)
                            } label: {
                                NoteSymptom(note: note, meals: false)
                            }
                            .noteModifier()
                        }
                    }
                }
            }
        }
        .onChange(of: vm.savedMealNotes) { _ in
            _ = filteredMeals 
            _ = filteredSymptoms
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
//    var note: MealNote
    @ObservedObject var note: MealNote
    let meals: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            TopNoteRow(time: note.createdAt ?? Date(), meals: meals)
            BottomNoteRow(text: note.ingredients ?? "", meals: meals)
        }
    }
}

struct NoteSymptom: View {
//    var note: SymptomNote
    @ObservedObject var note: SymptomNote
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
    
    
    init(time: Date, critical: Bool? = false, meals: Bool) {
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
                    .fill(critical ? SymptomTagsEnum.red.color.opacity(0.4) : SymptomTagsEnum.blue.color).opacity(0.4)
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
            .foregroundStyle(Color("PrimaryText"))
            .frame(width: 28)
    }
}

#Preview {
    NotesView(selection: .constant(.meals), selectedDate: .constant(Date()), onlyShow: false)
        .environmentObject(CoreDataViewModel())
}
