//
//  CalendarChart.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 07/09/2025.
//

import SwiftUI

struct CalendarChart: View {
    @EnvironmentObject var model: ViewModel
    @Binding var selectedFirstIngredient: String?
    @Binding var selectedSecondIngredient: String?
    @Binding var selectedDate: Date
    
    @State private var currentPage: Int
    
    let months: [Date]
    
    init(selectedFirstIngredient: Binding<String?>, selectedSecondIngredient: Binding<String?>, selectedDate: Binding<Date>) {
        self._selectedFirstIngredient = selectedFirstIngredient
        self._selectedSecondIngredient = selectedSecondIngredient
        self._selectedDate = selectedDate
        
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
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    if !model.mealNotes.isEmpty {
                        SectionTitle(title: "CHECK INGREDIENT OR COMBOS IN A MEAL", textColor: Color("SecondaryText"))
                        HStack {
                            SelectElementPicker(pickerData: dataForPicker(mealsMode: true, model: model, excluded: selectedSecondIngredient), pickerSelection: $selectedFirstIngredient)
                            SelectElementPicker(pickerData: dataForPicker(mealsMode: true, model: model, excluded: selectedFirstIngredient), pickerSelection: $selectedSecondIngredient)
                        }
                    }
                    VStack {
                        TabView(selection: $currentPage) {
                            ForEach(months.indices, id: \.self) { index in
                                MonthView(selectedDate: $selectedDate, selectedFirstIngredient: $selectedFirstIngredient, selectedSecondIngredient: $selectedSecondIngredient, month: months[index])
                                    .tag(index)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(height: 350)
                        .padding(.bottom, 40)
                        .environmentObject(model)
                        
                        TagsDescription()
                            .environmentObject(model)
                    }
                    .grayOverlayModifier()
                }
                .padding(.top, 30)
            }
        }
    }
}

struct MonthView: View {
    @EnvironmentObject var model: ViewModel
    @Binding var selectedDate: Date
    @Binding var selectedFirstIngredient: String?
    @Binding var selectedSecondIngredient: String?
    
    let month: Date
    let calendar = Calendar.current
    
    var body: some View {
        VStack {
            Text(month.formatted(.dateTime.month(.wide).year()))
                .padding(20)
                .bold()
                .foregroundStyle(Color("PrimaryText"))
            
            let symbols = calendar.shortStandaloneWeekdaySymbols
            HStack {
                ForEach(symbols, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(Color("PrimaryText"))
                }
            }
            
            let days = makeDays()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(days, id: \.self) { date in
                    if let date = date {
                        DayCell(selectedDate: $selectedDate, selectedFirstIngredient: $selectedFirstIngredient, selectedSecondIngredient: $selectedSecondIngredient, date: date)
                            .environmentObject(model)
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
    @EnvironmentObject var model: ViewModel
    @Binding var selectedDate: Date
    @Binding var selectedFirstIngredient: String?
    @Binding var selectedSecondIngredient: String?
    
    let date: Date
    
    var showSelectedIngredient: Color {
        let sameDateNotes = model.mealNotes.filter { note in
            if let created = note.createdAt {
                return Calendar.current.isDate(created, inSameDayAs: date)
            }
            return false
        }
        
        let contains = sameDateNotes.contains { note in
            guard let ingredients = note.ingredients else { return false }
            
            if let first = selectedFirstIngredient, let second = selectedSecondIngredient {
                if ingredients.contains(first) && ingredients.contains(second) {
                    return true
                }
            } else if let first = selectedFirstIngredient {
                if ingredients.contains(first) {
                    return true
                }
            } else if let second = selectedSecondIngredient {
                if ingredients.contains(second) {
                    return true
                }
            }
            return false
        }
        
        if contains {
            return .accent
        }
        
        return .clear
    }
    
    var symptomColor: SymptomTagsEnum? {
        let sameDayNotes = model.symptomNotes.filter { note in
            if let created = note.createdAt {
                return Calendar.current.isDate(created, inSameDayAs: date)
            }
            return false
        }
        
        let tags = sameDayNotes.map { note in
            (note.critical == true) ? SymptomTagsEnum.red : SymptomTagsEnum.blue
        }
        
        return tags.max(by: { $0.priority < $1.priority })
    }
    
    var body: some View {
        NavigationLink {
            CalendarDay(selectedDate: $selectedDate)
                .environmentObject(model)
        } label: {
            VStack {
                Text("\(Calendar.current.component(.day, from: date))")
                    .frame(width: 35, height: 35)
                    .background(
                        Circle()
                            .fill(
                                showSelectedIngredient
                            )
                    )
                    .overlay(
                        Circle().stroke(isToday(date: date) ? .gray.opacity(0.2) : Color.clear, lineWidth: 2)
                    )
                    .foregroundStyle(showSelectedIngredient == .accent ? .background : Color("PrimaryText"))
                    .fontWeight(isToday(date: date) ? .bold : .regular)
                
                if let tag = symptomColor {
                    Circle()
                        .fill(tag.color)
                        .frame(width: 10, height: 10)
                } else {
                    Circle()
                        .fill(.clear)
                        .frame(width: 10, height: 10)
                }
            }
        }
        .simultaneousGesture(TapGesture().onEnded {
            selectedDate = date
        })
    }
}

func isToday(date: Date) -> Bool {
    Calendar.current.isDateInToday(date)
}

extension Date {
    func startOfMonth() -> Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
    }
}


struct TagsDescription: View {
    @EnvironmentObject var model: ViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            HStack(spacing: 30) {
                Text("Symptom:")
                ForEach(SymptomTagsEnum.allCases) { el in
                    HStack {
                        Circle().fill(el.color)
                            .frame(width: 15, height: 15)
                        Text(el.desc)
                    }
                }
            }
        }
        .font(.caption2)
        .foregroundStyle(Color("SecondaryText"))
    }
}

#Preview {
    CalendarChart(selectedFirstIngredient: .constant("jajko"), selectedSecondIngredient: .constant("zgada"), selectedDate: .constant(Date()))
}
