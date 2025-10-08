//
//  NotesView.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 03/09/2025.
//

import SwiftUI

struct NotesView: View {
    @EnvironmentObject private var vm: CoreDataViewModel
    @Environment(\.dynamicTypeSize) var sizeCategory
    
    @Binding var selection: NoteTab
    @Binding var selectedDate: Date
    
    let calendar = Calendar.current
    let onlyShow: Bool
    
    var filteredMeals: [MealNote] {
        let onSame = onSameDay(
            vm.savedMealNotes,
            as: selectedDate,
            calendar: calendar,
            getTime: { $0.createdAt }
        )
        let sorted = onSame.sorted {
            ($0.createdAt ?? .distantPast) < ($1.createdAt ?? .distantPast)
        }
        return sorted
    }
    
    var filteredSymptoms: [SymptomNote] {
        let onSame = onSameDay(
            vm.savedSymptomNotes,
            as: selectedDate,
            calendar: calendar,
            getTime: { $0.createdAt }
        )
        let sorted = onSame.sorted {
            ($0.createdAt ?? .distantPast) < ($1.createdAt ?? .distantPast)
        }
        return sorted
    }
    
    var body: some View {
        VStack {
            switch selection {
            case .meals:
                if filteredMeals.isEmpty {
                    noListData(text: "No meals yet")
                } else {
                    if onlyShow {
                        ForEach(filteredMeals, id: \.objectID) { note in
                            NoteMeal(note: note, meals: true)
                                .noteModifier()
                        }
                    } else {
                        VStack(spacing: sizeCategory >= .accessibility3 ? 30 :  10) {
                            ForEach(filteredMeals, id: \.objectID) { note in
                                NavigationLink {
                                    EditMeal(note: note)
                                } label: {
                                    NoteMeal(note: note, meals: true)
                                }
                                .noteModifier()
                            }
                        }
                    }
                }
            case .symptoms:
                if filteredSymptoms.isEmpty {
                    noListData(text: "No symptoms yet")
                } else {
                    if onlyShow {
                        ForEach(filteredSymptoms, id: \.objectID) { note in
                            NoteSymptom(note: note, meals: false)
                                .noteModifier()
                        }
                    } else {
                        VStack(spacing: sizeCategory >= .accessibility3 ? 30 :  10) {
                            ForEach(filteredSymptoms, id: \.objectID) { note in
                                NavigationLink {
                                    EditSymptom(note: note)
                                } label: {
                                    NoteSymptom(note: note, meals: false)
                                }
                                .noteModifier()
                            }
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
    
    func noListData(text: LocalizedStringKey) -> some View {
        Text(text)
            .padding(.top, 50)
            .font(.callout)
            .foregroundStyle(.gray)
    }
}

struct NoteMeal: View {
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
    @ObservedObject var note: SymptomNote
    let meals: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            TopNoteRow(time: note.createdAt ?? Date(), critical: note.critical, meals: meals)
            BottomNoteRow(text: note.symptom ?? "", meals: meals)
        }
    }
}

struct TopNoteRow: View {
    @Environment(\.dynamicTypeSize) var sizeCategory
    
    let time: Date
    let critical: Bool?
    let meals: Bool
    
    
    init(time: Date, critical: Bool? = false, meals: Bool) {
        self.time = time
        self.critical = critical
        self.meals = meals
    }
    
    var body: some View {
        HStack(spacing: sizeCategory >= .accessibility3 ? 30 : 10) {
            NoteIcon(icon: "clock")
            Text(time, style: .time)
            if !meals {
                if let crit = critical {
                    Spacer()
                    Circle()
                        .fill(crit ? SymptomTagsEnum.red.color.opacity(0.4) : SymptomTagsEnum.blue.color).opacity(0.4)
                        .frame(width: 15, height: 15)
                }
            }
        }
    }
}

struct BottomNoteRow: View {
    @Environment(\.dynamicTypeSize) var sizeCategory
    
    let text: String
    let meals: Bool
    
    var body: some View {
        HStack(spacing: sizeCategory >= .accessibility3 ? 30 : 10) {
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
