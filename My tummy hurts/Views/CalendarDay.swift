//
//  CalendarDay.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 15/09/2025.
//

import SwiftUI
import Charts

struct CalendarDay: View {
    @EnvironmentObject var model: ViewModel
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
        VStack {
            pageTitle
            HStack {
                SectionTitle(title: "EVENTS TIMELINE")
                Spacer()
            }
            .padding(.top, 30)
            TimelineChart(startOfDay: startOfDay, endOfDay: endOfDay, filteredMeals: filteredMeals, filteredSymptoms: filteredSymptoms)
                .environmentObject(model)
            legend
            Spacer()
        }
        .customBgModifier()
    }
    
    var pageTitle: some View {
        Text(selectedDate, style: .date)
            .font(.title2.bold())
            .foregroundStyle(Color("PrimaryText"))
    }
    
    var legend: some View {
        HStack(alignment: .center, spacing: 30) {
            legendItem(icon: "fork.knife", text: "meal", color: Color("PrimaryText"))
            legendItem(icon: "toilet", text: "minor symptom", color: SymptomTagsEnum.blue.color)
            legendItem(icon: "toilet", text: "major symptom", color: SymptomTagsEnum.red.color)
        }
        .font(.caption)
        .padding(.top, 10)
    }
    
    func legendItem(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.body)
            Text(text)
                .foregroundStyle(.primaryText)
        }
    }
}

struct Event: Identifiable {
    let id = UUID()
    let date: Date
    let type: NoteTab
    let tag: SymptomTagsEnum?
    let icon: String
}

struct TimelineChart: View {
    @EnvironmentObject var model: ViewModel
    
    var startOfDay: Date
    var endOfDay: Date
    var filteredMeals: [MealNote]
    var filteredSymptoms: [SymptomNote]
    
    var meals: [Event] {
        filteredMeals.compactMap { meal in
            guard let mealTime = meal.createdAt else { return nil }
            return Event(date: mealTime, type: .meals, tag: nil, icon: "fork.knife")
        }
    }
    
    var symptoms: [Event] {
        filteredSymptoms.compactMap { symptom in
            guard let symptomTime = symptom.createdAt else { return nil }
            return Event(date: symptomTime, type: .symptoms, tag: symptom.critical ? .red : .blue, icon: "toilet")
        }
    }
    
    var data: [Event] {
        meals + symptoms
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            Chart(data) { event in
                PointMark(x: .value("Time", event.date)
                )
                .symbol {
                    Image(systemName: event.icon)
                        .foregroundColor(event.tag?.color ?? .primaryText)
                        .font(.system(size: 17))
                }
            }
            .chartXScale(domain: startOfDay...endOfDay)
            .frame(width: UIScreen.main.bounds.width * 2, height: 100)
            .padding(30)
        }
        .grayOverlayModifier()
    }
}

#Preview {
    CalendarDay(selectedDate: .constant(Date()))
        .environmentObject(ViewModel())
}
