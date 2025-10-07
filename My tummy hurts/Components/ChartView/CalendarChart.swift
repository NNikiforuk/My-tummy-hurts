//
//  CalendarChart.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 07/09/2025.
//

import SwiftUI

struct CalendarChart: View {
    @EnvironmentObject private var vm: CoreDataViewModel
    @Environment(\.dynamicTypeSize) var sizeCategory
    
    @Binding var selectedFirstIngredient: String?
    @Binding var selectedSecondIngredient: String?
    @Binding var selectedDate: Date
    
    @State private var currentPage: Int
    @State private var showInfo = false
    
    let months: [Date]
    
    init(selectedFirstIngredient: Binding<String?>, selectedSecondIngredient: Binding<String?>, selectedDate: Binding<Date>) {
        self._selectedFirstIngredient = selectedFirstIngredient
        self._selectedSecondIngredient = selectedSecondIngredient
        self._selectedDate = selectedDate
        
        let customCalendar = Calendar.gregorianMondayFirst
        let today = Date()
        
        var dates: [Date] = []
        let start = customCalendar.date(byAdding: .year, value: -2, to: today)!
        let end   = customCalendar.date(byAdding: .year, value:  2, to: today)!
        
        var current = start
        while current <= end {
            dates.append(current.startOfMonth(using: customCalendar))
            current = customCalendar.date(byAdding: .month, value: 1, to: current)!
        }
        
        self.months = dates
        
        self._currentPage = State(
            initialValue: dates.firstIndex(where: {
                customCalendar.isDate($0, equalTo: today, toGranularity: .month)
            }) ?? 0
        )
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    if !vm.savedMealNotes.isEmpty {
                        HStack {
                            SectionTitle(title: "Select ingredients", textColor: Color("SecondaryText"))
                                .textCase(.uppercase)
                            Button {
                                withAnimation { showInfo.toggle() }
                            } label: {
                                Image(systemName: "info.circle")
                                    .font(.subheadline)
                                    .foregroundStyle(Color("SecondaryText"))
                            }
                        }
                        if showInfo {
                            Text("Pick one ingredient to highlight its days. Add a second to see days they occur in the same meal")
                                .font(.footnote)
                                .foregroundStyle(Color("SecondaryText"))
                                .transition(.opacity)
                                .padding(.vertical, 5)
                        }
                        
                        if sizeCategory.isAccessibilitySize {
                            VStack {
                                SelectElementPicker(pickerData: dataForPicker(mealsMode: true, model: vm, excluded: selectedSecondIngredient), pickerSelection: $selectedFirstIngredient)
                                Spacer()
                                SelectElementPicker(pickerData: dataForPicker(mealsMode: true, model: vm, excluded: selectedFirstIngredient), pickerSelection: $selectedSecondIngredient)
                            }
                        } else {
                            HStack {
                                SelectElementPicker(pickerData: dataForPicker(mealsMode: true, model: vm, excluded: selectedSecondIngredient), pickerSelection: $selectedFirstIngredient)
                                Spacer()
                                SelectElementPicker(pickerData: dataForPicker(mealsMode: true, model: vm, excluded: selectedFirstIngredient), pickerSelection: $selectedSecondIngredient)
                            }
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
                        .frame(height: 400)
                        TagsDescription()
                    }
                    .grayOverlayModifier()
                }
                .padding(.top, 30)
            }
        }
    }
}

struct MonthView: View {
    @EnvironmentObject private var vm: CoreDataViewModel
    @Environment(\.dynamicTypeSize) var sizeCategory
    
    @Binding var selectedDate: Date
    @Binding var selectedFirstIngredient: String?
    @Binding var selectedSecondIngredient: String?
    
    let month: Date
    let customCalendar = Calendar.gregorianMondayFirst
    
    var monthFormatter: Date.FormatStyle {
        var style = Date.FormatStyle().month(.wide).year()
        style.calendar = customCalendar
        return style
    }
    
