//
//  CalendarChart.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 07/09/2025.
//

import SwiftUI

struct CalendarChart: View {
    @EnvironmentObject var model: ViewModel
    @Binding var selectedIngredient: String?
    
    @State private var selectedDate: Date = Date()
    @State private var currentPage: Int
    
    let months: [Date]
    
    var filteredMeals: [MealNote] {
        return model.mealNotes.filter { meal in
            meal.ingredients?.contains(selectedIngredient ?? "") ?? false
        }
    }
    
    init(selectedIngredient: Binding<String?>) {
        self._selectedIngredient = selectedIngredient
        
        let calendar = Calendar.current
        let today = Date()
        
        var dates: [Date] = []
        let start = calendar.date(byAdding: .year, value: -2, to: today)!
        let end   = calendar.date(byAdding: .year, value:  2, to: today)!
        
        var current = start
        while current <= end {
            dates.append(current.startOfMonth())
            current = calendar.date(byAdding: .month, value: 1, to: current)!
        }
        
        self.months = dates
        
        self._currentPage = State(
            initialValue: dates.firstIndex(where: {
                calendar.isDate($0, equalTo: today, toGranularity: .month)
            }) ?? 0
        )
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 10) {
                    if !model.mealNotes.isEmpty {
                        SelectElementPicker(sectionTitle: "SELECT INGREDIENT(S)", pickerData: dataForPicker(mealsMode: true, model: model), pickerSelection: $selectedIngredient)
                    }
                    VStack {
                        TabView(selection: $currentPage) {
                            ForEach(months.indices, id: \.self) { index in
                                MonthView(selectedDate: $selectedDate, month: months[index])
                                    .tag(index)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(height: 300)
                        .padding(.bottom, 40)
                        
                        TagsDescription()
                            .environmentObject(model)
                    }
                    .grayOverlayModifier()
                }
            }
        }
    }
}

struct MonthView: View {
    @Binding var selectedDate: Date
    
    let month: Date
    let calendar = Calendar.current
    
    var body: some View {
        VStack {
            Text(month.formatted(.dateTime.month(.wide).year()))
                .padding()
            
            let symbols = calendar.shortStandaloneWeekdaySymbols
            HStack {
                ForEach(symbols, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                }
            }
            
            let days = makeDays()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(days, id: \.self) { date in
                    if let date = date {
                        DayCell(date: date, selectedDate: $selectedDate)
                    } else {
                        Color.clear.frame(height: 40)
                    }
                }
            }
        }
    }
    
    private func makeDays() -> [Date?] {
        let range = calendar.range(of: .day, in: .month, for: month)!
        let firstDayOfMonth = month.startOfMonth()
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let offset = (firstWeekday - calendar.firstWeekday + 7) % 7
        
        var days: [Date?] = Array(repeating: nil, count: offset)
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
}

struct DayCell: View {
    let date: Date
    @Binding var selectedDate: Date
    
    var body: some View {
        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
        
        Text("\(Calendar.current.component(.day, from: date))")
            .frame(width: 35, height: 35)
            .background(
                Circle()
                    .fill(
                        isSelected
                        ? Color("PrimaryText")
                        : (isToday(date: date)
                           ? Color.gray.opacity(0.2)
                           : .clear
                          )
                    )
            )
            .foregroundColor(isSelected ? .white : .primary)
            .onTapGesture {
                withAnimation {
                    selectedDate = date
                }
            }
    }
    
    func isToday(date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
}

extension Date {
    func startOfMonth() -> Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
    }
}

struct TagsDescription: View {
    @EnvironmentObject var model: ViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 30) {
                Text("Symptom:")
                ForEach(SymptomTagsEnum.allCases) { el in
                    HStack {
                        Circle().fill(el.color)
                            .frame(width: 15, height: 15)
                        Text(el.desc)
                    }
                }
                Spacer()
            }
            if !model.mealNotes.isEmpty {
                HStack {
                    Text("Selected ingredient(s):")
                    Circle()
                        .fill(Color("NoteBgc"))
                        .frame(width: 15, height: 15)
                        .border(.gray)
                }
            }
        }
        .font(.caption2)
        .foregroundStyle(.gray)
    }
}

#Preview {
    CalendarChart(selectedIngredient: .constant("jajko"))
}
