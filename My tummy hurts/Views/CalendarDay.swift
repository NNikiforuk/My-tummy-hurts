//
//  CalendarDay.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 15/09/2025.
//

import SwiftUI
import Charts

struct CalendarDay: View {
    @EnvironmentObject private var vm: CoreDataViewModel
    @Binding var selectedDate: Date
    
    let calendar = Calendar.current
    
    var startOfDay: Date {
        calendar.startOfDay(for: selectedDate)
    }
    
    var endOfDay: Date {
        calendar.date(byAdding: .day, value: 1, to: startOfDay)!
    }
    
    var filteredMeals: [MealNote] {
        onSameDay(
            vm.savedMealNotes,
            as: selectedDate,
            calendar: calendar,
            getTime: { $0.createdAt }
        )
    }
    
    var filteredSymptoms: [SymptomNote] {
        onSameDay(
            vm.savedSymptomNotes,
            as: selectedDate,
            calendar: calendar,
            getTime: { $0.createdAt }
        )
    }
    
    var meals: [Event] {
        filteredMeals.compactMap { meal in
            guard let mealTime = meal.createdAt else { return nil }
            guard let mealIngredients = meal.ingredients else { return nil }
            
            return Event(date: mealTime, type: .meals, tag: nil, icon: "fork.knife", desc: mealIngredients)
        }
    }
    
    var symptoms: [Event] {
        filteredSymptoms.compactMap { symptom in
            guard let symptomTime = symptom.createdAt else { return nil }
            guard let symptoms = symptom.symptom else { return nil }
            
            return Event(date: symptomTime, type: .symptoms, tag: symptom.critical ? .red : .blue, icon: "toilet", desc: symptoms)
        }
    }
    
    var data: [Event] {
        let allTogether = meals + symptoms
        return allTogether.sorted(by: { $0.date < $1.date })
    }
    
    var body: some View {
        ScrollView {
            VStack {
                pageTitle
                if data.isEmpty {
                    NoDataAlert(text: "No notes today")
                } else {
                    HStack {
                        SectionTitle(title: "Daily events", textColor: Color("SecondaryText"))
                            .textCase(.uppercase)
                        Spacer()
                    }
                    .padding(.top, 30)
                    DailyEvents(data: data)
                        .grayOverlayModifier()
                }
                Spacer()
            }
        }
        .customBgModifier()
    }
    
    var pageTitle: some View {
        Text(selectedDate, style: .date)
            .font(.title2.bold())
            .foregroundStyle(Color("PrimaryText"))
    }
}

struct Event: Identifiable {
    let id = UUID()
    let date: Date
    let type: NoteTab
    let tag: SymptomTagsEnum?
    let icon: String
    let desc: String
}

struct DailyEvents: View {
    var data: [Event]
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(data) { note in
                    Note(note: note)
                }
                .noteModifier()
            }
        }
    }
}

struct Note: View {
    @Environment(\.dynamicTypeSize) var sizeCategory
    var note: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: sizeCategory.isAccessibilitySize ? 20 :  10) {
                NoteIcon(icon: "clock")
                Text(note.date, style: .time)
                    .foregroundStyle(Color("PrimaryText"))
                if (note.tag != nil) {
                    Spacer()
                    Circle()
                        .fill(note.tag == SymptomTagsEnum.red ? SymptomTagsEnum.red.color.opacity(0.4) : SymptomTagsEnum.blue.color.opacity(0.4))
                        .frame(width: 15, height: 15)
                }
            }
            HStack(spacing: sizeCategory.isAccessibilitySize ? 20 :  10) {
                NoteIcon(icon: note.type == .meals ? "carrot" : "toilet")
                Text(note.desc)
                    .foregroundStyle(Color("PrimaryText"))
                    .lineLimit(1)
                Spacer()
            }
        }
    }
}

struct CalendarDay_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CalendarDay(selectedDate: .constant(Date()))
                .environmentObject(CoreDataViewModel())
        }
    }
}