    var body: some View {
        VStack {
            Text(month, format: monthFormatter)
                .padding(20)
                .bold()
                .foregroundStyle(Color("PrimaryText"))
                .font(sizeCategory.isAccessibilitySize ? .system(size: 34) : .body)
            
            let symbols = weekdaySymbols(for: customCalendar, dts: sizeCategory)
            let ordered = symbols.shifted(startingAt: customCalendar.firstWeekday - 1)
            HStack {
                ForEach(ordered, id: \.self) { day in
                    Text(day)
                        .font(sizeCategory.isAccessibilitySize ? .system(size: 18) : .caption)
                        .frame(maxWidth: .infinity)
                }
            }
            
            let days = makeDays()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(days.indices, id: \.self) { index in
                    if let date = days[index] {
                        DayCell(selectedDate: $selectedDate, selectedFirstIngredient: $selectedFirstIngredient, selectedSecondIngredient: $selectedSecondIngredient, date: date)
                    } else {
                        Color.clear
                            .frame(height: 32)
                    }
                }
            }
        }
    }
    
    private func weekdaySymbols(for cal: Calendar, dts: DynamicTypeSize) -> [String] {
        if dts.isAccessibilitySize {
            let narrow = cal.veryShortStandaloneWeekdaySymbols
            return narrow.isEmpty ? cal.shortStandaloneWeekdaySymbols.map { String($0.prefix(1)) } : narrow
        } else {
            return cal.shortStandaloneWeekdaySymbols
        }
    }
    
    private func makeDays() -> [Date?] {
        let range = customCalendar.range(of: .day, in: .month, for: month)!
        let firstDayOfMonth = month.startOfMonth(using: customCalendar)
        let weekdayIndex = customCalendar.component(.weekday, from: firstDayOfMonth)
        let offset = (weekdayIndex - customCalendar.firstWeekday + 7) % 7
        
        var days: [Date?] = Array(repeating: nil, count: offset)
        for day in range {
            if let date = customCalendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        return days
    }
}

struct DayCell: View {
    @EnvironmentObject private var vm: CoreDataViewModel
    @Environment(\.dynamicTypeSize) var sizeCategory
    
    @Binding var selectedDate: Date
    @Binding var selectedFirstIngredient: String?
    @Binding var selectedSecondIngredient: String?
    
    let date: Date
    let customCalendar = Calendar.gregorianMondayFirst
    
    var showSelectedIngredient: Color {
        let sameDateNotes = vm.savedMealNotes.filter { note in
            if let created = note.createdAt {
                return customCalendar.isDate(created, inSameDayAs: date)
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
        let sameDayNotes = vm.savedSymptomNotes.filter { note in
            if let created = note.createdAt {
                return customCalendar.isDate(created, inSameDayAs: date)
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
        } label: {
            VStack {
                Text("\(Calendar.current.component(.day, from: date))")
                    .frame(width: 30, height: 30)
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
                    .font(sizeCategory.isAccessibilitySize ? .system(size: 24) : .body)
                
                if let tag = symptomColor {
                    Circle()
                        .fill(tag.color)
                        .frame(width: 8, height: 8)
                } else {
                    Circle()
                        .fill(.clear)
                        .frame(width: 8, height: 8)
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

struct TagsDescription: View {
    @Environment(\.dynamicTypeSize) var sizeCategory
    
    var body: some View {
        VStack(alignment: .center) {
            HStack(spacing: 30) {
                Text("Symptom:")
                ForEach(SymptomTagsEnum.allCases) { el in
                    HStack {
                        Circle().fill(el.color)
                            .frame(width: 10, height: 10)
                        Text(el.localized)
                    }
                }
            }
        }
        .font(sizeCategory.isAccessibilitySize ? .system(size: 22) : .body )
        .foregroundStyle(Color("SecondaryText"))
        .padding(.top, 50)
    }
}

extension Date {
    func startOfMonth(using calendar: Calendar = .gregorianMondayFirst) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: self))!
    }
}

extension Calendar {
    static var gregorianMondayFirst: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        calendar.timeZone = .current
        return calendar
    }()
}

extension Array {
    func shifted(startingAt index: Int) -> [Element] {
        guard !isEmpty, indices.contains(index) else { return self }
        return Array(self[index...] + self[..<index])
    }
}

#Preview {
    CalendarChart(selectedFirstIngredient: .constant("jajko"), selectedSecondIngredient: .constant("zgada"), selectedDate: .constant(Date()))
        .environmentObject(CoreDataViewModel())
}
